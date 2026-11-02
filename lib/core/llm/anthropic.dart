import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'provider.dart';

/// Anthropic adapter (blueprint 3.3).
///
/// Uses `POST /v1/messages` with the `x-api-key` header and
/// `anthropic-version`. Streaming uses SSE `event:` / `data:` frames:
/// `content_block_delta` carries text deltas, `message_delta` carries the
/// stop reason, and `message_stop` ends the stream.
class AnthropicProvider implements LlmProvider {
  AnthropicProvider({
    required this.baseUrl,
    required this.apiKey,
    this.timeout = const Duration(seconds: 60),
    this.anthropicVersion = '2023-06-01',
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final String baseUrl;
  final String apiKey;
  final Duration timeout;
  final String anthropicVersion;
  final Dio _dio;

  String get _normalizedBase {
    var b = baseUrl.trim();
    while (b.endsWith('/')) {
      b = b.substring(0, b.length - 1);
    }
    return b;
  }

  Map<String, dynamic> _headers() => <String, dynamic>{
        'x-api-key': apiKey,
        'anthropic-version': anthropicVersion,
        'content-type': 'application/json',
      };

  Options _options() => Options(
        headers: _headers(),
        sendTimeout: timeout,
        receiveTimeout: timeout,
      );

  @override
  Future<List<ModelInfo>> listModels() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_normalizedBase/models',
        options: _options(),
      );
      final data = res.data?['data'];
      if (data is! List) return const <ModelInfo>[];
      return data
          .whereType<Map<String, dynamic>>()
          .map((m) => ModelInfo(
                id: m['id'] as String? ?? '',
                displayName: m['display_name'] as String?,
                contextWindow: m['context_window'] as int?,
              ))
          .where((m) => m.id.isNotEmpty)
          .toList(growable: false);
    } on DioException catch (_) {
      return const <ModelInfo>[];
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_normalizedBase/models',
        options: _options(),
      );
      // 4xx (bad key, wrong path) is NOT a connection: only 2xx counts.
      final code = res.statusCode;
      return code != null && code >= 200 && code < 300;
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<LlmEvent> chat(ChatRequest request) async* {
    // Anthropic takes the system prompt outside of the messages array.
    final body = <String, dynamic>{
      'model': request.model,
      'max_tokens': request.maxTokens,
      'temperature': request.temperature,
      'stream': true,
      if (request.systemPrompt != null && request.systemPrompt!.isNotEmpty)
        'system': request.systemPrompt,
      'messages': <Map<String, dynamic>>[
        for (final m in request.messages)
          if (m.role == 'user')
            <String, dynamic>{
              'role': m.role,
              'content': m.content,
            }
          else if (m.role == 'assistant')
            // An assistant turn may carry tool calls: Anthropic expects
            // them as content blocks, not hidden in the message envelope.
            <String, dynamic>{
              'role': m.role,
              'content': <Map<String, dynamic>>[
                if (m.content.isNotEmpty)
                  <String, dynamic>{'type': 'text', 'text': m.content},
                for (final tc in m.toolCalls)
                  <String, dynamic>{
                    'type': 'tool_use',
                    'id': tc.id,
                    'name': tc.name,
                    'input': tc.arguments,
                  },
              ],
            }
          else if (m.role == 'tool')
            // Anthropic carries tool results as a user message containing
            // a tool_result block, not a separate role.
            <String, dynamic>{
              'role': 'user',
              'content': <Map<String, dynamic>>[
                <String, dynamic>{
                  'type': 'tool_result',
                  'tool_use_id': m.toolCallId ?? '',
                  'content': m.content,
                },
              ],
            },
      ],
    };
    if (request.tools.isNotEmpty) {
      body['tools'] = <Map<String, dynamic>>[
        for (final t in request.tools)
          <String, dynamic>{
            'name': t.name,
            'description': t.description,
            'input_schema': t.inputSchema,
          },
      ];
    }

    final response = await _dio.post<ResponseBody>(
      '$_normalizedBase/messages',
      data: body,
      options: _options().copyWith(responseType: ResponseType.stream),
    );

    final stream = response.data?.stream;
    if (stream == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Empty response stream.',
      );
    }

