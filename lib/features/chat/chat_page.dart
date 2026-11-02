import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/design_tokens.dart';
import '../../app/theme.dart';
import 'chat_notifier.dart';
import 'chat_repository.dart';
import '../../data/database/app_database.dart' show MessageHit;

/// Layar chat (blueprint Fase 2, wireframe A).
///
/// - streaming teks delta (tidak ditulis ke DB per delta, P-04)
/// - tombol Stop saat streaming
/// - Regenerate dan Edit pesan pengguna
/// - render markdown minimal + lazy (tevATE sangat panjang dipotong)
/// - daftar percakapan di sidebar (lebar) / drawer (sempit)
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _ensureOpened() {
    ref.read(chatNotifierProvider.notifier).open();
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  void _onSend() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    ref.read(chatNotifierProvider.notifier).send(text);
    _jumpToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatNotifierProvider);
    final colors = appColors(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= DesignTokens.singleColumn;

    if (chat.messages.isEmpty && chat.conversationId == null) {
      _ensureOpened();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Superagent'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.surfaceTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: DesignTokens.accent),
                  const SizedBox(width: 6),
                  Text(ref.watch(activeModelProvider),
                      style: const TextStyle(fontSize: 12)),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cari riwayat',
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'Percakapan baru',
            onPressed: () =>
                ref.read(chatNotifierProvider.notifier).open(),
          ),
        ],
      ),
      drawer: isWide ? null : const _ConversationDrawer(),
      body: isWide
          ? Row(
              children: [
                const SizedBox(
                  width: DesignTokens.sidebarWidth,
                  child: _ConversationList(),
                ),
                Expanded(child: _chatArea(chat, colors)),
              ],
            )
          : _chatArea(chat, colors),
    );
  }

  Widget _chatArea(ChatState chat, AppColors colors) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemCount: chat.messages.length,
              itemBuilder: (context, i) {
                final m = chat.messages[i];
                return _MessageBubble(
                  message: m,
                  colors: colors,
                  onRegenerate: m.role == 'assistant' && !chat.isStreaming
                      ? () => ref.read(chatNotifierProvider.notifier).regenerate()
                      : null,
                  onEdit: m.role == 'user' && !chat.isStreaming
                      ? () => _showEditDialog(context, m)
                      : null,
                );
              },
            ),
          ),
        ),
        _composer(chat, colors),
      ],
    );
  }

  Widget _composer(ChatState chat, AppColors colors) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 6,
                enabled: !chat.isStreaming,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _onSend(),
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  hintStyle: TextStyle(color: colors.textSecondary),
                  filled: true,
                  fillColor: colors.surfaceTint,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onEditingComplete: () {},
              ),
            ),
            const SizedBox(width: 8),
            chat.isStreaming
                ? FloatingActionButton(
                    onPressed: () =>
                        ref.read(chatNotifierProvider.notifier).stop(),
                    tooltip: 'Stop',
                    backgroundColor: DesignTokens.danger,
                    child: const Icon(Icons.stop),
                  )
                : FloatingActionButton(
                    onPressed: _onSend,
                    tooltip: 'Kirim',
                    backgroundColor: DesignTokens.accent,
                    child: const Icon(Icons.arrow_upward),
                  ),
          ],
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _ChatSearchDelegate(ref.read(chatRepositoryProvider)),
    );
  }

  void _showEditDialog(BuildContext context, ChatMessageState m) {
    final controller = TextEditingController(text: m.content);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit pesan'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(chatNotifierProvider.notifier)
                  .editUserMessage(m.id, controller.text.trim());
              _jumpToBottom();
            },
            child: const Text('Kirim ulang'),
          ),
        ],
      ),
    );
  }
}

