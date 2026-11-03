import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Ekspor & impor konfigurasi terenkripsi (blueprint S-04).
///
/// Format file export (version 1):
/// ```
/// SEC1                    <- magic (4 byte ASCII)
/// <1 byte>  version = 1
/// <1 byte>  salt len (16)
/// <16 byte> salt (PBKDF2)
/// <1 byte>  nonce len (default 12 untuk AES-GCM)
/// <N byte>  nonce (AES-GCM)
/// <4 byte>  ciphertext len (big-endian uint32)
/// <N byte>  ciphertext (AES-256-GCM)
/// <16 byte> MAC (GCM tag)
/// ```
///
/// Kunci turunan dari passphrase via PBKDF2-SHA256, 200.000 iterasi
/// (blueprint: "iterasi tinggi"), 32 byte = AES-256. Cipher: AES-GCM
/// (authenticated encryption — integrity + confidentiality).
///
/// **S-02:** tidak ada kunci/passphrase yang di-hardcode; passphrase
/// diminta dari pengguna saat export maupun impor.
class ConfigVault {
  ConfigVault._();

  static const magic = 'SEC1';
  static const version = 1;
  static const _saltLen = 16;
  static const _pbkdf2Iterations = 200000;
  static const _keyLen = 32; // AES-256

  /// Enkrip [config] (JSON map) dengan [passphrase].
  /// Melempar [ConfigVaultException] bila passphrase lemah atau gagal.
  static Future<Uint8List> encrypt(
    Map<String, dynamic> config,
    String passphrase,
  ) async {
    if (passphrase.length < 8) {
      throw const ConfigVaultException(
        'Passphrase minimal 8 karakter (S-04).',
      );
    }
    final pbkdf2 = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: _pbkdf2Iterations, bits: _keyLen * 8);
    final secretKey = SecretKey(passphrase.codeUnits);
    final rng = Random.secure();
    final salt = Uint8List.fromList(
      List<int>.generate(_saltLen, (_) => rng.nextInt(256)),
    );
    final derived = await pbkdf2.deriveKey(secretKey: secretKey, nonce: salt);

    final plain = utf8.encode(jsonEncode(config));
    final algorithm = AesGcm.with256bits();
    final nonceR = algorithm.newNonce();
    final secret = await derived.extractBytes();
    final box = await algorithm.encrypt(
      plain,
      secretKey: SecretKey(secret),
      nonce: nonceR,
    );

    final out = BytesBuilder();
    out.add(magic.codeUnits);
    out.addByte(version);
    out.addByte(_saltLen);
    out.add(salt);
    out.addByte(nonceR.length);
    out.add(nonceR);
    _addUint32(out, box.cipherText.length);
    out.add(box.cipherText);
    out.add(box.mac.bytes);
    return out.toBytes();
  }

  /// Dekrip [data] hasil [encrypt] dengan [passphrase].
  /// Melempar [ConfigVaultException] bila magic salah, versi tidak dikenal,
  /// atau passphrase salah (AES-GCM gagal verifikasi tag).
  static Future<Map<String, dynamic>> decrypt(
    Uint8List data,
    String passphrase,
  ) async {
    if (data.length < 4 + 1 + 1 + _saltLen + 16 + 4) {
      throw const ConfigVaultException('File export terlalu pendek.');
    }
    final magicStr = String.fromCharCodes(data.sublist(0, 4));
    if (magicStr != magic) {
      throw const ConfigVaultException('Format file tidak dikenal (bukan SEC1).');
    }
    final ver = data[4];
    if (ver != version) {
      throw ConfigVaultException('Versi file export $ver tidak didukung.');
    }
    final saltLen = data[5];
    if (saltLen != _saltLen) {
      throw const ConfigVaultException('Panjang salt tidak valid.');
    }
    var off = 6;
    final salt = data.sublist(off, off + saltLen);
    off += saltLen;
    final nonceLen = data[off];
    off += 1;
    final nonce = data.sublist(off, off + nonceLen);
    off += nonceLen;
    final ctLen = _readUint32(data, off);
    off += 4;
    // ciphertext + 16 byte MAC (GCM tag).
    if (off + ctLen + 16 > data.length) {
      throw const ConfigVaultException('Panjang ciphertext tidak valid.');
    }
    final cipherText = data.sublist(off, off + ctLen);
    final mac = Mac(data.sublist(off + ctLen, off + ctLen + 16));

    final pbkdf2 = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: _pbkdf2Iterations, bits: _keyLen * 8);
    final derived = await pbkdf2.deriveKey(
      secretKey: SecretKey(passphrase.codeUnits),
      nonce: salt,
    );
    final secret = await derived.extractBytes();
    final algorithm = AesGcm.with256bits();
    List<int> plain;
    try {
      plain = await algorithm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: mac),
        secretKey: SecretKey(secret),
      );
    } on SecretBoxAuthenticationError {
      // Passphrase salah atau file rusak/dimasukkan (S-04: integrity check).
      throw const ConfigVaultException(
        'Passphrase salah atau file terkorupsi.',
      );
    } catch (_) {
      throw const ConfigVaultException('Dekripsi gagal.');
    }
    final json = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
    return json;
  }

  static void _addUint32(BytesBuilder b, int v) {
    b.addByte((v >> 24) & 0xff);
    b.addByte((v >> 16) & 0xff);
    b.addByte((v >> 8) & 0xff);
    b.addByte(v & 0xff);
  }

  static int _readUint32(Uint8List d, int off) =>
      (d[off] << 24) | (d[off + 1] << 16) | (d[off + 2] << 8) | d[off + 3];
}

/// Error untuk operasi [ConfigVault]. Pesan aman ditampilkan ke pengguna
/// (tidak membocorkan kunci atau struktur internal).
class ConfigVaultException implements Exception {
  const ConfigVaultException(this.message);
  final String message;
  @override
  String toString() => 'ConfigVaultException: $message';
}