    yield* _parseSse(stream);
  }

  /// Decodes Anthropic SSE frames into normalised events.
  ///
  /// Frame shape: `event: <type>\ndata: <json>\n\n` — the event name and
  /// the payload are TWO LINES OF ONE FRAME, so each frame is split on
  /// newlines before the fields are read. Reading the whole frame as a
  /// single line (an earlier version did `frame.startsWith('event:')`)
  /// swallowed the payload and decoded nothing at all.
  ///
  /// Tool arguments arrive as `input_json_delta` fragments after
  /// `content_block_start`; the accumulator rebuilds them and the ToolCall
  /// is only emitted at `content_block_stop`.
  Stream<LlmEvent> _parseSse(Stream<List<int>> raw) async* {
    final buffer = <int>[];
    final acc = _AnthropicToolAccumulator();
    await for (final chunk in raw) {
      buffer.addAll(chunk);
      while (true) {
        final sep = _indexOfSeparator(buffer);
        if (sep < 0) break;
        final isCrlf = sep + 3 < buffer.length &&
            buffer[sep] == 13 &&
            buffer[sep + 1] == 10;
        final frame = buffer.sublist(0, sep);
        buffer.removeRange(0, sep + (isCrlf ? 4 : 2));
        final text = utf8.decode(frame, allowMalformed: true);

        String? type;
        String? payload;
        for (final line in text.split('\n')) {
          final l = line.trim();
          if (l.startsWith('event:')) {
            type = l.substring(6).trim();
          } else if (l.startsWith('data:')) {
            payload = l.substring(5).trim();
          }
        }
        if (payload == null || payload.isEmpty) continue;

        try {
          final json = jsonDecode(payload) as Map<String, dynamic>;
          for (final event in _decodeFrame(type, json, acc)) {
            yield event;
          }
        } catch (_) {
          // Skip malformed frames; the stream continues.
        }
      }
    }
    // Stream ended early: still honour half-sent tool calls.
    for (final tc in acc.flush()) {
      yield tc;
    }
  }

  List<LlmEvent> _decodeFrame(
    String? type,
    Map<String, dynamic> json,
    _AnthropicToolAccumulator acc,
  ) {
    switch (type) {
      case 'content_block_start':
        final block = json['content_block'] as Map<String, dynamic>?;
        if (block != null && block['type'] == 'tool_use') {
          acc.startBlock(
            index: json['index'] as int? ?? 0,
            id: block['id'] as String? ?? '',
            name: block['name'] as String? ?? '',
          );
        }
        return const <LlmEvent>[];
      case 'content_block_delta':
        final delta = json['delta'] as Map<String, dynamic>?;
        if (delta == null) return const <LlmEvent>[];
        if (delta['type'] == 'text_delta') {
          final text = delta['text'] as String?;
          if (text != null && text.isNotEmpty) {
            return <LlmEvent>[TextDelta(text)];
          }
        }
        if (delta['type'] == 'input_json_delta') {
          acc.appendJson(
            index: json['index'] as int? ?? 0,
            partial: delta['partial_json'] as String? ?? '',
          );
        }
        return const <LlmEvent>[];
      case 'content_block_stop':
        final tc = acc.stopBlock(json['index'] as int? ?? 0);
        return tc != null ? <LlmEvent>[tc] : const <LlmEvent>[];
      case 'message_delta':
        final usage = json['usage'] as Map<String, dynamic>?;
        if (usage != null) {
          return <LlmEvent>[
            Usage(
              promptTokens: usage['input_tokens'] as int? ?? 0,
              completionTokens: usage['output_tokens'] as int? ?? 0,
            ),
          ];
        }
        return const <LlmEvent>[];
      case 'message_stop':
        return const <LlmEvent>[Done()];
      default:
        return const <LlmEvent>[];
    }
  }

  int _indexOfSeparator(List<int> data) {
    for (var i = 0; i < data.length - 1; i++) {
      // `\n\n` or `\r\n\r\n`; strictly-CRLF servers never frame on `\n\n`.
      if (data[i] == 10 && data[i + 1] == 10) return i;
      if (data[i] == 13 && data[i + 1] == 10 && i + 3 < data.length) {
        if (data[i + 2] == 13 && data[i + 3] == 10) return i;
      }
    }
    return -1;
  }
}

/// Rebuilds Anthropic tool calls from stream fragments: `content_block_start`
/// carries id and name, the following `input_json_delta` deltas carry the
/// argument JSON in slices, `content_block_stop` closes the block.
class _AnthropicToolAccumulator {
  final Map<int, _AnthropicProtoCall> _blocks = {};

  void startBlock({required int index, required String id, required String name}) {
    _blocks[index] = _AnthropicProtoCall(id: id, name: name);
  }

  void appendJson({required int index, required String partial}) {
    _blocks[index]?.argsBuffer.write(partial);
  }

  /// Closes one block and returns its tool call, if it was a tool block.
  ToolCall? stopBlock(int index) {
    final p = _blocks.remove(index);
    if (p == null) return null;
    return _finish(p);
  }

  /// Closes all remaining blocks (stream ended without message_stop).
  List<ToolCall> flush() {
    if (_blocks.isEmpty) return const <ToolCall>[];
    final out = <ToolCall>[];
    final keys = _blocks.keys.toList()..sort();
    for (final k in keys) {
      final p = _blocks.remove(k)!;
      out.add(_finish(p));
    }
    return out;
  }

  ToolCall _finish(_AnthropicProtoCall p) {
    Map<String, dynamic> parsed = <String, dynamic>{};
    final raw = p.argsBuffer.toString();
    if (raw.isNotEmpty) {
      try {
        parsed = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        // Malformed arguments: keep the call so the policy engine still
        // vets it, with an empty payload.
      }
    }
    return ToolCall(id: p.id, name: p.name, arguments: parsed);
  }
}

class _AnthropicProtoCall {
  _AnthropicProtoCall({required this.id, required this.name});
  final String id;
  final String name;
  final StringBuffer argsBuffer = StringBuffer();
}
