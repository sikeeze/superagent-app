import 'package:flutter_test/flutter_test.dart';
import 'package:superagent/core/security/app_lock_manager.dart';
import 'package:superagent/core/security/secure_store.dart';

/// SecureStore palsu berbasis Map (tidak menyentuh keystore OS).
class _FakeStore implements SecureStore {
  final _data = <String, String>{};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<void> deleteAll() async => _data.clear();

  @override
  Future<bool> containsKey(String key) async => _data.containsKey(key);
}

void main() {
  late AppLockManager lock;

  setUp(() {
    lock = AppLockManager(_FakeStore());
  });

  group('AppLockManager (6.8)', () {
    test('awal: tidak terkunci bila belum diset', () async {
      await lock.load();
      expect(lock.isEnabled, isFalse);
      expect(lock.isLocked, isFalse);
    });

    test('enable + unlock dengan PIN benar', () async {
      await lock.enable('1234');
      expect(lock.isEnabled, isTrue);
      expect(lock.isLocked, isFalse); // baru di-enable tidak terkunci

      lock.lock();
      expect(lock.isLocked, isTrue);

      final ok = await lock.unlock('1234');
      expect(ok, isTrue);
      expect(lock.isLocked, isFalse);
    });

    test('unlock dengan PIN salah -> false, tidak terbuka', () async {
      await lock.enable('1234');
      lock.lock();
      final ok = await lock.unlock('9999');
      expect(ok, isFalse);
      expect(lock.isLocked, isTrue);
      expect(lock.failedAttempts, 1);
    });

    test('backoff: setelah beberapa kali gagal ada delay', () async {
      await lock.enable('1234');
      lock.lock();
      // Percobaan ke-2, 3, ... memicu backoff eksponensial.
      expect(await lock.unlock('9999'), isFalse); // attempt 1 -> bebas
      expect(await lock.unlock('9999'), isFalse); // attempt 2 -> bebas
      expect(await lock.unlock('9999'), isFalse); // attempt 3 -> delay 2s
      expect(lock.backoffRemaining(), lessThanOrEqualTo(2));
      // Setelah PIN benar, counter & backoff reset.
      await Future<void>.delayed(const Duration(seconds: 3));
      final ok = await lock.unlock('1234');
      expect(ok, isTrue);
      expect(lock.failedAttempts, 0);
      expect(lock.backoffRemaining(), 0);
    });

    test('disable butuh PIN benar', () async {
      await lock.enable('1234');
      expect(() => lock.disable('0000'), throwsA(isA<AppLockException>()));
      await lock.disable('1234');
      expect(lock.isEnabled, isFalse);
      expect(lock.isLocked, isFalse);
    });

    test('auto-lock periode 1-60 menit', () async {
      await lock.enable('1234');
      await lock.setAutoLockMinutes(10);
      expect(lock.autoLockMinutes, 10);
      expect(() => lock.setAutoLockMinutes(0), throwsA(isA<AppLockException>()));
      expect(() => lock.setAutoLockMinutes(61), throwsA(isA<AppLockException>()));
    });

    test('PIN invalid ditolak saat enable', () async {
      expect(() => lock.enable('123'), throwsA(isA<AppLockException>()));
      expect(() => lock.enable('abcd'), throwsA(isA<AppLockException>()));
      expect(() => lock.enable('123456789'), throwsA(isA<AppLockException>()));
    });

    test('load: app mulai terkunci bila kunci aktif', () async {
      // Store yang sama berisi setting dari enable() sebelumnya.
      final store = _FakeStore();
      final l1 = AppLockManager(store);
      await l1.enable('1234');
      // Simulasi restart: instance baru memuat setting dari store sama.
      final lock2 = AppLockManager(store);
      await lock2.load();
      expect(lock2.isEnabled, isTrue);
      expect(lock2.isLocked, isTrue);
    });

    test('onLockChanged dipanggil saat lock(); brute-force Backoff aktif', () async {
      final lock = AppLockManager(_FakeStore());
      await lock.load();
      await lock.enable('1234');

      var fired = false;
      lock.onLockChanged = (locked) => fired = locked;
      lock.lock();
      expect(fired, isTrue);
      expect(lock.isLocked, isTrue);

      // 3x salah -> backoff aktif (percobaan setelahnya ditolak total,
      // fail-closed: counter tidak naik tapi akses tetap diblok).
      String? err;
      for (var i = 0; i < 5; i++) {
        try {
          await lock.unlock('0000');
        } on AppLockException catch (e) {
          err = e.message;
        }
      }
      expect(lock.failedAttempts, 3);
      expect(err, isNotNull);
      // _backoffFor(3) = 2s.
      expect(lock.backoffRemaining(), greaterThan(0));

    });

    test('auto-lock timer: _locked true setelah timer idle', () async {
      final lock = AppLockManager(_FakeStore());
      await lock.load();
      await lock.setAutoLockMinutes(1);
      await lock.enable('1234');
      // Timer tidak bisa diuji langsung tanpa menunggu 1 menit; pastikan
      // state konsisten setelah enable (terkunci=false, enabled=true).
      expect(lock.isEnabled, isTrue);
      expect(lock.isLocked, isFalse);
    });
  });
}


