import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audit/audit_logger.dart';
import '../../core/policy/permissions.dart';
import '../../core/policy/policy_engine.dart';
import '../../core/skills/skill_manifest.dart';
import '../../core/skills/skill_runner.dart';
import '../../core/skills/skill_store.dart';
import 'skills_providers.dart';

/// Halaman daftar skill (blueprint 9.1). Semua eksekusi melalui
/// PolicyEngine + AuditLogger (S-22).
class SkillsPage extends ConsumerWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillListProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Skills')),
      body: skills.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.extension_outlined,
                        size: 64, color: colors.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text('Belum ada skill terpasang',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Skill adalah unit deklaratif: SKILL.md + manifest.json '
                      '+ script sandbox. Pasang lewat terminal: '
                      'skill install <path>',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }
          // P-01: ListView.builder untuk daftar.
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = list[i];
              return ListTile(
                leading: Icon(_riskIcon(m.risk),
                    color: _riskColor(m.risk, colors)),
                title: Text(m.name),
                subtitle: Text(m.description, maxLines: 2),
                trailing: _PermChips(permissions: m.permissions),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _SkillDetailPage(manifest: m),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _riskIcon(SkillRisk r) => switch (r) {
        SkillRisk.low => Icons.check_circle_outline,
        SkillRisk.medium => Icons.warning_amber_outlined,
        SkillRisk.high => Icons.dangerous_outlined,
      };

  Color _riskColor(SkillRisk r, ColorScheme c) => switch (r) {
        SkillRisk.low => Colors.green,
        SkillRisk.medium => Colors.orange,
        SkillRisk.high => c.error,
      };
}

class _PermChips extends StatelessWidget {
  const _PermChips({required this.permissions});
  final SkillPermissions permissions;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (permissions.network.isNotEmpty) {
      chips.add(const Chip(
          avatar: Icon(Icons.cloud_outlined, size: 16),
          label: Text('network')));
    }
    if (permissions.notify) {
      chips.add(const Chip(
          avatar: Icon(Icons.notifications_outlined, size: 16),
          label: Text('notify')));
    }
    if (permissions.files == SkillFileAccess.sandbox) {
      chips.add(const Chip(
          avatar: Icon(Icons.folder_outlined, size: 16),
          label: Text('sandbox')));
    }
    if (chips.isEmpty) {
      chips.add(const Chip(
          avatar: Icon(Icons.description_outlined, size: 16),
          label: Text('deklaratif')));
    }
    return Wrap(spacing: 4, children: chips);
  }
}

class _SkillDetailPage extends ConsumerStatefulWidget {
  const _SkillDetailPage({required this.manifest});
  final SkillManifest manifest;

  @override
  ConsumerState<_SkillDetailPage> createState() => _SkillDetailPageState();
}

class _SkillDetailPageState extends ConsumerState<_SkillDetailPage> {
  bool _running = false;
  String? _output;
  String? _error;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _output = null;
      _error = null;
    });
    final store = await ref.read(skillStoreProvider.future);
    final result = await _runSkill(store, widget.manifest.name);
    if (!mounted) return;
    setState(() {
      _running = false;
      if (result.success) {
        _output = result.output;
      } else if (result.needsConfirmation) {
        _error = 'Skill ini berisiko ${widget.manifest.risk.name}: '
            'perlu konfirmasi. Jalankan dengan konfirmasi dari terminal.';
      } else {
        _error = result.error ?? 'Gagal.';
      }
    });
  }

  Future<SkillRunResult> _runSkill(SkillStore store, String name) async {
    final m = widget.manifest;
    final policy = PolicyEngine();
    final audit = AuditLogger(await _auditPath());
    final runner = SkillRunner(
      store: store,
      policy: policy,
      audit: audit,
      granted: _grantedFor(m),
    );
    return runner.run(name, confirm: false);
  }

  Future<String> _auditPath() async {
    final dir = await skillsRoot();
    return '${dir.parent.path}${Platform.pathSeparator}audit.log';
  }

  Set<Permission> _grantedFor(SkillManifest m) {
    final s = <Permission>{};
    if (m.permissions.network.isNotEmpty) s.add(Permission.network);
    if (m.permissions.notify) s.add(Permission.notify);
    if (m.permissions.files == SkillFileAccess.sandbox) s.add(Permission.files);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.manifest;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(m.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('v${m.version} · risiko ${m.risk.name}',
              style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(m.description),
          const SizedBox(height: 16),
          Text('Izin', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _PermChips(permissions: m.permissions),
          if (m.permissions.network.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Domain: ${m.permissions.network.join(', ')}',
                style: TextStyle(color: colors.onSurfaceVariant)),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _running ? null : _run,
            icon: _running
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.play_arrow_rounded),
            label: Text(_running ? 'Menjalankan...' : 'Jalankan skill'),
          ),
          if (_output != null) ...[
            const SizedBox(height: 16),
            Text('Hasil', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _output!.length > 2000
                    ? '${_output!.substring(0, 2000)}…'
                    : _output!,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: colors.error)),
          ],
        ],
      ),
    );
  }
}