/// Bubble pesan sesuai wireframe A: pengguna kanan, asisten kiri, dan
/// kartu tool yang menampilkan nama tool + status + durasi.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.colors,
    this.onRegenerate,
    this.onEdit,
  });

  final ChatMessageState message;
  final AppColors colors;
  final VoidCallback? onRegenerate;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final isTool = message.role == 'tool';

    if (isTool) return _toolCard();

    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.75,
      ),
      decoration: BoxDecoration(
        color: isUser ? DesignTokens.accent : colors.surfaceTint,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: const Radius.circular(14),
          bottomLeft: Radius.circular(isUser ? 14 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _markdownLite(message.content, isUser),
          if (message.status == MessageStatus.streaming)
            const _BlinkingCursor(),
          if (message.status == MessageStatus.error && message.errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                message.errorText!,
                style: TextStyle(color: DesignTokens.danger, fontSize: 12),
              ),
            ),
        ],
      ),
    );

    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isUser) _avatar(Icons.smart_toy_outlined),
        Flexible(
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              bubble,
              if (!isUser && message.status == MessageStatus.done)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onRegenerate != null)
                      _iconAction(Icons.refresh, 'Ulangi', onRegenerate!),
                    if (onEdit != null)
                      _iconAction(Icons.edit_outlined, 'Edit', onEdit!),
                  ],
                ),
            ],
          ),
        ),
        if (isUser) _avatar(Icons.person_outline),
      ],
    );
  }

  Widget _avatar(IconData icon) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(icon, size: 18, color: colors.textSecondary),
      );

  Widget _iconAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _toolCard() {
    final status = message.toolStatus ?? 'ok';
    final icon = status == 'ok'
        ? Icons.check_circle
        : status == 'failed'
            ? Icons.error
            : Icons.hourglass_top;
    final color = status == 'ok'
        ? DesignTokens.success
        : status == 'failed'
            ? DesignTokens.danger
            : DesignTokens.warning;
    final dur = message.toolDurationMs;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(message.toolName ?? 'tool',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          if (dur != null) ...[
            const SizedBox(width: 8),
            Text('${(dur / 1000).toStringAsFixed(1)}s',
                style: TextStyle(fontSize: 11, color: colors.textSecondary)),
          ],
        ],
      ),
    );
  }

  /// Render markdown minimal: **bold**, *italic*, `code`, dan list `-`.
  /// Lazy: pesan lebih panjang dari 4000 karakter diiris untuk menghindari
  /// widget tree membengkak (aturan P-04).
  Widget _markdownLite(String text, bool isUser) {
    const limit = 4000;
    final display = text.length > limit ? '${text.substring(0, limit)}…' : text;
    final base = TextStyle(
      color: isUser ? Colors.white : colors.textPrimary,
      fontSize: 14,
      height: 1.4,
    );
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'(\*\*[^*]+\*\*|`[^`]+`|\*[^*]+\*)');
    var last = 0;
    for (final m in pattern.allMatches(display)) {
      if (m.start > last) spans.add(TextSpan(text: display.substring(last, m.start), style: base));
      final token = m.group(0)!;
      if (token.startsWith('**')) {
        spans.add(TextSpan(
            text: token.substring(2, token.length - 2),
            style: base.copyWith(fontWeight: FontWeight.w700)));
      } else if (token.startsWith('`')) {
        spans.add(TextSpan(
            text: token.substring(1, token.length - 1),
            style: base.copyWith(
                fontFamily: 'monospace',
                color: isUser ? Colors.white70 : DesignTokens.accent)));
      } else {
        spans.add(TextSpan(
            text: token.substring(1, token.length - 1),
            style: base.copyWith(fontStyle: FontStyle.italic)));
      }
      last = m.end;
    }
    if (last < display.length) {
      spans.add(TextSpan(text: display.substring(last), style: base));
    }
    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c,
      child: Container(
        width: 8,
        height: 14,
        margin: const EdgeInsets.only(top: 2),
        color: DesignTokens.accent,
      ),
    );
  }
}

class _ConversationList extends ConsumerWidget {
  const _ConversationList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = appColors(context);
    final asyncConvos = ref.watch(conversationsProvider);
    return asyncConvos.when(
      data: (convos) => ListView.builder(
        itemCount: convos.length,
        itemBuilder: (context, i) {
          final c = convos[i];
          return ListTile(
            dense: true,
            title: Text(c.title, overflow: TextOverflow.ellipsis),
            subtitle: Text(_relative(c.updatedAt),
                style: TextStyle(fontSize: 11, color: colors.textSecondary)),
            onTap: () =>
                ref.read(chatNotifierProvider.notifier).open(id: c.id),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat: $e')),
    );
  }

  String _relative(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'baru saja';
    if (d.inHours < 1) return '${d.inMinutes}m lalu';
    if (d.inDays < 1) return '${d.inHours}j lalu';
    return '${d.inDays}h lalu';
  }
}

class _ConversationDrawer extends StatelessWidget {
  const _ConversationDrawer();

  @override
  Widget build(BuildContext context) {
    return const Drawer(child: _ConversationList());
  }
}

class _ChatSearchDelegate extends SearchDelegate<String?> {
  _ChatSearchDelegate(this._repo);

  final ChatRepository _repo;

  @override
  Widget buildSuggestions(BuildContext context) => _build(context);

  @override
  Widget buildResults(BuildContext context) => _build(context);

  Widget _build(BuildContext context) {
    final colors = appColors(context);
    return FutureBuilder(
      future: query.isEmpty ? Future.value(<MessageHit>[]) : _repo.search(query),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snap.data!;
        if (rows.isEmpty) {
          return Center(
              child: Text(query.isEmpty ? 'Ketik untuk mencari' : 'Tidak ada hasil',
                  style: TextStyle(color: colors.textSecondary)));
        }
        return ListView.builder(
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final m = rows[i];
            return ListTile(
              title: Text(m.content, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text('${m.role} · percakapan #${m.conversationId}',
                  style: TextStyle(fontSize: 11, color: colors.textSecondary)),
              onTap: () => close(context, m.content),
            );
          },
        );
      },
    );
  }

  @override
  TextInputType get keyboardType => TextInputType.text;

  @override
  List<Widget>? buildActions(BuildContext context) => null;

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );
}
