import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'dart:convert';

import '../security/redactor.dart';

/// Append-only audit trail (blueprint section 5.6, rules S-41/V-04/K-06).
///
/// Every agent decision, tool call, permission grant and user confirmation
/// lands here with redacted arguments. The file is append-only by contract:
/// entries are never edited or deleted, only expired by retention.
class AuditLogger {
  AuditLogger(this._path);

  final String _path;
  IOSink? _sink;
  bool _initialised = false;

  /// Opens the log in append mode. Safe to call repeatedly.
  Future<void> init() async {
    if (_initialised) return;
    final file = File(_path);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    _sink = file.openWrite(mode: FileMode.append);
    _initialised = true;
  }

  /// Writes one structured entry. Arguments are redacted first.
  Future<void> log({
    required String taskId,
    required String event,
    String? tool,
    Map<String, dynamic>? args,
    String? result,
    String? decision,
    String? approvedBy,
  }) async {
    await init();
    final entry = AuditEntry(
      timestamp: DateTime.now().toUtc(),
      taskId: taskId,
      event: event,
      tool: tool,
      args: Redactor.redactJson(args ?? <String, dynamic>{}),
      result: result != null ? Redactor.redact(result) : null,
      decision: decision,
      approvedBy: approvedBy,
    );
    _sink?.writeln(entry.toJson());
  }

  /// Reads back the last [limit] entries for the activity / log screen.
  Future<List<AuditEntry>> tail({int limit = 200}) async {
    final file = File(_path);
    if (!await file.exists()) return const [];
    final lines = await file.readAsLines();
    final start = lines.length > limit ? lines.length - limit : 0;
    final out = <AuditEntry>[];
    for (final line in lines.skip(start)) {
      if (line.trim().isEmpty) continue;
      try {
        out.add(AuditEntry.fromJson(line));
      } catch (_) {
        // Skip malformed lines rather than failing the whole read.
      }
    }
    return out;
  }

  /// Retention sweep (rule P-13). Deletes entries older than [maxAge].
  Future<int> prune({Duration maxAge = const Duration(days: 90)}) async {
    final file = File(_path);
    if (!await file.exists()) return 0;
    final lines = await file.readAsLines();
    final cutoff = DateTime.now().toUtc().subtract(maxAge);
    final kept = <String>[];
    var removed = 0;
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final e = AuditEntry.fromJson(line);
        if (e.timestamp.isBefore(cutoff)) {
          removed++;
          continue;
        }
        kept.add(line);
      } catch (_) {
        kept.add(line);
      }
    }
    await file.writeAsString('${kept.join('\n')}\n');
    return removed;
  }

  Future<void> dispose() async {
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
    _initialised = false;
  }
}

/// One append-only audit record. [args] and [result] are stored redacted.
@immutable
class AuditEntry {
  const AuditEntry({
    required this.timestamp,
    required this.taskId,
    required this.event,
    this.tool,
    this.args,
    this.result,
    this.decision,
    this.approvedBy,
  });

  final DateTime timestamp;
  final String taskId;
  final String event;
  final String? tool;
  final String? args;
  final String? result;
  final String? decision;
  final String? approvedBy;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'ts': timestamp.toIso8601String(),
        'task_id': taskId,
        'event': event,
        if (tool != null) 'tool': tool,
        if (args != null) 'args': args,
        if (result != null) 'result': result,
        if (decision != null) 'decision': decision,
        if (approvedBy != null) 'approved_by': approvedBy,
      };

  String toJson() => jsonEncodeHelper(toMap());

  factory AuditEntry.fromJson(String source) {
    final m = jsonDecodeHelper(source) as Map<String, dynamic>;
    return AuditEntry(
      timestamp: DateTime.parse(m['ts'] as String),
      taskId: m['task_id'] as String,
      event: m['event'] as String,
      tool: m['tool'] as String?,
      args: m['args'] as String?,
      result: m['result'] as String?,
      decision: m['decision'] as String?,
      approvedBy: m['approved_by'] as String?,
    );
  }
}

String jsonEncodeHelper(Map<String, dynamic> m) => jsonEncode(m);

dynamic jsonDecodeHelper(String source) => jsonDecode(source);
