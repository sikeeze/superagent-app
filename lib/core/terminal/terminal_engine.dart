import 'dart:async';

import '../audit/audit_logger.dart';
import '../security/redactor.dart';
import '../skills/skill_runner.dart';
import '../skills/skill_store.dart';
import 'command_parser.dart';

/// Satu baris output terminal.
class TerminalLine {
  const TerminalLine({required this.text, this.kind = LineKind.output});

  final String text;
  final LineKind kind;
}

enum LineKind { input, output, error, warn }

/// Hasil eksekusi command.
class CommandResult {
  const CommandResult({required this.lines, this.clear = false});
  final List<TerminalLine> lines;
  final bool clear;
}

/// Terminal virtual (blueprint 9.2/9.3).
///
/// - S-23: perintah diimplementasikan dalam app, bukan shell sistem.
/// - S-22: setiap perintah melalui AuditLogger (riwayat tak simpan
///   argumen rahasia — S-06/9.3, dipakaikan Redactor).
/// - S-24: perintah destruktif butuh konfirmasi.
/// - Buffer layar dibatasi 2000 baris (9.3).
class TerminalEngine {
  TerminalEngine({
    required this.store,
    required this.audit,
    required this.runner,
    this.maxLines = 2000,
  });

  final SkillStore store;
  final AuditLogger audit;
  final SkillRunner runner;
  final int maxLines;

  /// Daftar command virtual yang didukung (S-23).
  static const commands = <String>[
    'help',
    'skill',
    'config',
    'logs',
    'clear',
  ];

  /// Eksekusi satu baris input.
  Future<CommandResult> execute(String raw) async {
    final parsed = parseCommand(raw);
    if (parsed == null) {
      return const CommandResult(lines: []);
    }

    // 9.3: riwayat tak simpan argumen rahasia.
    final safe = Redactor.redact(raw);
    await audit.log(
      taskId: 'terminal',
      event: 'command',
      tool: 'terminal',
      args: {'command': safe},
    );

    switch (parsed.name) {
      case 'help':
        return _help();
      case 'clear':
        return const CommandResult(lines: [], clear: true);
      case 'skill':
        return _skill(parsed);
      case 'config':
        return _config(parsed);
      case 'logs':
        return _logs(parsed);
      default:
        return CommandResult(lines: [
          TerminalLine(
              text: 'Perintah tidak dikenal: ${parsed.name}. Ketik "help".',
              kind: LineKind.error),
        ]);
    }
  }

  CommandResult _help() => const CommandResult(lines: [
        TerminalLine(text: 'Perintah terminal virtual Superagent:'),
        TerminalLine(text: '  help                     Daftar perintah'),
        TerminalLine(text: '  skill list               Daftar skill terpasang'),
        TerminalLine(
            text: '  skill install <url|path> Impor skill (tinjau izin)'),
        TerminalLine(text: '  skill remove <nama>      Hapus skill'),
        TerminalLine(text: '  skill inspect <nama>     Tampilkan isi & izin'),
        TerminalLine(text: '  skill run <nama>         Jalankan skill'),
        TerminalLine(text: '  config get <kunci>       Baca pengaturan'),
        TerminalLine(text: '  config set <kunci> <nilai> Ubah pengaturan'),
        TerminalLine(text: '  logs [n]                 Log terakhir'),
        TerminalLine(text: '  clear                    Bersihkan layar'),
      ]);

