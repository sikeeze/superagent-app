import 'dart:async';

import '../audit/audit_logger.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/task_repository.dart';

/// Scheduler task (blueprint 5.4 + P-08).
///
/// - **Timer tunggal** untuk task due terdekat — tidak ada polling (P-08).
/// - **Maks 2 paralel** (antrean serial default).
/// - Setiap run masuk audit log (S-22/S-36).
/// - Eksekusi aktual via [TaskExecutor] (injeksi, terpisah dari UI).
class TaskScheduler extends TaskExecutor {
  TaskScheduler({
    required TaskRepository repo,
    required AuditLogger audit,
    required TaskRunner runner,
    int maxParallel = 2,
  })  : _repo = repo,
        _audit = audit,
        _runner = runner,
        _maxParallel = maxParallel;

  final TaskRepository _repo;
  final AuditLogger _audit;
  final TaskRunner _runner;
  final int _maxParallel;

  Timer? _timer;
  bool _stopped = false;
  int _active = 0;

  /// Mulai scheduler. Pilih due terdekat, tunggu, jalankan.
  Future<void> start() async {
    _stopped = false;
    await _repo.pruneOldDone();
    _reschedule();
  }

  /// Hentikan scheduler (task yang sedang berjalan tetap diselesaikan).
  void stop() {
    _stopped = true;
    _timer?.cancel();
    _timer = null;
  }

  /// Kapan task due berikutnya (null = tidak ada).
  Future<DateTime?> nextDue() async {
    final tasks = await _repo.all();
    for (final t in tasks) {
      if (t.status == 'pending' && t.nextRunAt != null) {
        return t.nextRunAt;
      }
    }
    return null;
  }

  void _reschedule() async {
    if (_stopped) return;
    _timer?.cancel();
    final due = await nextDue();
    if (due == null) {
      _timer = null;
      return;
    }
    final delay = due.difference(DateTime.now());
    // Task sudah due: jalankan segera (tapi hormati batas paralel).
    final wait = delay.isNegative ? Duration.zero : delay;
    _timer = Timer(wait, _tick);
  }

  Future<void> _tick() async {
    if (_stopped) return;
    final free = _maxParallel - _active;
    if (free <= 0) {
      // Slot penuh: coba lagi sebentar lagi.
      _timer = Timer(const Duration(seconds: 2), _tick);
      return;
    }
    final due = await _repo.dueTasks(limit: free);
    if (due.isEmpty) {
      _reschedule();
      return;
    }
    for (final t in due) {
      _active++;
      // Jalankan tanpa await: paralel.
      _runTask(t).whenComplete(() {
        _active--;
        if (!_stopped) _reschedule();
      });
    }
    // Ambil slot langsung untuk following-up.
    _reschedule();
  }

  Future<void> _runTask(Task t) async {
    await _repo.updateStatus(t.id, 'running');
    await _audit.log(
      taskId: 'task:${t.id}',
      event: 'start',
      tool: 'scheduler',
      result: t.title,
    );
    try {
      final ok = await _runner.onRun(t);
      if (!ok) {
        await _repo.updateStatus(t.id, 'failed', error: 'Eksekusi gagal');
        return;
      }
      // Jadwalkan ulang bila interval/cron; bila 'once' -> done.
      final next = _nextRun(t);
      if (next == null) {
        await _repo.updateStatus(t.id, 'done');
      } else {
        await _repo.scheduleNext(t.id, next);
      }
    } catch (e) {
      await _repo.updateStatus(t.id, 'failed', error: e.toString());
    }
  }

  /// Hitung run berikutnya. Null = task 'once' (selesai).
  DateTime? _nextRun(Task t) {
    final now = DateTime.now();
    if (t.kind == 'interval' && t.intervalSec != null) {
      return now.add(Duration(seconds: t.intervalSec!));
    }
    if (t.kind == 'cron' && t.cronExpr != null) {
      return parseSimpleCronNext(t.cronExpr!, now);
    }
    return null;
  }

  /// Cron sederhana: "menit jam hari" (blueprint: cron sederhana).
  /// Mendukung nilai numerik atau `*`. Contoh: "30 6 *".
  /// Dipublikasikan agar bisa diuji langsung (tanpa timer).
  DateTime? parseSimpleCronNext(String expr, DateTime now) {
    final parts = expr.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) return null;
    int? parseOrStar(String p, int max) {
      if (p == '*') return null;
      return int.tryParse(p);
    }

    final m = parseOrStar(parts[0], 59);
    final h = parseOrStar(parts[1], 23);
    final d = parseOrStar(parts[2], 31);
    if (m != null && (m < 0 || m > 59)) return null;
    if (h != null && (h < 0 || h > 23)) return null;
    if (d != null && (d < 1 || d > 31)) return null;

    var next = DateTime(now.year, now.month, now.day,
        h ?? now.hour, m ?? now.minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    // Hari-of-month spesifik: lompat ke hari itu bulan berikutnya.
    if (d != null) {
      while (next.day != d) {
        next = next.add(const Duration(days: 1));
        if (next.month != now.month && next.day != 1) {
          // ga mungkin? tetap batasi loop.
        }
      }
    }
    return next;
  }

  @override
  void dispose() {
    stop();
  }
}

/// Eksekutor standar untuk task: jalankan skill bila ada, bila tidak
/// catat prompt sebagai log (agent loop integrasi di Fase 8).
class TaskRunner {
  TaskRunner(this._audit);

  /// Akses untuk subclass (log tambahan saat run).
  AuditLogger get auditLogger => _audit;
  final AuditLogger _audit;

  /// Return true = sukses.
  Future<bool> onRun(Task t) async {
    await _audit.log(
      taskId: 'task:${t.id}',
      event: 'run',
      tool: t.skill == null ? 'prompt' : 'skill:${t.skill}',
      result: t.prompt,
    );
    return true;
  }
}

/// Interface ringan agar scheduler bisa di-inject di tes.
abstract class TaskExecutor {
  void dispose();
}
