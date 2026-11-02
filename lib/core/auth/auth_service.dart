import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hasil sebuah operasi auth: sukses (session pengguna) atau pesan error
/// generik (A-07: "Email atau password salah" agar tidak membuka celah
/// enumerasi akun).
class AuthResult {
  const AuthResult({
    this.userId,
    this.email,
    this.error,
    this.needEmailVerify = false,
  });

  final String? userId;
  final String? email;
  final String? error;
  final bool needEmailVerify;

  bool get ok => error == null;
}

/// Satu sesi/perangkat aktif (A-11: layar "Perangkat dan sesi").
class DeviceInfo {
  const DeviceInfo({
    required this.id,
    required this.platform,
    this.lastSeen,
    this.current = false,
  });

  final String id;
  final String platform;
  final DateTime? lastSeen;
  final bool current;
}

/// Abstraksi penyedia autentikasi (8B.2: "Arsitektur memakai interface
/// AuthProvider agar penyedia dapat diganti").
///
/// Kontrak ini mengikuti aturan A-01..A-18. Implementasi Supabase ada di
/// [SupabaseAuthService]. Modul auth terisolasi dari agent (A-12): LLM
/// tidak menerima token dan tidak punya tool untuk memanggil auth.
abstract class AuthService {
  /// Status login saat ini.
  bool get isLoggedIn;
  String? get userId;
  String? get userEmail;

  /// Email+password (A-07: password minimal 12 karakter, email wajib
  /// diverifikasi sebelum akun aktif).
  Future<AuthResult> signUp({required String email, required String password});
  Future<AuthResult> signIn({required String email, required String password});

  /// Kirim tautan reset password (deep link kembali ke app).
  Future<AuthResult> sendPasswordReset({required String email});

  /// Magic link / OTP (8B.3: tawarkan agar pengguna tidak perlu password).
  Future<AuthResult> sendOtp({required String email});
  Future<AuthResult> verifyOtp({required String email, required String token});

  /// OAuth lewat browser sistem (A-01: dilarang WebView tertanam; A-02:
  /// PKCE; A-03: scope minimal).
  Future<AuthResult> signInWithGoogle();
  Future<AuthResult> signInWithGitHub();

  /// Keluar dari perangkat ini (A-14: hapus token sesi dari secure
  /// storage; Vault dan data lokal TIDAK ikut terhapus).
  Future<AuthResult> signOut();

  /// Keluar dari semua perangkat (A-11: sesi dapat dicabut).
  Future<AuthResult> signOutAll();

  /// Hapus akun (A-15: setelah re-autentikasi, permanen).
  Future<AuthResult> deleteAccount();

  /// Daftar sesi/perangkat aktif (A-11).
  Future<List<DeviceInfo>> listDevices();
}

/// Provider Riverpod tunggal (A-12: isolasi modul auth).
/// Implementasi dipasang di main() setelah initSupabase().
final authServiceProxyProvider = Provider<AuthService>((ref) {
  throw UnimplementedError('Pasang override authServiceProxyProvider di main.');
});