  Future<CommandResult> _skill(ParsedCommand p) async {
    final sub = p.sub;
    switch (sub) {
      case 'list':
        final names = await store.listNames();
        if (names.isEmpty) {
          return const CommandResult(
              lines: [TerminalLine(text: 'Tidak ada skill terpasang.')]);
        }
        return CommandResult(
          lines: names
              .map((n) => TerminalLine(text: '  $n'))
              .toList(growable: false),
        );

      case 'inspect':
        final name = p.rest.firstOrNull;
        if (name == null) {
          return _usage('skill inspect <nama>');
        }
        final m = await store.readManifest(name);
        if (m == null) {
          return CommandResult(lines: [
            TerminalLine(text: 'Skill "$name" tidak ada.', kind: LineKind.error),
          ]);
        }
        return CommandResult(lines: [
          TerminalLine(text: 'name: ${m.name}'),
          TerminalLine(text: 'version: ${m.version}'),
          TerminalLine(text: 'description: ${m.description}'),
          TerminalLine(
              text: 'risk: ${m.risk.name}'),
          TerminalLine(
              text: 'network: ${m.permissions.network.isEmpty ? "none" : m.permissions.network.join(", ")}'),
          TerminalLine(text: 'notify: ${m.permissions.notify}'),
          TerminalLine(text: 'files: ${m.permissions.files.name}'),
          TerminalLine(text: 'sha256: ${m.sha256 ?? "-"}'),
        ]);

      case 'remove':
        final name = p.rest.firstOrNull;
        if (name == null) return _usage('skill remove <nama>');
        // S-24: penghapusan butuh konfirmasi; kami minta via prompt
        // kedua (lihat UI: ketik ulang untuk konfirmasi).
        final removed = await store.remove(name);
        return CommandResult(lines: [
          TerminalLine(
            text: removed
                ? 'Skill "$name" dihapus.'
                : 'Skill "$name" tidak ada.',
            kind: removed ? LineKind.output : LineKind.warn,
          ),
        ]);

      case 'run':
        final name = p.rest.firstOrNull;
        if (name == null) return _usage('skill run <nama>');
        final res = await runner.run(name);
        if (res.needsConfirmation) {
          return CommandResult(lines: [
            TerminalLine(
                text: 'Skill "$name" berisiko tinggi. '
                    'Jalankan dari halaman Skills dengan konfirmasi.',
                kind: LineKind.warn),
          ]);
        }
        return CommandResult(lines: [
          TerminalLine(
            text: res.success
                ? (res.output.length > 500
                    ? '${res.output.substring(0, 500)}…'
                    : res.output)
                : (res.error ?? 'Gagal.'),
            kind: res.success ? LineKind.output : LineKind.error,
          ),
        ]);

      case 'install':
        // Impor skill butuh tinjauan izin (S-31) — di Fase 5 ini menerima
        // path folder lokal; URL unduhan butuh jaringan (belumsafe).
        return const CommandResult(lines: [
          TerminalLine(
              text: 'skill install: impor dari path/URL belum tersedia. '
                  'Salin folder skill ke folder skills/ secara manual.',
              kind: LineKind.warn),
        ]);

      default:
        return _usage('skill list|install|remove|inspect|run');
    }
  }

  Future<CommandResult> _config(ParsedCommand p) async {
    final sub = p.sub;
    if (sub == 'get') {
      final key = p.rest.firstOrNull ?? '';
      return CommandResult(lines: [
        TerminalLine(text: '$key = ${_configValue(key)}'),
      ]);
    }
    if (sub == 'set') {
      final key = p.rest.firstOrNull;
      final value = p.rest.skip(1).join(' ');
      if (key == null || key.isEmpty) {
        return _usage('config set <kunci> <nilai>');
      }
      // Hanya pengaturan non-rahasia (9.2). Kunci yang mengandung
      // pola rahasia ditolak.
      if (_looksSecret(key)) {
        return CommandResult(lines: [
          TerminalLine(
              text: 'Kunci pengaturan terlihat seperti rahasia. Ditolak.',
              kind: LineKind.error),
        ]);
      }
      _configValues[key] = value;
      return CommandResult(lines: [
        TerminalLine(text: '$key = $value'),
      ]);
    }
    return _usage('config get|set <kunci> [nilai]');
  }

  /// Penyimpanan config non-rahasia in-memory (sesi ini). Persistensi
  /// ke SharedPreferences di luar cakupan Fase 5 minimal.
  final Map<String, String> _configValues = {};

  String _configValue(String key) {
    switch (key) {
      case 'terminal.buffer':
        return '$maxLines';
      case 'skills.path':
        return store.rootDir.path;
      default:
        return _configValues[key] ?? '';
    }
  }

  bool _looksSecret(String key) {
    final k = key.toLowerCase();
    return k.contains('key') ||
        k.contains('secret') ||
        k.contains('token') ||
        k.contains('password') ||
        k.contains('seed');
  }

  Future<CommandResult> _logs(ParsedCommand p) async {
    final n = int.tryParse(p.sub ?? '') ?? 20;
    final entries = await audit.tail(limit: n);
    if (entries.isEmpty) {
      return const CommandResult(lines: [TerminalLine(text: 'Log kosong.')]);
    }
    return CommandResult(
      lines: entries.reversed
          .map((e) => TerminalLine(
              text: '${e.timestamp.toIso8601String().substring(11, 19)} '
                  '${e.event}: ${e.tool ?? "-"}'))
          .toList(growable: false),
    );
  }

  CommandResult _usage(String usage) => CommandResult(lines: [
        TerminalLine(text: 'Penggunaan: $usage', kind: LineKind.warn),
      ]);
}
