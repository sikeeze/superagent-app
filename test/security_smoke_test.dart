import 'package:flutter_test/flutter_test.dart';
import 'package:superagent/core/policy/network_guard.dart';
import 'package:superagent/core/policy/permissions.dart';
import 'package:superagent/core/policy/policy_engine.dart';
import 'package:superagent/core/security/bip39_wordlist.dart';
import 'package:superagent/core/security/redactor.dart';

/// Smoke test untuk inti keamanan (blueprint Bagian 12: uji SSRF, redaksi,
/// policy). Menjalankan: flutter test test/security_smoke_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Bip39Wordlist.load();
  });

  group('S-13 anti-SSRF', () {
    test('blokir rentang privat', () {
      expect(NetworkGuard.isPrivateHost('10.0.0.1'), isTrue);
      expect(NetworkGuard.isPrivateHost('192.168.1.1'), isTrue);
      expect(NetworkGuard.isPrivateHost('172.16.0.9'), isTrue);
      expect(NetworkGuard.isPrivateHost('172.31.255.1'), isTrue);
      expect(NetworkGuard.isPrivateHost('169.254.169.254'), isTrue);
      expect(NetworkGuard.isPrivateHost('100.64.0.1'), isTrue);
      expect(NetworkGuard.isPrivateHost('fd12:3456::1'), isTrue);
      expect(NetworkGuard.isPrivateHost('::ffff:10.0.0.1'), isTrue);
      expect(NetworkGuard.isPrivateHost('10.0.0.1:8080'), isTrue);
    });

    test('mengizinkan host publik', () {
      expect(NetworkGuard.isPrivateHost('172.32.0.1'), isFalse);
      expect(NetworkGuard.isPrivateHost('api.openai.com'), isFalse);
    });
  });

  group('S-10 cleartext', () {
    test('https diizinkan, http publik ditolak', () {
      expect(NetworkGuard.isCleartextAllowed(Uri.parse('https://a.com')), isTrue);
      expect(NetworkGuard.isCleartextAllowed(Uri.parse('http://a.com')), isFalse);
      expect(NetworkGuard.isCleartextAllowed(Uri.parse('http://localhost:8080')), isTrue);
      expect(NetworkGuard.isCleartextAllowed(Uri.parse('http://192.168.1.5')), isTrue);
    });
  });

  group('S-12 allowlist host', () {
    test('host kosong menolak semua', () {
      expect(NetworkGuard.hostAllowed('a.com', <String>{}), isFalse);
    });

    test('host dan subdomain diizinkan', () {
      expect(NetworkGuard.hostAllowed('a.com', <String>{'a.com'}), isTrue);
      expect(NetworkGuard.hostAllowed('b.a.com', <String>{'a.com'}), isTrue);
      expect(NetworkGuard.hostAllowed('c.com', <String>{'a.com'}), isFalse);
    });
  });

  group('hostOf', () {
    test('mengekstrak host dari url / argumen bare', () {
      expect(
        NetworkGuard.hostOf(<String, dynamic>{'url': 'https://api.x.com/v1'}),
        'api.x.com',
      );
      expect(
        NetworkGuard.hostOf(<String, dynamic>{'host': 'api.x.com'}),
        'api.x.com',
      );
      expect(NetworkGuard.hostOf(<String, dynamic>{}), isNull);
    });
  });

  group('S-03 redaksi rahasia', () {
    test('kunci API sk- dan supabase', () {
      expect(Redactor.redact('key sk-abcdEfghIjklmnopqr1234'), 'key sk-***');
      expect(Redactor.redact('sb_secret_abcdefghijklmnop1234'), 'sb_***');
    });

    test('header bearer (Authorization: Bearer ...)', () {
      final out = Redactor.redact(
          'Authorization: Bearer abcdefghijklmnopqrstuvwxyz123456');
      expect(out, isNot(contains('abcdefghijklmnopqrstuvwxyz')));
      expect(out, contains('***'));
    });

    test('kunci privat EVM', () {
      expect(Redactor.redact('0x${'a' * 64}'), '0x***');
    });

    test('JWT tiga segmen', () {
      expect(Redactor.redact('eyJhbGciOi.eyJzdWIiOiJ1.SflKxwRJS'), 'jwt.***');
    });

    test('seed phrase BIP-39', () {
      const phrase =
          'abandon ability able about above absent absorb abstract absurd '
          'abuse access accident';
      final out = Redactor.redact(phrase);
      expect(out, isNot(contains('abandon ability')));
      expect(out, contains('seed phrase'));
    });

    test('seed phrase di tengah kalimat', () {
      const text =
          'kunci saya: abandon ability able about above absent absorb '
          'abstract absurd abuse access accident tolong simpan';
      final out = Redactor.redact(text);
      expect(out, isNot(contains('abstract absurd')));
      expect(out, contains('seed phrase'));
    });

    test('mask tampilan', () {
      expect(Redactor.mask('abc'), '***');
      expect(Redactor.mask('sk-abcdefghijkl'), '***ijkl');
    });
  });

  group('6.6 PolicyEngine', () {
    final httpSpec = ToolSpec(
      name: 'http_request',
      description: 'fetch',
      inputSchema: <String, dynamic>{},
      risk: RiskLevel.low,
      permissions: <Permission>[Permission.network],
    );
    final policy =
        PolicyEngine(defaultAllowedHosts: <String>{'api.openai.com'});

    test('SSRF ditolak', () {
      final d = policy.evaluate(
        tool: httpSpec,
        args: <String, dynamic>{'url': 'http://169.254.169.254/'},
        granted: <Permission>{Permission.network},
      );
      expect(d.allowed, isFalse);
    });

    test('host di luar allowlist ditolak', () {
      final d = policy.evaluate(
        tool: httpSpec,
        args: <String, dynamic>{'url': 'https://evil.com/'},
        granted: <Permission>{Permission.network},
      );
      expect(d.allowed, isFalse);
    });

    test('host allowlist diizinkan', () {
      final d = policy.evaluate(
        tool: httpSpec,
        args: <String, dynamic>{'url': 'https://api.openai.com/v1/chat'},
        granted: <Permission>{Permission.network},
      );
      expect(d.allowed, isTrue);
    });

    test('izin yang hilang ditolak', () {
      final d = policy.evaluate(
        tool: httpSpec,
        args: <String, dynamic>{'url': 'https://api.openai.com/'},
        granted: <Permission>{},
      );
      expect(d.allowed, isFalse);
    });

    test('forbidden selalu ditolak berapa pun izin yang diberikan', () {
      final spec = ToolSpec(
        name: 'export_key',
        description: 'x',
        inputSchema: <String, dynamic>{},
        risk: RiskLevel.forbidden,
      );
      final d = policy.evaluate(
        tool: spec,
        args: <String, dynamic>{},
        granted: <Permission>{
          Permission.network,
          Permission.files,
          Permission.sign
        },
      );
      expect(d.allowed, isFalse);
      expect(d.needsConfirmation, isFalse);
    });

    test('risiko tinggi memerlukan konfirmasi', () {
      final spec = ToolSpec(
        name: 'send_funds',
        description: 'x',
        inputSchema: <String, dynamic>{},
        risk: RiskLevel.high,
      );
      final d = policy.evaluate(
        tool: spec,
        args: <String, dynamic>{},
        granted: <Permission>{},
      );
      expect(d.allowed, isFalse);
      expect(d.needsConfirmation, isTrue);
    });
  });
}
