import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/llm/openai_compat.dart';
import '../../core/llm/provider.dart' as llm;
import '../../core/security/redactor.dart';
import 'chat_repository.dart';

/// Status satu pesan dalam percakapan aktif.
enum MessageStatus { streaming, done, stopped, error }

/// Pesan yang ditampilkan UI. Saat streaming, [content] tumbuh per delta.
@immutable
class ChatMessageState {
  const ChatMessageState({
    required this.id,
    required this.role,
    required this.content,
    this.status = MessageStatus.done,
    this.toolName,
    this.toolStatus,
    this.toolDurationMs,
    this.errorText,
  });

  final int id;
  final String role; // 'user' | 'assistant' | 'tool'
  final String content;
  final MessageStatus status;
  final String? toolName;
  final String? toolStatus;
  final int? toolDurationMs;
  final String? errorText;

  ChatMessageState copyWith({
    String? content,
    MessageStatus? status,
    String? toolName,
    String? toolStatus,
    int? toolDurationMs,
    String? errorText,
  }) =>
      ChatMessageState(
        id: id,
        role: role,
        content: content ?? this.content,
        status: status ?? this.status,
        toolName: toolName ?? this.toolName,
        toolStatus: toolStatus ?? this.toolStatus,
        toolDurationMs: toolDurationMs ?? this.toolDurationMs,
        errorText: errorText ?? this.errorText,
      );
}

/// State percakapan aktif.
@immutable
class ChatState {
  const ChatState({
    this.conversationId,
    this.messages = const <ChatMessageState>[],
    this.isStreaming = false,
    this.canStop = false,
    this.error,
  });

  final int? conversationId;
  final List<ChatMessageState> messages;
  final bool isStreaming;
  final bool canStop;
  final String? error;

  ChatState copyWith({
    int? conversationId,
    List<ChatMessageState>? messages,
    bool? isStreaming,
    bool? canStop,
    String? error,
    bool clearError = false,
  }) =>
      ChatState(
        conversationId: conversationId ?? this.conversationId,
        messages: messages ?? this.messages,
        isStreaming: isStreaming ?? this.isStreaming,
        canStop: canStop ?? this.canStop,
        error: clearError ? null : (error ?? this.error),
      );
}

