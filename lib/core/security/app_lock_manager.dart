import 'dart:async';

import 'package:cryptography/cryptography.dart';

import '../security/secure_store.dart';

/// Kunci aplikasi (blueprint 6.8): PIN + auto-lock + batas percobaan backoff.
///
/// PIN disimpan di secure storage OS sebagai **hash PBKDF2** (tidak pernah
/// plain). Sesi terkunci saat app start atau setelah N menit idle (timer
/// di-reset setiap interaksi pengguna terdeteksi).
///
/// - **S-01:** PIN (hashed) di secure storage, bukan SharedPreferences.
/// - **Backoff:** setiap percobaan gagal menambah delay: 1s, 2s, 4s, 8s,
///   16s, 30s (maks). Setelah berhasil, counter reset.
/// - **Windows Hello/biometrik** ditunda (butuh plugin native
///   `local_auth`; S-05 Fase 8 mencatat plugin native berisiko crash AOT
///   pada toolchain MSVC 14.51 ini) — lihat docs Fase 11.
class AppLockManager {
  AppLockManager(this._store);

  final SecureStore _store;

  static const _pinHashKey = 'applock.pin.hash';
  static const _saltKey = 'applock.pin.salt';
  static const _enabledKey = 'applock.enabled';
  static const _autoLockMinutesKey = 'applock.autolock.minutes';

  /// Maksimum delay backoff (detik).
  static const maxBackoffSeconds = 30;

  bool _locked = true;
  bool _enabled = false;
  int _autoLockMinutes = 5;
  Timer? _idleTimer;
  int _failedAttempts = 0;
  DateTime? _lastFailure;
  Timer? _backoffTimer;

  /// Dipanggil saat status kunci berubah (auto-lock,lock manual, unlock).
  /// main() menghubungkannya ke appLockStateProvider supaya UI reaktif.
  void Function(bool locked)? onLockChanged;

  /// PIN aktif & app terkunci (single source of truth untuk UI gate).
  bool get isLocked => _enabled && _locked;
  bool get isEnabled => _enabled;
  int get autoLockMinutes => _autoLockMinutes;
  int get failedAttempts => _failedAttempts;

  /// Muat pengaturan dari secure storage. Dipanggil saat startup app.
  Future<void> load() async {
    final enabled = await _store.read(_enabledKey);
    _enabled = enabled == '1';
    final mins = await _store.read(_autoLockMinutesKey);
    if (mins != null) {
      final parsed = int.tryParse(mins);
      if (parsed != null && parsed >= 1 && parsed <= 60) _autoLockMinutes = parsed;
    }
    // Saat load, app mulai dalam keadaan terkunci bila kunci aktif.
    _locked = _enabled;
  }

  /// Aktifkan kunci dengan PIN baru. PIN divalidasi (min 4 digit) lalu
  /// disimpan sebagai hash + salt.
  Future<void> enable(String pin) async {
    if (!_isValidPin(pin)) {
      throw const AppLockException('PIN harus 4-8 digit angka.');
    }
    final salt = _generateSalt();
    final hash = await _hashPin(pin, salt);
    await _store.write(_saltKey, salt);
    await _store.write(_pinHashKey, hash);
    await _store.write(_enabledKey, '1');
    _enabled = true;
    _locked = false;
    _failedAttempts = 0;
    _scheduleAutoLock();
  }

  /// Nonaktifkan kunci (butuh PIN benar).
  Future<void> disable(String pin) async {
    if (!await verify(pin)) {
      throw const AppLockException('PIN salah.');
    }
    await _store.delete(_enabledKey);
    await _store.delete(_pinHashKey);
    await _store.delete(_saltKey);
    _enabled = false;
    _locked = false;
    _failedAttempts = 0;
    _idleTimer?.cancel();
  }

  /// Verifikasi PIN. Mengembalikan true bila benar.
  /// Bila salah, backoff diberlakukan (unlock dipending sesuai attempt).
  Future<bool> verify(String pin) async {
    final salt = await _store.read(_saltKey);
    final stored = await _store.read(_pinHashKey);
    if (salt == null || stored == null) return false;
    final hash = await _hashPin(pin, salt);
    if (hash == stored) {
      _failedAttempts = 0;
      _lastFailure = null;
      return true;
    }
    _failedAttempts++;
    _lastFailure = DateTime.now();
    return false;
  }

