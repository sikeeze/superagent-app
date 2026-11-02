import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_providers.dart';

/// Halaman daftar task terjadwal (blueprint 5.4).
class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  @override
  void initState() {
    super.initState();
    // init scheduler + notifikasi sekali saja.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskNotifierProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Task Terjadwal')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreate,
        icon: const Icon(Icons.add),
        label: const Text('Task Baru'),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.tasks.isEmpty
              ? Center(
                  child: Text(
                    'Belum ada task.\nTekan + untuk membuat jadwal.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: state.tasks.length,
                  itemBuilder: (ctx, i) {
                    final t = state.tasks[i];
                    return ListTile(
                      leading: _statusIcon(t.status),
                      title: Text(t.title),
                      subtitle: Text(
                        '${t.kind} · ${t.skill ?? "prompt"} · ${t.status}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) {
                          final notifier =
                              ref.read(taskNotifierProvider.notifier);
                          if (v == 'run') {
                            notifier.runNow(t.id);
                          } else if (v == 'cancel') {
                            notifier.cancelTask(t.id);
                          } else if (v == 'remove') {
                            notifier.removeTask(t.id);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'run', child: Text('Jalankan')),
                          PopupMenuItem(value: 'cancel', child: Text('Batal')),
                          PopupMenuItem(value: 'remove', child: Text('Hapus')),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _statusIcon(String status) {
    final icon = switch (status) {
      'running' => Icons.play_circle_outline,
      'done' => Icons.check_circle_outline,
      'failed' => Icons.error_outline,
      'cancelled' => Icons.cancel_outlined,
      _ => Icons.schedule_outlined,
    };
    return Icon(icon);
  }

  void _showCreate() {
    final titleCtrl = TextEditingController();
    final promptCtrl = TextEditingController();
    String kind = 'once';
    String schedule = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Task Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: promptCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Prompt',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: kind,
                      decoration: const InputDecoration(
                        labelText: 'Jadwal',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'once', child: Text('Sekali (segera)')),
                        DropdownMenuItem(
                            value: 'interval', child: Text('Interval')),
                        DropdownMenuItem(
                            value: 'cron', child: Text('Cron sederhana')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => kind = v);
                      },
                    ),
                    const SizedBox(height: 8),
                    if (kind == 'interval')
                      TextField(
                        onChanged: (v) => schedule = v,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Interval (detik)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    if (kind == 'cron')
                      TextField(
                        onChanged: (v) => schedule = v,
                        decoration: const InputDecoration(
                          labelText: 'Cron (menit jam hari)',
                          hintText: 'contoh: 30 6 *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () async {
                    final notifier = ref.read(taskNotifierProvider.notifier);
                    await notifier.createTask(
                      title: titleCtrl.text.isEmpty
                          ? 'Task'
                          : titleCtrl.text,
                      prompt: promptCtrl.text,
                      kind: kind,
                      intervalSec:
                          kind == 'interval' ? int.tryParse(schedule) : null,
                      cronExpr: kind == 'cron' ? schedule : null,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
