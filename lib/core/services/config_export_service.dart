import 'dart:io';

import '../security/config_vault.dart';
import '../security/secure_store.dart';

/// Mengatur ekspor dan impor konfigurasi (S-04).
///
/// Yang diekspor: profil provider (metadata + API key yang tersimpan di
/// secure storage). Tidak ada data percakapan (terlalu besar dan ada di DB),
/// dan tidak ada kunci privat (Fase 7: tidak pernah disimpan app).
///
/// **S-02:** passphrase diminta dari pengguna; file hasil ekspor wajib
///.disimpan di luar repositori.
class ConfigExportService {
  ConfigExportService(this._secure);

  final SecureStore _secure;

  /// Bangun payload mentah (metadata + api keys). Testable tanpa IO.
  Future<Map<String, dynamic>> buildPayload() async {
    final json = await _secure.readJson('provider.profiles');
    final profiles =
        (json?['profiles'] as List? ?? <dynamic>[]).whereType<Map<String, dynamic>>().toList();
    final activeId = json?['active_id'] as String?;
    final apiKeys = <String, dynamic>{};
    for (final p in profiles) {
      final id = p['id'] as String?;
      if (id == null) continue;
      final key = await _secure.read('llm.apikey.$id');
      if (key != null && key.isNotEmpty) apiKeys[id] = key;
    }
    return <String, dynamic>{
      'version': 1,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'active_id': activeId,
      'profiles': profiles,
      'api_keys': apiKeys,
    };
  }

  /// Ekspor konfigurasi ke file terenkripsi. [path] harus di luar repo.
  /// Melempar [ConfigVaultException] bila passphrase lemah.
  Future<void> exportToFile(String path, String passphrase) async {
    final payload = await buildPayload();
    final enc = await ConfigVault.encrypt(payload, passphrase);
    final f = File(path);
    await f.writeAsBytes(enc);
  }

  /// Impor konfigurasi dari file terenkripsi. Menimpa profil yang ada
  /// dengan id yang sama (upsert) dan menulis API key ke secure storage.
  Future<int> importFromFile(String path, String passphrase) async {
    final bytes = await File(path).readAsBytes();
    final payload = await ConfigVault.decrypt(bytes, passphrase);
    final profiles =
        (payload['profiles'] as List? ?? <dynamic>[]).whereType<Map<String, dynamic>>().toList();
    final apiKeys = (payload['api_keys'] as Map? ?? <dynamic, dynamic>{})
        .cast<String, dynamic>();
    final activeId = payload['active_id'] as String?;

    int restored = 0;
    for (final p in profiles) {
      final id = p['id'] as String?;
      if (id == null) continue;
      final key = apiKeys[id] as String?;
      if (key != null && key.isNotEmpty) {
        await _secure.write('llm.apikey.$id', key);
      }
      restored++;
    }

    // Timpa metadata profil yang ada.
    final existing = await _secure.readJson('provider.profiles');
    final existingList =
        (existing?['profiles'] as List? ?? <dynamic>[]).whereType<Map<String, dynamic>>().toList();
    final byId = <String, Map<String, dynamic>>{};
    for (final e in existingList) {
      final id = e['id'] as String?;
      if (id != null) byId[id] = e;
    }
    for (final p in profiles) {
      final id = p['id'] as String?;
      if (id != null) byId[id] = p;
    }
    await _secure.writeJson('provider.profiles', <String, dynamic>{
      'profiles': byId.values.toList(),
      'active_id': activeId,
    });
    return restored;
  }
}