  /// Coba buka kunci. Melempar [AppLockException] bila masih dalam masa
  /// backoff (percobaan ditolak sepenuhnya). Mengembalikan true bila PIN
  /// benar dan kunci terbuka.
  Future<bool> unlock(String pin) async {
    if (!_enabled) return true;
    final remaining = backoffRemaining();
    if (remaining > 0) {
      throw AppLockException(
        'Terlalu banyak percobaan. Coba lagi dalam ${remaining}s.',
      );
    }
    final ok = await verify(pin);
    if (ok) {
      _locked = false;
      _scheduleAutoLock();
      return true;
    }
    // Gagal: hitung backoff untuk percobaan berikutnya. Percobaan kedua
    // (attempt=2) masih bebas; setelahnya delay eksponensial.
    _scheduleBackoffTimer();
    return false;
  }

  /// Kunci manual (mis. tombol "Kunci app" di pengaturan).
  void lock() {
    if (!_enabled) return;
    _locked = true;
    _idleTimer?.cancel();
    onLockChanged?.call(true);
  }

  /// Catat aktivitas pengguna; reset timer auto-lock (panggil dari
  /// WidgetsBindingObserver.userInteract atau tap apa pun).
  void reportUserActivity() {
    if (!_enabled || _locked) return;
    _scheduleAutoLock();
  }

  /// Atur periode auto-lock (1-60 menit).
  Future<void> setAutoLockMinutes(int minutes) async {
    if (minutes < 1 || minutes > 60) {
      throw const AppLockException('Periode 1-60 menit.');
    }
    _autoLockMinutes = minutes;
    await _store.write(_autoLockMinutesKey, minutes.toString());
    if (_enabled && !_locked) _scheduleAutoLock();
  }

  /// Detik tersisa sebelum percobaan diperbolehkan lagi (0 bila bebas).
  int backoffRemaining() {
    if (_failedAttempts == 0 || _lastFailure == null) return 0;
    final delay = _backoffFor(_failedAttempts);
    final elapsed = DateTime.now().difference(_lastFailure!).inSeconds;
    final remaining = delay - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  int _backoffFor(int attempts) {
    // 1-2 gagal: bebas. 3: 2s, 4: 4s, 5: 8s, 6+: 16s (capped 30s).
    if (attempts <= 2) return 0;
    final exp = attempts - 2;
    final secs = 1 << (exp > 4 ? 4 : exp); // 2,4,8,16,16...
    return secs > maxBackoffSeconds ? maxBackoffSeconds : secs;
  }

  void _scheduleBackoffTimer() {
    final remaining = backoffRemaining();
    if (remaining > 0) {
      _backoffTimer?.cancel();
      _backoffTimer = Timer(Duration(seconds: remaining), () {});
    }
  }

  void _scheduleAutoLock() {
    _idleTimer?.cancel();
    _idleTimer = Timer(Duration(minutes: _autoLockMinutes), () {
      if (_enabled) {
        _locked = true;
        onLockChanged?.call(true);
      }
    });
  }

  bool _isValidPin(String pin) =>
      pin.length >= 4 && pin.length <= 8 && int.tryParse(pin) != null;

  String _generateSalt() {
    final rng = DateTime.now().microsecondsSinceEpoch;
    return (rng ^ (rng >> 32)).toRadixString(16);
  }

  Future<String> _hashPin(String pin, String salt) async {
    // PBKDF2-HMAC-SHA256 via package:cryptography (sudah terpasang Fase 10).
    // 100.000 iterasi, output 32 byte -> hex.
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 32 * 8,
    );
    final secret = await pbkdf2.deriveKey(
      secretKey: SecretKey(pin.codeUnits),
      nonce: salt.codeUnits,
    );
    final bytes = await secret.extractBytes();
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Dispose semua timer (panggil saat app dispose).
  void dispose() {
    _idleTimer?.cancel();
    _backoffTimer?.cancel();
  }
}

/// Error kunci aplikasi (pesan aman ditampilkan ke pengguna).
class AppLockException implements Exception {
  const AppLockException(this.message);
  final String message;
  @override
  String toString() => 'AppLockException: $message';
}
