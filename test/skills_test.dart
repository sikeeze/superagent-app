// Tes Fase 4: skill system — manifest, store, sandbox QuickJS.
// Blueprint 9.1 kriteria: "Manifest izin ditegakkan, uji sandbox
// escape gagal".
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:superagent/core/skills/skill_manifest.dart';
import 'package:superagent/core/skills/skill_store.dart';

void main() {
  late Directory tmp;
  late SkillStore store;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('skill_test_');
    store = SkillStore(tmp);
    await store.ensure();
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  group('SkillManifest (9.1)', () {
    test('parse manifest lengkap', () {
      const raw = '''
{
  "name": "web-research",
  "version": "1.0.0",
  "description": "Riset web ringkas",
  "permissions": {"network": ["api.example.com"], "notify": true, "files": "sandbox"},
  "risk": "medium"
}
''';
      final m = parseSkillManifest(raw);
      expect(m.name, 'web-research');
      expect(m.version, '1.0.0');
      expect(m.permissions.network, ['api.example.com']);
      expect(m.permissions.notify, isTrue);
      expect(m.permissions.files, SkillFileAccess.sandbox);
      expect(m.risk, SkillRisk.medium);
    });

    test('fail-closed: manifest tanpa name ditolak', () {
      const raw = '{"version": "1.0.0", "description": "x", "risk": "low"}';
      expect(() => parseSkillManifest(raw),
          throwsA(isA<SkillManifestException>()));
    });

    test('fail-closed: risk tidak valid ditolak', () {
      const raw = '''
{"name": "a", "version": "1", "description": "x", "permissions": {}, "risk": "extreme"}
''';
      expect(() => parseSkillManifest(raw),
          throwsA(isA<SkillManifestException>()));
    });

    test('default: network kosong (S-12 tolak semua sampai disetujui)', () {
      const raw = '''
{"name": "a", "version": "1", "description": "x", "permissions": {}, "risk": "low"}
''';
      final m = parseSkillManifest(raw);
      expect(m.permissions.network, isEmpty);
      expect(m.permissions.notify, isFalse);
      expect(m.permissions.files, SkillFileAccess.none);
    });
  });

  group('SkillStore (9.1)', () {
    test('tulis, daftar, baca, hapus skill', () async {
      await store.write(
        'my-skill',
        instructions: '# My Skill\nLakukan X.',
        manifestJson: {
          'name': 'my-skill',
          'version': '1.0.0',
          'description': 'Tes',
          'permissions': {'network': [], 'notify': false, 'files': 'none'},
          'risk': 'low',
        },
        scripts: {'main.js': '1 + 1'},
      );

      expect(await store.listNames(), ['my-skill']);
      expect((await store.readManifest('my-skill'))!.name, 'my-skill');
      expect(await store.readInstructions('my-skill'), contains('Lakukan X'));
      expect(await store.listScripts('my-skill'), ['main.js']);

      // Mutakhir: skill kedua muncul terurut.
      await store.write('aaa', instructions: 'x', manifestJson: {
        'name': 'aaa',
        'version': '1.0.0',
        'description': 'x',
        'permissions': {},
        'risk': 'low',
      });
      expect(await store.listNames(), ['aaa', 'my-skill']);

      expect(await store.remove('my-skill'), isTrue);
      expect(await store.listNames(), ['aaa']);
    });

    test('hash isi stabil untuk isi sama (S-32)', () async {
      await store.write('h', instructions: 'sama', manifestJson: {
        'name': 'h',
        'version': '1.0.0',
        'description': 'x',
        'permissions': {},
        'risk': 'low',
      });
      final h1 = await store.hashContents('h');
      final h2 = await store.hashContents('h');
      expect(h1, h2);
      expect(h1.length, 64); // SHA-256 heksadesimal.

      // Ubah isi -> hash berubah (memicu persetujuan ulang, S-32).
      await store.write('h', instructions: 'BERBEDA', manifestJson: {
        'name': 'h',
        'version': '1.0.0',
        'description': 'x',
        'permissions': {},
        'risk': 'low',
      });
      expect(await store.hashContents('h'), isNot(h1));
    });

    test('manifest rusak -> null (fail-closed, S-30)', () async {
      await store.write('bad', instructions: 'x', manifestJson: {
        'name': 'bad',
        'version': '1.0.0',
        'description': 'x',
        'permissions': {},
        'risk': 'low',
      });
      // Corrupt manifest.
      final f = File('${store.dirFor('bad').path}/manifest.json');
      await f.writeAsString('{ not json');
      expect(await store.readManifest('bad'), isNull);
    });
  });
}
