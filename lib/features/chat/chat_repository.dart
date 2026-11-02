import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/llm/provider.dart' as llm;
import '../../data/database/app_database.dart';

/// Jembatan antara [AppDatabase] dan UI chat (blueprint Fase 2).
///
/// UI hanya melihat model domain sederhana; detail baris database
/// (termasuk meta tool) tidak bocor ke widget.
class ChatRepository {
  ChatRepository(this._db);

  final AppDatabase _db;

  Future<int> createConversation({
    String title = 'Percakapan baru',
    String? providerId,
    String? model,
  }) =>
      _db.createConversation(
        title: title,
        providerId: providerId,
        model: model,
      );

  Stream<List<Conversation>> watchConversations() => _db.conversationsStream();

  Future<List<Conversation>> allConversations() => _db.watchConversations();

  Future<Conversation?> conversation(int id) => _db.getConversation(id);

  Future<void> rename(int id, String title) => _db.renameConversation(id, title);

  Future<void> delete(int id) => _db.deleteConversation(id);

  Stream<List<Message>> watchMessages(int conversationId) =>
      _db.messagesStream(conversationId);

  Future<List<Message>> messages(int conversationId) =>
      _db.messagesFor(conversationId);

  Future<int> appendUserMessage(int conversationId, String text) =>
      _db.insertMessage(conversationId: conversationId, role: 'user', content: text);

  Future<int> appendAssistantMessage(int conversationId, String text) =>
      _db.insertMessage(conversationId: conversationId, role: 'assistant', content: text);

  Future<int> appendToolMessage({
    required int conversationId,
    required String toolName,
    required String status,
    required String content,
    int? durationMs,
    String? argsJson,
  }) =>
      _db.insertMessage(
        conversationId: conversationId,
        role: 'tool',
        content: content,
        toolName: toolName,
        toolStatus: status,
        toolDurationMs: durationMs,
        toolArgsJson: argsJson,
      );

  Future<void> setMessageContent(int id, String content) =>
      _db.updateMessageContent(id, content);

  /// Pencarian riwayat lintas percakapan.
  Future<List<MessageHit>> search(String query) => _db.searchMessages(query);

  /// Pemangkasan konteks: pertahankan [keepLatest] pesan terakhir.
  Future<int> prune(int conversationId, int keepLatest) =>
      _db.pruneMessages(conversationId, keepLatest);

  /// Mengubah pesan lama menjadi payload ChatRequest untuk LLM.
  List<llm.ChatMessage> toChatMessages(List<Message> rows) {
    return rows
        .where((m) => m.role == 'user' || m.role == 'assistant')
        .map((m) => llm.ChatMessage(role: m.role, content: m.content))
        .toList(growable: false);
  }
}

/// Riverpod: satu instance database per aplikasi.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ChatRepository(db);
});

/// Daftar percakapan (urut yang terakhir diperbarui).
final conversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchConversations();
});
