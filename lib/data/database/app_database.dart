import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'crypto_tables.dart';
import 'tables.dart';
import 'task_tables.dart';

part 'app_database.g.dart';

/// Hasil pencarian riwayat (Fase 2).
class MessageHit {
  const MessageHit({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
  });

  final int id;
  final int conversationId;
  final String role;
  final String content;
}

/// Database lokal aplikasi (blueprint Fase 2, aturan P-04).
///
/// - WAL mode + indeks untuk throughput baca/tulis
/// - foreign key cascade: hapus percakapan = hapus pesannya
/// - versi migrate naik satu per satu; tidak ada destructive migration
@DriftDatabase(tables: [
  Conversations,
  Messages,
  Tasks,
  WatchWallets,
  OnchainSettings,
  ContractAllowlist,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Konstruktor injeksi untuk tes (database di memori).
  @visibleForTesting
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // v2: tabel tasks (blueprint 5.4).
          if (from < 2) {
            await m.createTable(tasks);
          }
          // v3: tabel crypto watch-only (blueprint 10A, Fase 7).
          if (from < 3) {
            await m.createTable(watchWallets);
            await m.createTable(onchainSettings);
            await m.createTable(contractAllowlist);
          }
        },
        beforeOpen: (details) async {
          // foreign_keys butuh satu panggilan per koneksi; WAL untuk
          // konkurensi baca saat streaming.
          await customStatement('PRAGMA foreign_keys = ON;');
          await customStatement('PRAGMA journal_mode = WAL;');
          // Indeks pencarian + urutan baca pesan (Fase 2).
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_messages_conversation '
            'ON messages (conversation_id, created_at);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_conversations_updated '
            'ON conversations (updated_at DESC);',
          );
        },
      );

  // --- Conversations ------------------------------------------------------

  Future<int> createConversation({
    String title = 'Percakapan baru',
    String? providerId,
    String? model,
  }) async {
    final id = await into(conversations).insert(ConversationsCompanion.insert(
      title: Value(title),
      providerId: Value(providerId),
      model: Value(model),
    ));
    return id;
  }

  Future<List<Conversation>> watchConversations() =>
      (select(conversations)
            ..orderBy([(c) => OrderingTerm(expression: c.updatedAt, mode: OrderingMode.desc)]))
          .get();

  Stream<List<Conversation>> conversationsStream() =>
      (select(conversations)
            ..orderBy([(c) => OrderingTerm(expression: c.updatedAt, mode: OrderingMode.desc)]))
          .watch();

  Future<Conversation?> getConversation(int id) async =>
      (select(conversations)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<void> touchConversation(int id, {int? tokenEstimate}) async {
    final conv = await getConversation(id);
    if (conv == null) return;
    await (update(conversations)..where((c) => c.id.equals(id))).write(
      ConversationsCompanion(
        updatedAt: Value(DateTime.now()),
        tokenEstimate: tokenEstimate != null ? Value(tokenEstimate) : const Value.absent(),
      ),
    );
  }

  Future<void> renameConversation(int id, String title) async {
    await (update(conversations)..where((c) => c.id.equals(id)))
        .write(ConversationsCompanion(title: Value(title)));
  }

  Future<void> deleteConversation(int id) async {
    await (delete(conversations)..where((c) => c.id.equals(id))).go();
  }

  Future<int> conversationCount() async {
    final count = countAll();
    final row = await (selectOnly(conversations)..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  // --- Messages -----------------------------------------------------------

  Future<int> insertMessage({
    required int conversationId,
    required String role,
    required String content,
    String? toolName,
    String? toolStatus,
    int? toolDurationMs,
    String? toolArgsJson,
  }) async {
    final id = await into(messages).insert(MessagesCompanion.insert(
      conversationId: conversationId,
      role: role,
      content: content,
      toolName: Value(toolName),
      toolStatus: Value(toolStatus),
      toolDurationMs: Value(toolDurationMs),
      toolArgsJson: Value(toolArgsJson),
    ));
    await touchConversation(conversationId);
    return id;
  }

  Future<void> updateMessageContent(int id, String content) async {
    await (update(messages)..where((m) => m.id.equals(id)))
        .write(MessagesCompanion(content: Value(content)));
  }

  Future<List<Message>> messagesFor(int conversationId) =>
      (select(messages)
            ..where((m) => m.conversationId.equals(conversationId))
            ..orderBy([(m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.asc)]))
          .get();

  Stream<List<Message>> messagesStream(int conversationId) =>
      (select(messages)
            ..where((m) => m.conversationId.equals(conversationId))
            ..orderBy([(m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.asc)]))
          .watch();

  /// Pencarian riwayat pesan (Fase 2) — LIKE case-insensitive di SQLite
  /// sudah cukup ringan untuk skala lokal; FTS5 baru di Fase 8 bila perlu.
  /// Statement metah karena drift `like()` tidak mendukung klausul ESCAPE:
  /// tanpa klausul itu, `%` dalam query pengguna menjadi wildcard.
  Future<List<MessageHit>> searchMessages(String query) async {
    final rows = await customSelect(
      "SELECT id, conversation_id, role, content FROM messages "
      "WHERE content LIKE ? ESCAPE '\\'",
      variables: [Variable.withString('%${query.replaceAll('%', r'\%')}%')],
    ).get();
    return rows
        .map((r) => MessageHit(
              id: r.read<int>('id'),
              conversationId: r.read<int>('conversation_id'),
              role: r.read<String>('role'),
              content: r.read<String>('content'),
            ))
        .toList();
  }

  /// Menghapus pesan lama untuk pemangkasan konteks (sliding window).
  /// Menggunakan id (autoincrement, monoton naik) alih-alih timestamp:
  /// pesan yang disisi batch sering berbagi timestamp sama persis, yang
  /// membuat perbandingan waktu menghapus terlalu banyak baris.
  Future<int> pruneMessages(int conversationId, int keepLatest) async {
    if (keepLatest <= 0) return 0;
    final all = await messagesFor(conversationId);
    if (all.length <= keepLatest) return 0;
    final cutId = all[all.length - keepLatest].id;
    return (delete(messages)
          ..where((m) => m.conversationId.equals(conversationId))
          ..where((m) => m.id.isSmallerThanValue(cutId)))
        .go();
  }

  Future<int> messageCount() async {
    final count = countAll();
    final row = await (selectOnly(messages)..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}superagent.db');
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // Mengurangi I/O sinkron; aman untuk aplikasi lokal (P-04).
        db.execute('PRAGMA journal_mode = WAL;');
        db.execute('PRAGMA synchronous = NORMAL;');
        db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  });
}
