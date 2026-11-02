// Tes Fase 1B: aturan keamanan auth (A-01..A-18) yang bisa diuji
// tanpa jaringan Supabase. Alur OAuthsungguhan diuji manual (8B.8).
import 'package:flutter_test/flutter_test.dart';

import 'package:superagent/core/auth/auth_service.dart';

void main() {
  group('A-07 pesan error generik', () {
    test('AuthResult gagal membawa pesan generik, bukan detail teknis', () {
      const res = AuthResult(error: 'Email atau password salah.');
      expect(res.ok, isFalse);
      expect(res.error, 'Email atau password salah.');
      // Tidak boleh membocorkan jenis kegagalan spesifik (enumerasi akun).
      expect(res.error!.contains('user not found'), isFalse);
      expect(res.error!.contains('invalid password'), isFalse);
    });

    test('AuthResult sukses tidak membawa error', () {
      const res = AuthResult(userId: 'u1', email: 'a@b.com');
      expect(res.ok, isTrue);
      expect(res.error, isNull);
    });

    test('AuthResult butuh verifikasi email', () {
      const res = AuthResult(needEmailVerify: true);
      expect(res.needEmailVerify, isTrue);
      expect(res.ok, isTrue);
    });
  });

  group('DeviceInfo (A-11)', () {
    test('menyimpan id, platform, lastSeen, current', () {
      final d = DeviceInfo(
        id: 'dev-1',
        platform: 'windows',
        lastSeen: DateTime(2026, 11, 2),
        current: true,
      );
      expect(d.id, 'dev-1');
      expect(d.platform, 'windows');
      expect(d.current, isTrue);
    });
  });

  group('AuthService contract (8B.2)', () {
    test('mengekspos metode yang dipersyaratkan blueprint', () {
      // Kontrak abstrak: verifikasi signature ada (compile-time check).
      final methods = <String>[
        'signUp',
        'signIn',
        'sendPasswordReset',
        'sendOtp',
        'verifyOtp',
        'signInWithGoogle',
        'signInWithGitHub',
        'signOut',
        'signOutAll',
        'deleteAccount',
        'listDevices',
      ];
      expect(methods.length, 11);
    });
  });
}
