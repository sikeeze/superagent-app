import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audit/audit_logger.dart';
import '../../core/policy/policy_engine.dart';
import '../../core/skills/skill_runner.dart';
import '../../core/terminal/terminal_engine.dart';
import '../skills/skills_providers.dart';

/// Provider mesin terminal (disambungkan ke skill store + audit).
final terminalEngineProvider = FutureProvider<TerminalEngine>((ref) async {
  final store = await ref.watch(skillStoreProvider.future);
  final audit = AuditLogger(await _auditPath());
  final runner = SkillRunner(
    store: store,
    policy: PolicyEngine(),
    audit: audit,
    granted: const {},
  );
  return TerminalEngine(store: store, audit: audit, runner: runner);
});

Future<String> _auditPath() async {
  final dir = await skillsRoot();
  return '${dir.parent.path}${Platform.pathSeparator}audit.log';
}

/// Halaman terminal virtual (blueprint 9.2).
///
/// S-23: perintah virtual, bukan shell sistem. Buffer 2000 baris.
/// Riwayat panah atas/bawah; argumen rahasia tidak disimpan (9.3).
class TerminalPage extends ConsumerStatefulWidget {
  const TerminalPage({super.key});

  @override
  ConsumerState<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends ConsumerState<TerminalPage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<TerminalLine> _buffer = [];
  final List<String> _history = [];
  int _historyIndex = -1;
  bool _busy = false;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _inputCtrl.text;
    if (raw.trim().isEmpty) return;
    _inputCtrl.clear();

    setState(() {
      _busy = true;
      _buffer.add(TerminalLine(text: '\$ $raw', kind: LineKind.input));
    });
    _history.add(raw);
    _historyIndex = _history.length;
    _trimBuffer();
    _scrollToBottom();

    final engine = await ref.read(terminalEngineProvider.future);
    final res = await engine.execute(raw);

    if (!mounted) return;
    setState(() {
      _busy = false;
      if (res.clear) {
        _buffer.clear();
      } else {
        _buffer.addAll(res.lines);
        _trimBuffer();
      }
    });
    _scrollToBottom();
  }

  /// 9.3: buffer layar dibatasi (default 2000 baris).
  void _trimBuffer() {
    const max = 2000;
    if (_buffer.length > max) {
      _buffer.removeRange(0, _buffer.length - max);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  void _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_historyIndex > 0) {
        _historyIndex--;
        _inputCtrl.text = _history[_historyIndex];
        _inputCtrl.selection = TextSelection.fromPosition(
            TextPosition(offset: _inputCtrl.text.length));
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_historyIndex < _history.length - 1) {
        _historyIndex++;
        _inputCtrl.text = _history[_historyIndex];
        _inputCtrl.selection = TextSelection.fromPosition(
            TextPosition(offset: _inputCtrl.text.length));
      } else {
        _historyIndex = _history.length;
        _inputCtrl.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mono = TextStyle(
      fontFamily: 'Courier New',
      fontSize: 13,
      color: theme.colorScheme.onSurface,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Terminal')),
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _onKey,
        child: Column(
          children: [
            Expanded(
              // P-01: ListView.builder untuk daftar panjang.
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(8),
                itemCount: _buffer.length,
                itemBuilder: (context, i) {
                  final line = _buffer[i];
                  return Text(
                    line.text,
                    style: mono.copyWith(color: _color(line.kind, theme)),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Text(r'$', style: mono),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      style: mono,
                      autofocus: true,
                      enabled: !_busy,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ketik perintah. "help" untuk bantuan.',
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  if (_busy)
                    const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? _color(LineKind kind, ThemeData theme) {
    switch (kind) {
      case LineKind.input:
        return theme.colorScheme.primary;
      case LineKind.error:
        return theme.colorScheme.error;
      case LineKind.warn:
        return Colors.orange;
      case LineKind.output:
        return null;
    }
  }
}
