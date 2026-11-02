import 'dart:async';
import 'dart:io';

import '../audit/audit_logger.dart';
import '../policy/permissions.dart';
import '../policy/policy_engine.dart';
import 'quickjs_sandbox.dart';
import 'skill_manifest.dart';
import 'skill_store.dart';

/// Hasil menjalankan sebuah skill.
class SkillRunResult {
  const SkillRunResult({
    required this.name,
    required this.success,
    required this.output,
    this.error,
    this.needsConfirmation = false,
  });

  final String name;
  final bool success;
  final String output;
  final String? error;
  final bool needsConfirmation;

  factory SkillRunResult.ok(String name, String output) =>
      SkillRunResult(name: name, success: true, output: output);

  factory SkillRunResult.fail(String name, String error) =>
      SkillRunResult(name: name, success: false, output: error, error: error);

  factory SkillRunResult.confirm(String name) => SkillRunResult(
      name: name,
      success: false,
      output: 'Perlu konfirmasi.',
      needsConfirmation: true);
}

/// Membangun [SandboxHost] untuk sebuah skill (injeksi agar testable).
typedef SandboxHostBuilder = SandboxHost Function(
    SkillManifest manifest, AuditLogger audit);

/// Menjalankan skill (blueprint 9.1) sesuai manifest-nya.
///
/// Eksekusi script selalu melalui PolicyEngine dan AuditLogger (S-22).
/// Skill berisiko tinggi butuh konfirmasi pengguna (fail-closed).
class SkillRunner {
  SkillRunner({
    required this.store,
    required this.policy,
    required this.audit,
    required this.granted,
    SandboxHostBuilder? hostBuilder,
  }) : _hostBuilder = hostBuilder;

  final SkillStore store;
  final PolicyEngine policy;
  final AuditLogger audit;

  /// Izin yang sudah disetujui pengguna untuk skill ini (S-31).
  final Set<Permission> granted;

  final SandboxHostBuilder? _hostBuilder;

  /// Jalankan skill: SKILL.md menjadi instruksi agent, scripts/ (bila
  /// ada) dieksekusi di sandbox QuickJS (S-20/21/25).
  Future<SkillRunResult> run(
    String name, {
    bool confirm = false,
  }) async {
    final manifest = await store.readManifest(name);
    if (manifest == null) {
      return SkillRunResult.fail(name, 'Skill "$name" tidak ditemukan.');
    }

    final scripts = await store.listScripts(name);
    if (scripts.isEmpty) {
      // Skill murni deklaratif: SKILL.md diumpan ke agent loop sebagai
      // data (S-33), bukan dieksekusi sebagai kode.
      final instructions = await store.readInstructions(name);
      if (instructions == null) {
        return SkillRunResult.fail(name, 'Skill tidak punya SKILL.md.');
      }
      await audit.log(
        taskId: 'skill:$name',
        event: 'run',
        tool: 'skill',
        result: 'declarative',
      );
      return SkillRunResult.ok(name, instructions);
    }

    // Cek policy sebelum eksekusi script (fail-closed, S-22).
    final decision = policy.evaluate(
      tool: _specFor(manifest, name),
      args: const {},
      granted: granted,
      allowedHosts: manifest.permissions.network.toSet(),
    );
    if (decision.needsConfirmation && !confirm) {
      await audit.log(
        taskId: 'skill:$name',
        event: 'policy',
        tool: 'skill',
        decision: 'needs_confirmation',
        result: decision.reason,
      );
      return SkillRunResult.confirm(name);
    }
    if (!decision.allowed) {
      await audit.log(
        taskId: 'skill:$name',
        event: 'policy',
        tool: 'skill',
        decision: 'denied',
        result: decision.reason,
      );
      return SkillRunResult.fail(name, decision.reason);
    }

    // Jalankan setiap script di sandbox segar (S-21: 10 dtk, buang).
    final outputs = <String>[];
    for (final scriptName in scripts) {
      final f = File('${store.dirFor(name).path}/scripts/$scriptName');
      final code = await f.readAsString();
      final sandbox = QuickJsSandbox();
      try {
        final builder = _hostBuilder;
        if (builder != null) {
          sandbox.host = builder(manifest, audit);
        }
        final res = await sandbox.run(code);
        if (!res.success) {
          await audit.log(
            taskId: 'skill:$name',
            event: 'run',
            tool: 'skill',
            result: 'script $scriptName gagal: ${res.error}',
          );
          return SkillRunResult.fail(name, 'Script $scriptName: ${res.error}');
        }
        outputs.add('$scriptName: ${res.output}');
      } finally {
        sandbox.dispose();
      }
    }

    await audit.log(
      taskId: 'skill:$name',
      event: 'run',
      tool: 'skill',
      result: 'ok (${scripts.length} script)',
    );
    return SkillRunResult.ok(name, outputs.join('\n'));
  }
}

/// Helper: bangun ToolSpec dari manifest (S-22: setiap eksekusi
/// melewati PolicyEngine).
ToolSpec _specFor(SkillManifest m, String name) {
  final perms = <Permission>[];
  if (m.permissions.network.isNotEmpty) perms.add(Permission.network);
  if (m.permissions.notify) perms.add(Permission.notify);
  if (m.permissions.files == SkillFileAccess.sandbox) {
    perms.add(Permission.files);
  }
  return ToolSpec(
    name: 'skill:$name',
    description: m.description,
    inputSchema: const {},
    risk: _riskFor(m),
    permissions: perms,
    timeoutMs: 10000,
  );
}

RiskLevel _riskFor(SkillManifest m) {
  switch (m.risk) {
    case SkillRisk.low:
      return RiskLevel.low;
    case SkillRisk.medium:
      return RiskLevel.medium;
    case SkillRisk.high:
      return RiskLevel.high;
  }
}
