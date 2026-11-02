// Tes Fase 6: task scheduler (5.4), retensi (P-13), cron sederhana.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superagent/core/audit/audit_logger.dart';
import 'package:superagent/core/tasks/task_scheduler.dart';
import 'package:superagent/data/database/app_database.dart';
import 'package:superagent/data/repositories/task_repository.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;
  late AuditLogger audit;
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('task_test_');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TaskRepository(db);
    audit = AuditLogger('${tmp.path}${Platform.pathSeparator}audit.log');
  });

  tearDown(() async {
    await audit.dispose();
    await db.close();
    try {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    } catch (_) {}
  });

  group('TaskRepository (5.4)', () {
    test('create + all', () async {
      await repo.create(title: 'seed', prompt: 'x');
      final rows = await repo.all();
      expect(rows.length, 1);
      expect(rows.first.title, 'seed');
      expect(rows.first.status, 'pending');
      expect(rows.first.kind, 'once');
    });

    test('updateStatus mencatat lastRunAt', () async {
      final id = await repo.create(title: 'seed', prompt: 'x');
      await repo.updateStatus(id, 'running');
      await repo.updateStatus(id, 'done');
      final after = await repo.byId(id);
      expect(after!.status, 'done');
      expect(after.lastRunAt, isNotNull);
    });

    test('dueTasks hanya ambil yang sudah due dan pending', () async {
      final past = DateTime.now().subtract(const Duration(minutes: 5));
      final future = DateTime.now().add(const Duration(hours: 1));
      await repo.create(title: 'past', prompt: 'p', nextRunAt: past);
      await repo.create(title: 'future', prompt: 'p', nextRunAt: future);
      final due = await repo.dueTasks();
      expect(due.length, 1);
      expect(due.first.title, 'past');
    });

    test('runningCount', () async {
      final id = await repo.create(title: 'r', prompt: 'p');
      await repo.updateStatus(id, 'running');
      expect(await repo.runningCount(), 1);
    });

    test('pruneOldDone hapus done >30 hari (P-13)', () async {
      final old = DateTime.now().subtract(const Duration(days: 40));
      final id = await repo.create(title: 'old', prompt: 'p');
      await repo.updateStatus(id, 'done');
      // lastRunAt diisi now; paksa ke 40 hari lalu. Drift menyimpan
      // datetime sebagai microsecond integer (bukan ISO string).
      await db.customStatement(
          'UPDATE tasks SET last_run_at = ? WHERE id = ?;',
          [old.millisecondsSinceEpoch ~/ 1000, id]);
      final n = await repo.pruneOldDone();
      expect(n, 1);
      expect((await repo.all()).where((r) => r.title == 'old'), isEmpty);
    });

    test('scheduleNext kembali ke pending', () async {
      final id = await repo.create(title: 's', prompt: 'p');
      await repo.updateStatus(id, 'running');
      await repo.scheduleNext(
          id, DateTime.now().add(const Duration(minutes: 10)));
      final after = await repo.byId(id);
      expect(after!.status, 'pending');
      expect(after.nextRunAt, isNotNull);
    });
  });

  group('TaskScheduler (5.4, P-08)', () {
    test('jalankan task due segera', () async {
      final id = await repo.create(title: 'seed', prompt: 'x');
      final scheduler = TaskScheduler(
        repo: repo,
        audit: audit,
        runner: TaskRunner(audit),
      );
      await scheduler.start();
      // Tunggu tick (timer = 0 delay).
      await Future.delayed(const Duration(milliseconds: 300));
      final t = await repo.byId(id);
      expect(t!.status, anyOf('done', 'running'));
      scheduler.dispose();
    });

    test('interval menskedul ulang', () async {
      final id = await repo.create(
        title: 'int',
        prompt: 'p',
        kind: 'interval',
        intervalSec: 60,
      );
      final scheduler = TaskScheduler(
        repo: repo,
        audit: audit,
        runner: TaskRunner(audit),
      );
      await scheduler.start();
      await Future.delayed(const Duration(milliseconds: 300));
      final t = await repo.byId(id);
      expect(t!.status, 'pending');
      expect(t.nextRunAt, isNotNull);
      scheduler.dispose();
    });

    test('cron sederhana: next run besok', () {
      final scheduler = TaskScheduler(
        repo: repo,
        audit: audit,
        runner: TaskRunner(audit),
      );
      final now = DateTime(2026, 11, 2, 10, 0);
      final next = scheduler.parseSimpleCronNext('30 6 *', now);
      expect(next, DateTime(2026, 11, 3, 6, 30));
    });

    test('cron sederhana: hari of month', () {
      final scheduler = TaskScheduler(
        repo: repo,
        audit: audit,
        runner: TaskRunner(audit),
      );
      final now = DateTime(2026, 11, 2, 10, 0);
      final next = scheduler.parseSimpleCronNext('0 0 10', now);
      expect(next, DateTime(2026, 11, 10, 0, 0));
    });

    test('cron invalid -> null', () {
      final scheduler = TaskScheduler(
        repo: repo,
        audit: audit,
        runner: TaskRunner(audit),
      );
      expect(scheduler.parseSimpleCronNext('99 99 99', DateTime.now()), isNull);
      expect(scheduler.parseSimpleCronNext('tidak valid', DateTime.now()), isNull);
    });
  });
}

extension on TaskRepository {
  Future<Task?> byTitle(String title) async {
    final rows = await all();
    for (final t in rows) {
      if (t.title == title) return t;
    }
    return null;
  }
}
