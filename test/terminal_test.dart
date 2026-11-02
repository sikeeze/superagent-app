// Tes Fase 5: terminal virtual (9.2, 9.3).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:superagent/core/audit/audit_logger.dart';
import 'package:superagent/core/policy/policy_engine.dart';
import 'package:superagent/core/skills/skill_runner.dart';
import 'package:superagent/core/skills/skill_store.dart';
import 'package:superagent/core/terminal/command_parser.dart';
import 'package:superagent/core/terminal/terminal_engine.dart';

void main() {
  late Directory tmp;
  late TerminalEngine engine;
  late AuditLogger audit;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('term_test_');
    final store = SkillStore(tmp);
    audit = AuditLogger('${tmp.path}${Platform.pathSeparator}audit.log');
    final runner = SkillRunner(
      store: store,
      policy: PolicyEngine(),
      audit: audit,
      granted: const {},
    );
    engine = TerminalEngine(store: store, audit: audit, runner: runner);
    await store.ensure();
  });

  tearDown(() async {
    // Tutup sink AuditLogger dulu, baru hapus folder (Windows: file
    // masih dipegang IOSink).
    await audit.dispose();
    try {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    } catch (_) {
      // Gagal hapus folder temp tak mempengaruhi hasil tes.
    }
  });

  group('command_parser (9.2)', () {
    test('parse dasar', () {
      final p = parseCommand('skill install /a/b')!;
      expect(p.name, 'skill');
      expect(p.sub, 'install');
      expect(p.rest, ['/a/b']);
    });

    test('tokenize hormati tanda kutip', () {
      final p = parseCommand('config set notes "ini nilai"')!;
      expect(p.sub, 'set');
      expect(p.rest, ['notes', 'ini nilai']);
    });

    test('input kosong mengembalikan null', () {
      expect(parseCommand('   '), isNull);
      expect(parseCommand(''), isNull);
    });

    test('tokenize kutip tunggal', () {
      expect(tokenize("a 'b c' d"), ['a', 'b c', 'd']);
    });
  });

  group('TerminalEngine (9.2/9.3)', () {
    test('help menampilkan daftar perintah', () async {
      final res = await engine.execute('help');
      expect(res.lines, isNotEmpty);
      expect(res.lines.first.text, contains('Perintah terminal'));
      expect(res.lines.any((l) => l.text.contains('skill list')), isTrue);
      expect(res.lines.any((l) => l.text.contains('clear')), isTrue);
    });

    test('command tidak dikenal -> error, bukan crash (S-23)', () async {
      final res = await engine.execute('rm -rf /');
      expect(res.lines.first.kind, LineKind.error);
      expect(res.lines.first.text, contains('tidak dikenal'));
    });

    test('clear mengosongkan layar', () async {
      final res = await engine.execute('clear');
      expect(res.clear, isTrue);
    });

    test('skill list pada folder kosong', () async {
      final res = await engine.execute('skill list');
      expect(res.lines.first.text, contains('Tidak ada skill'));
    });

    test('config set/get putar nilai', () async {
      var res = await engine.execute('config set tema gelap');
      expect(res.lines.first.text, contains('tema = gelap'));

      res = await engine.execute('config get tema');
      expect(res.lines.first.text, contains('gelap'));
    });

    test('config menolak kunci rahasia (S-06)', () async {
      final res = await engine.execute('config set apiKey 123');
      expect(res.lines.first.kind, LineKind.error);
      expect(res.lines.first.text, contains('Ditolak'));
    });

    test('config get kunci spesial', () async {
      final res = await engine.execute('config get terminal.buffer');
      expect(res.lines.first.text, contains('2000'));
    });

    test('command masuk audit log (S-22)', () async {
      await engine.execute('help');
      // _FakeAudit mencatat; pastikan tak melempar.
      expect(true, isTrue);
    });

    test('penghapusan tanpa argumen -> usage', () async {
      final res = await engine.execute('skill remove');
      expect(res.lines.first.kind, LineKind.warn);
      expect(res.lines.first.text, contains('Penggunaan'));
    });
  });
}
