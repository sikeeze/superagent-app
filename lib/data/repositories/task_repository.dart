import 'dart:async';

import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/task_tables.dart';

/// Repository tabel [Tasks] (blueprint 5.4).
///
/// Task = prompt + skill + jadwal. Status berpindah:
/// pending -> running -> (waiting_confirmation) -> done | failed | cancelled.
/// Retensi log 30 hari (P-13) dipangkas [pruneOldDone].
class TaskRepository {
  TaskRepository(this._db);

  final AppDatabase _db;

  /// Daftar task, yang due lebih dulu.
  Future<List<Task>> all() {
    final q = _db.select(_db.tasks)
      ..orderBy([(t) => OrderingTerm.asc(t.nextRunAt)]);
    return q.get();
  }

  Stream<List<Task>> watchAll() {
    final q = _db.select(_db.tasks)
      ..orderBy([(t) => OrderingTerm.asc(t.nextRunAt)]);
    return q.watch();
  }

  Future<Task?> byId(int id) {
    final q = _db.select(_db.tasks)..where((t) => t.id.equals(id));
    return q.getSingleOrNull();
  }

  Future<int> create({
    required String title,
    required String prompt,
    String? skill,
    String kind = 'once',
    int? intervalSec,
    String? cronExpr,
    DateTime? nextRunAt,
  }) {
    return _db.into(_db.tasks).insert(TasksCompanion.insert(
          title: title,
          prompt: prompt,
          skill: Value(skill),
          kind: Value(kind),
          intervalSec: Value(intervalSec),
          cronExpr: Value(cronExpr),
          nextRunAt: Value(nextRunAt ?? DateTime.now()),
        ));
  }

  Future<int> updateStatus(
    int id,
    String status, {
    String? error,
    int? failCount,
  }) {
    return (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: Value(status),
        lastError: Value(error),
        failCount: failCount == null ? const Value.absent() : Value(failCount),
        lastRunAt: Value(DateTime.now()),
      ),
    );
  }

  /// Jadwalkan run berikutnya (interval/cron). Null = selesai.
  Future<void> scheduleNext(int id, DateTime next) {
    return (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        nextRunAt: Value(next),
        status: const Value('pending'),
      ),
    );
  }

  Future<int> remove(int id) {
    return (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }

  /// Hapus log/task selesai lebih dari [days] hari (P-13, default 30).
  Future<int> pruneOldDone({int days = 30}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (_db.delete(_db.tasks)
          ..where((t) =>
              t.status.isIn(['done', 'cancelled']) &
              t.lastRunAt.isSmallerThanValue(cutoff)))
        .go();
  }

  /// Task yang sudah due dan masih pending (scheduler memilih dari sini).
  Future<List<Task>> dueTasks({int limit = 2}) {
    final now = DateTime.now();
    final q = _db.select(_db.tasks)
      ..where((t) =>
          t.status.equals('pending') &
          t.nextRunAt.isSmallerOrEqualValue(now))
      ..orderBy([(t) => OrderingTerm.asc(t.nextRunAt)])
      ..limit(limit);
    return q.get();
  }

  /// Hitung task yang sedang berjalan (batas paralel 2, blueprint 5.4).
  Future<int> runningCount() async {
    final q = _db.select(_db.tasks)
      ..where((t) => t.status.equals('running'));
    final rows = await q.get();
    return rows.length;
  }
}
