import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;

import 'skill_manifest.dart';

/// Penyimpanan skill di sistem file perangkat (blueprint 9.1).
///
/// Layout (di dalam folder data aplikasi):
/// ```
/// skills/
///   <nama>/
///     SKILL.md
///     manifest.json
///     scripts/*.js   (opsional)
/// ```
///
/// - S-30: skill luar dianggap tidak tepercaya sampai pengguna meninjau.
/// - S-32: SHA-256 seluruh isi; perubahan setelah disetujui memicu
///   persetujuan ulang.
class SkillStore {
  SkillStore(this.rootDir);

  final Directory rootDir;

  /// Pastikan folder root ada.
  Future<void> ensure() async {
    if (!await rootDir.exists()) {
      await rootDir.create(recursive: true);
    }
  }

  /// Lokasi folder satu skill.
  Directory dirFor(String name) => Directory('${rootDir.path}/$name');

  /// Daftar nama skill yang terpasang.
  Future<List<String>> listNames() async {
    await ensure();
    final names = <String>[];
    await for (final entry in rootDir.list()) {
      if (entry is Directory) {
        final manifestFile = File('${entry.path}/manifest.json');
        if (await manifestFile.exists()) {
          names.add(entry.path.split(Platform.pathSeparator).last);
        }
      }
    }
    return names..sort();
  }

  /// Baca manifest satu skill. null jika tidak terpasang.
  Future<SkillManifest?> readManifest(String name) async {
    final f = File('${dirFor(name).path}/manifest.json');
    if (!await f.exists()) return null;
    try {
      return parseSkillManifest(await f.readAsString());
    } catch (_) {
      // Manifest rusak = skill tak bisa dipakai (fail-closed, S-30).
      return null;
    }
  }

  /// Baca instruksi SKILL.md.
  Future<String?> readInstructions(String name) async {
    final f = File('${dirFor(name).path}/SKILL.md');
    if (!await f.exists()) return null;
    return f.readAsString();
  }

  /// Daftar script JS di folder scripts/.
  Future<List<String>> listScripts(String name) async {
    final d = Directory('${dirFor(name).path}/scripts');
    if (!await d.exists()) return const [];
    final scripts = <String>[];
    await for (final entry in d.list()) {
      if (entry is File && entry.path.endsWith('.js')) {
        scripts.add(entry.uri.pathSegments.last);
      }
    }
    return scripts..sort();
  }

  /// Tulis skill lengkap (impor). [sha256] dihitung oleh pemanggil dari
  /// seluruh isi sebelum ditulis (S-32).
  Future<void> write(String name, {
    required String instructions,
    required Map<String, dynamic> manifestJson,
    Map<String, String> scripts = const {},
  }) async {
    await ensure();
    final d = dirFor(name);
    if (await d.exists()) {
      await d.delete(recursive: true);
    }
    await d.create(recursive: true);
    await File('${d.path}/SKILL.md').writeAsString(instructions);
    await File('${d.path}/manifest.json')
        .writeAsString(const JsonEncoder.withIndent('  ').convert(manifestJson));
    if (scripts.isNotEmpty) {
      final sd = Directory('${d.path}/scripts');
      await sd.create(recursive: true);
      for (final entry in scripts.entries) {
        await File('${sd.path}/${entry.key}').writeAsString(entry.value);
      }
    }
  }

  /// Hapus skill.
  Future<bool> remove(String name) async {
    final d = dirFor(name);
    if (!await d.exists()) return false;
    await d.delete(recursive: true);
    return true;
  }

  /// SHA-256 seluruh isi skill (S-32): digabung per file (urutan
  /// deterministik) lalu dihash.
  Future<String> hashContents(String name) async {
    final d = dirFor(name);
    if (!await d.exists()) return '';
    final sink = StringBuffer();
    final files = <File>[];
    await for (final entry in d.list(recursive: true)) {
      if (entry is File) files.add(entry);
    }
    files.sort((a, b) => a.path.compareTo(b.path));
    for (final f in files) {
      sink.write(f.uri.pathSegments.last);
      sink.write('\u0000');
      sink.write(await f.readAsString());
      sink.write('\u0000');
    }
    return _sha256Hex(sink.toString());
  }
}
/// Hitung SHA-256 heksadesimal sebuah string (S-32).
/// crypto adalah paket resmi dart.dev (sudak dependensi transitif).
String _sha256Hex(String input) {
  return crypto.sha256.convert(input.codeUnits).toString();
}
