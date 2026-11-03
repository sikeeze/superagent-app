import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:superagent/core/security/config_vault.dart';

void main() {
  group('ConfigVault (S-04)', () {
    test('round-trip: encrypt -> decrypt mengembalikan config asli', () async {
      const config = <String, dynamic>{
        'version': 1,
        'profiles': <Map<String, dynamic>>[
          {'id': 'p1', 'name': 'OpenAI', 'model': 'gpt-4o-mini'},
        ],
        'active_id': 'p1',
        'api_keys': <String, dynamic>{
          'p1': 'sk-Tp9Zm3qLd5Rj2WxYend1234567890',
        },
      };
      final enc = await ConfigVault.encrypt(config, 'passphrase-aman-123');
      expect(enc, isA<Uint8List>());
      expect(enc.length, greaterThan(50));

      final dec = await ConfigVault.decrypt(enc, 'passphrase-aman-123');
      expect(dec['active_id'], 'p1');
      expect((dec['profiles'] as List).length, 1);
      expect(dec['api_keys']['p1'], 'sk-Tp9Zm3qLd5Rj2WxYend1234567890');
    });

    test('passphrase salah -> exception', () async {
      final enc = await ConfigVault.encrypt(
        <String, dynamic>{'a': 1},
        'passphrase-benar-12345',
      );
      expect(
        () => ConfigVault.decrypt(enc, 'passphrase-salah-99999'),
        throwsA(isA<ConfigVaultException>()),
      );
    });

    test('magic salah -> exception', () async {
      final bad = Uint8List.fromList(utf8.encode('XXXX') + List<int>.filled(40, 0));
      expect(
        () => ConfigVault.decrypt(bad, 'passphrase-12345678'),
        throwsA(isA<ConfigVaultException>()),
      );
    });

    test('passphrase < 8 karakter -> exception', () async {
      expect(
        () => ConfigVault.encrypt(<String, dynamic>{}, 'pendek'),
        throwsA(isA<ConfigVaultException>()),
      );
    });

    test('data terpotong -> exception', () async {
      final short = Uint8List.fromList(List<int>.filled(10, 1));
      expect(
        () => ConfigVault.decrypt(short, 'passphrase-12345678'),
        throwsA(isA<ConfigVaultException>()),
      );
    });

    test('nonce unik per encrypt (random salt + nonce)', () async {
      const config = <String, dynamic>{'a': 1};
      final a = await ConfigVault.encrypt(config, 'passphrase-aman-123');
      final b = await ConfigVault.encrypt(config, 'passphrase-aman-123');
      // Salt + nonce random -> ciphertext berbeda untuk config yang sama.
      expect(a, isNot(equals(b)));
      // Keduanya tetap bisa didekrip.
      expect((await ConfigVault.decrypt(a, 'passphrase-aman-123'))['a'], 1);
      expect((await ConfigVault.decrypt(b, 'passphrase-aman-123'))['a'], 1);
    });
  });
}
