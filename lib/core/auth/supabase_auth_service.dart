import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'supabase_config.dart';

/// Redirect URI deep link (A-04: validasi callback hanya dari host/path
/// yang diharapkan; A-18: redirect_uri terdaftar hanya URI aplikasi ini).
const authRedirectUri = 'io.superagent.app://login';

/// Implementasi AuthService dengan Supabase (8B.2: disarankan).
///
/// - A-05: sesi dipersisten di secure storage oleh [supabase_config].
/// - A-06: token/OTP tidak pernah dicatat di log.
/// - A-07: pesan error generik.
class SupabaseAuthService implements AuthService {
  @override
  bool get isLoggedIn => supabase.auth.currentSession != null;

  @override
  String? get userId => supabase.auth.currentUser?.id;

  @override
  String? get userEmail => supabase.auth.currentUser?.email;

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signUp(email: email, password: password);
      // email_confirm aktif di project Supabase: akun butuh verifikasi.
      if (res.user == null || res.session == null) {
        return const AuthResult(needEmailVerify: true);
      }
      return AuthResult(userId: res.user!.id, email: res.user!.email);
    } on AuthException catch (_) {
      // A-07: pesan generik, jangan bocor jenis kegagalan spesifik.
      return const AuthResult(error: 'Pendaftaran gagal. Coba lagi nanti.');
    } catch (_) {
      return const AuthResult(error: 'Pendaftaran gagal. Coba lagi nanti.');
    }
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth
          .signInWithPassword(email: email, password: password);
      return AuthResult(userId: res.user?.id, email: res.user?.email);
    } on AuthException catch (_) {
      // A-07: pesan generik.
      return const AuthResult(error: 'Email atau password salah.');
    } catch (_) {
      return const AuthResult(error: 'Email atau password salah.');
    }
  }

  @override
  Future<AuthResult> sendPasswordReset({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return AuthResult(email: email);
    } catch (_) {
      return const AuthResult(error: 'Permintaan gagal. Coba lagi nanti.');
    }
  }

  @override
  Future<AuthResult> sendOtp({required String email}) async {
    try {
      await supabase.auth.signInWithOtp(email: email);
      return AuthResult(email: email);
    } catch (_) {
      return const AuthResult(error: 'Permintaan gagal. Coba lagi nanti.');
    }
  }

  @override
  Future<AuthResult> verifyOtp({
    required String email,
    required String token,
  }) async {
    try {
      final res = await supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.magiclink,
      );
      return AuthResult(userId: res.user?.id, email: res.user?.email);
    } catch (_) {
      return const AuthResult(error: 'Kode tidak valid atau kedaluwarsa.');
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() => _oauth('google');

  @override
  Future<AuthResult> signInWithGitHub() => _oauth('github');

  /// OAuth lewat browser sistem (A-01, A-02, A-03).
  Future<AuthResult> _oauth(String providerId) async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.values.byName(providerId),
        redirectTo: authRedirectUri,
        // A-02: PKCE dipaksa di tingkat klien (authOptions.flowType).
      );
      // Sesi datang lewat deep link; state dipantau oleh AuthNotifier.
      return const AuthResult();
    } catch (_) {
      return const AuthResult(error: 'Login gagal. Coba lagi nanti.');
    }
  }

  @override
  Future<AuthResult> signOut() async {
    try {
      await supabase.auth.signOut();
      // A-14: secure storage dibersihkan oleh AuthNotifier.
      return const AuthResult();
    } catch (_) {
      return const AuthResult(error: 'Keluar gagal. Coba lagi nanti.');
    }
  }

  @override
  Future<AuthResult> signOutAll() async {
    try {
      // A-11: cabut sesi refresh di perangkat lain.
      await supabase.auth.signOut(scope: SignOutScope.others);
      return const AuthResult();
    } catch (_) {
      return const AuthResult(error: 'Keluar dari semua perangkat gagal.');
    }
  }

  @override
  Future<AuthResult> deleteAccount() async {
    try {
      // A-15: penghapusan permanen hanya bisa lewat fungsi server aman
      // (butuh service-role key yang TIDAK boleh ada di app — A-10).
      // RPC delete_account() memverifikasi auth.uid() sendiri.
      await supabase.rpc('delete_account');
      await supabase.auth.signOut();
      return const AuthResult();
    } catch (_) {
      return const AuthResult(error: 'Hapus akun gagal. Coba lagi nanti.');
    }
  }

  @override
  Future<List<DeviceInfo>> listDevices() async {
    try {
      final res = await supabase
          .from('user_devices')
          .select('id, platform, last_seen, current_session')
          .order('last_seen', ascending: false);
      return (res as List).map((row) {
        final m = row as Map<String, dynamic>;
        return DeviceInfo(
          id: m['id'] as String,
          platform: m['platform'] as String? ?? 'Tidak diketahui',
          lastSeen: m['last_seen'] == null
              ? null
              : DateTime.tryParse(m['last_seen'].toString()),
          current: (m['current_session'] as bool?) ?? false,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
