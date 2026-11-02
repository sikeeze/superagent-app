import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/audit/audit_logger.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/tasks/task_scheduler.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/task_repository.dart';

/// Database app (Fase 2). Dipakai bersama oleh scheduler & UI.
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Repository task (blueprint 5.4).
final taskRepositoryProvider = FutureProvider<TaskRepository>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return TaskRepository(db);
});

/// AuditLogger instance app (file di app data dir, S-01 compliant).
final auditLoggerProvider = FutureProvider<AuditLogger>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return AuditLogger('${dir.path}${Platform.pathSeparator}audit.log');
});

/// State daftar task (5.4).
class TaskListState {
  const TaskListState({this.tasks = const [], this.loading = false});
  final List<Task> tasks;
  final bool loading;
  TaskListState copyWith({List<Task>? tasks, bool? loading}) =>
      TaskListState(
        tasks: tasks ?? this.tasks,
        loading: loading ?? this.loading,
      );
}

/// Scheduler + notifikasi (5.4/5.5). Timer tunggal (P-08), maks 2 paralel.
class TaskNotifier extends StateNotifier<TaskListState> {
  TaskNotifier(this._repo, this._audit) : super(const TaskListState()) {
    _scheduler = TaskScheduler(
      repo: _repo,
      audit: _audit,
      runner: _TaskRun(_audit),
    );
  }

  final TaskRepository _repo;
  final AuditLogger _audit;
  late final TaskScheduler _scheduler;
  StreamSubscription? _sub;
  final _notified = <int>{};

  Future<void> init() async {
    state = state.copyWith(loading: true);
    try {
      await NotificationService.instance.init();
    } catch (_) {
      // Windows/Android tanpa permission: notifikasi skip, task tetap jalan.
    }
    await _scheduler.start();
    _sub = _repo.watchAll().listen(_onData);
    final rows = await _repo.all();
    state = TaskListState(tasks: rows);
  }

  void _onData(List<Task> rows) {
    for (final t in rows) {
      if (t.status == 'done' && !_notified.contains(t.id)) {
        _notified.add(t.id);
        NotificationService.instance.notifyTaskDone(t.id, t.title);
      } else if (t.status == 'failed' && !_notified.contains(t.id)) {
        _notified.add(t.id);
        NotificationService.instance.notifyTaskFailed(
            t.id, t.title, t.lastError ?? 'Eksekusi gagal');
      }
    }
    state = TaskListState(tasks: rows);
  }

  Future<int> createTask({
    required String title,
    required String prompt,
    String? skill,
    String kind = 'once',
    int? intervalSec,
    String? cronExpr,
    DateTime? nextRunAt,
  }) {
    return _repo.create(
      title: title,
      prompt: prompt,
      skill: skill,
      kind: kind,
      intervalSec: intervalSec,
      cronExpr: cronExpr,
      nextRunAt: nextRunAt,
    );
  }

  Future<void> cancelTask(int id) => _repo.updateStatus(id, 'cancelled');

  Future<void> removeTask(int id) => _repo.remove(id);

  /// Jalankan sekarang (atur nextRunAt = sekarang).
  Future<void> runNow(int id) => _repo.scheduleNext(id, DateTime.now());

  @override
  void dispose() {
    _sub?.cancel();
    _scheduler.dispose();
    super.dispose();
  }
}

/// Eksekusi task: jalankan skill bila ada; bila tidak catat prompt.
/// Integrasi penuh dengan agent loop menyusul di Fase 8.
class _TaskRun extends TaskRunner {
  _TaskRun(super.audit);

  @override
  Future<bool> onRun(Task t) async {
    await auditLogger.log(
      taskId: 'task:${t.id}',
      event: 'run',
      tool: t.skill == null ? 'prompt' : 'skill:${t.skill}',
      result: 'mulai: [REDACTED]',
    );
    return true;
  }
}

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, TaskListState>((ref) {
  throw UnimplementedError('override di main()');
});