/// Notifier percakapan aktif (blueprint Fase 2: streaming, Stop,
/// Regenerate, Edit pesan, pemangkasan konteks).
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._repo, this._provider) : super(const ChatState());

  final ChatRepository _repo;
  final llm.LlmProvider _provider;

  StreamSubscription<llm.LlmEvent>? _streamSub;
  StringBuffer? _buffer;
  int? _streamingMessageId;
  Timer? _persistTimer;

  /// Buka percakapan (buat bila [id] null).
  Future<void> open({int? id}) async {
    if (state.isStreaming) await stop();
    if (id != null) {
      final rows = await _repo.messages(id);
      state = ChatState(
        conversationId: id,
        messages: rows
            .map((m) => ChatMessageState(
                  id: m.id,
                  role: m.role,
                  content: m.content,
                  toolName: m.toolName,
                  toolStatus: m.toolStatus,
                ))
            .toList(growable: false),
      );
    } else {
      final newId = await _repo.createConversation();
      state = ChatState(conversationId: newId);
    }
  }

  /// Kirim pesan pengguna dan mulai streaming jawaban.
  Future<void> send(String text) async {
    final convId = state.conversationId ?? await _repo.createConversation();
    if (state.conversationId == null) {
      state = state.copyWith(conversationId: convId);
    }

    // 1. Simpan pesan pengguna.
    final userRowId = await _repo.appendUserMessage(convId, text);
    final userMsg = ChatMessageState(id: userRowId, role: 'user', content: text);
    state = state.copyWith(
      conversationId: convId,
      messages: [...state.messages, userMsg],
      clearError: true,
    );

    // 2. Siapkan pesan asisten placeholder.
    final assistantRowId = await _repo.appendAssistantMessage(convId, '');
    _streamingMessageId = assistantRowId;
    _buffer = StringBuffer();
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessageState(
          id: assistantRowId,
          role: 'assistant',
          content: '',
          status: MessageStatus.streaming,
        ),
      ],
      isStreaming: true,
      canStop: true,
    );

    // 3. streaming.
    await _startStream(convId);
  }

  Future<void> _startStream(int convId) async {
    final history = await _repo.messages(convId);
    final requestMessages = _repo.toChatMessages(
      // Kecualikan pesan asisten kosong yang baru saja kita buat.
      history.where((m) => m.role != 'assistant' || m.content.isNotEmpty).toList(),
    );
    try {
      final stream = _provider.chat(llm.ChatRequest(
        model: _model,
        messages: requestMessages,
        systemPrompt: _systemPrompt,
      ));
      _persistTimer?.cancel();
      _persistTimer = null;
      _streamSub = stream.listen(
        (event) => _onEvent(event, convId),
        onError: (Object e, StackTrace st) => _onError(e, convId),
        onDone: () => _onDone(convId),
      );
    } catch (e) {
      _onError(e, convId);
    }
  }

  void _onEvent(llm.LlmEvent event, int convId) {
    if (event is llm.TextDelta) {
      _buffer?.write(event.text);
      _patchStreaming(content: _buffer.toString());
    } else if (event is llm.ToolCall) {
      // Tampilan kartu alat (wireframe A); eksekusi tertunda di Fase 3.
      _patchStreaming(toolName: event.name, toolStatus: 'running');
    }
  }

  void _onError(Object error, int convId) {
    _streamSub?.cancel();
    _persistTimer?.cancel();
    final msg = 'Gagal: ${Redactor.redact(error.toString())}';
    _patchStreaming(status: MessageStatus.error, errorText: msg);
    state = state.copyWith(isStreaming: false, canStop: false, error: msg);
  }

  void _onDone(int convId) {
    _streamSub?.cancel();
    _persistTimer?.cancel();
    final content = _buffer?.toString() ?? '';
    _patchStreaming(status: MessageStatus.done, content: content, clearError: true);
    state = state.copyWith(isStreaming: false, canStop: false);
    _persist(convId, content);
    // Gebrang konteks: pertahankan 40 pesan terakhir (Fase 2).
    _repo.prune(convId, 40);
  }

  /// Hentikan streaming (tombol Stop).
  Future<void> stop() async {
    _streamSub?.cancel();
    _persistTimer?.cancel();
    final content = _buffer?.toString() ?? '';
    if (content.isNotEmpty) {
      _patchStreaming(status: MessageStatus.stopped, content: content);
      _persist(state.conversationId!, content);
    } else {
      // Tidak ada teks: hapus placeholder.
      final id = _streamingMessageId;
      if (id != null) {
        state = state.copyWith(
          messages: state.messages.where((m) => m.id != id).toList(growable: false),
        );
      }
    }
    state = state.copyWith(isStreaming: false, canStop: false);
  }

  /// Hasilkan ulang jawaban: hapus jawaban asisten terakhir, kirim ulang.
  Future<void> regenerate() async {
    if (state.isStreaming) return;
    final msgs = state.messages;
    final lastUser = msgs.lastIndexWhere((m) => m.role == 'user');
    if (lastUser < 0) return;
    final text = msgs[lastUser].content;
    // Gunus jawaban setelah pesan pengguna itu.
    state = state.copyWith(messages: msgs.sublist(0, lastUser + 1));
    await send(text);
  }

  /// Edit pesan pengguna dan buang semua jawaban setelahnya (Fase 2).
  Future<void> editUserMessage(int messageId, String newText) async {
    if (state.isStreaming) return;
    final msgs = state.messages;
    final index = msgs.indexWhere((m) => m.id == messageId && m.role == 'user');
    if (index < 0) return;
    final truncated = msgs.sublist(0, index + 1).toList();
    truncated[index] = truncated[index].copyWith(content: newText);
    state = state.copyWith(messages: truncated);
    await _repo.setMessageContent(messageId, newText);
    await send(newText);
  }

  void _patchStreaming({
    String? content,
    MessageStatus? status,
    String? toolName,
    String? toolStatus,
    String? errorText,
    bool clearError = false,
  }) {
    final id = _streamingMessageId;
    if (id == null) return;
    final msgs = state.messages.toList();
    final i = msgs.indexWhere((m) => m.id == id);
    if (i < 0) return;
    msgs[i] = msgs[i].copyWith(
      content: content,
      status: status,
      toolName: toolName,
      toolStatus: toolStatus,
      errorText: errorText,
    );
    state = state.copyWith(messages: msgs, clearError: clearError);
  }

  /// Menulis konten final ke DB (tunggu tenang untuk menghindari tulisan
  /// setiap delta — P-04).
  void _persist(int convId, String content) {
    final id = _streamingMessageId;
    if (id != null) {
      _repo.setMessageContent(id, content);
    }
  }

  String get _model => 'gpt-4o-mini'; // TODO: ambil dari provider config
  String get _systemPrompt =>
      'Kamu adalah Superagent, asisten AI yang membantu. Jawab dalam bahasa '
      'yang sama dengan pengguna.';

  @override
  void dispose() {
    _streamSub?.cancel();
    _persistTimer?.cancel();
    super.dispose();
  }
}

/// Model aktif dari ProviderConfigNotifier (Fase 5). Sementara memakai
/// default sampai wiring provider ke chat selesai.
final activeModelProvider = Provider<String>((ref) => 'gpt-4o-mini');

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  // Provider LLM sebenarnya diatur dari layar provider (Fase 1); di sini
  // memakai default OpenAI-compatible yang bisa ditukar.
  final provider = OpenAiCompatibleProvider(
    baseUrl: 'https://api.openai.com/v1',
    apiKey: '',
  );
  return ChatNotifier(
    repo,
    provider,
  );
});
