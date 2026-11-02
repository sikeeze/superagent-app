import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'provider.dart';

/// OpenAI-compatible adapter (blueprint 3.3, 5.1).
///
/// Talks to any endpoint exposing `POST /chat/completions` (OpenAI itself,
/// gateways, Ollama, LM Studio, vLLM). Streaming uses Server-Sent Events;
/// tool calls are normalised into the internal [LlmEvent] format so the
/// agent loop never depends on vendor shape.
class OpenAiCompatibleProvider implements LlmProvider {
  OpenAiCompatibleProvider({
    required this.baseUrl,
    required this.apiKey,
    this.timeout = const Duration(seconds: 60),
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final String baseUrl;
  final String apiKey;
  final Duration timeout;
  final Dio _dio;

  String get _normalizedBase {
    var b = baseUrl.trim();
    while (b.endsWith('/')) {
      b = b.substring(0, b.length - 1);
    }
    return b;
  }

  Map<String, dynamic> _authHeader() => <String, dynamic>{
        'Authorization': 'Bearer $apiKey',
      };

  Options _options() => Options(
        headers: _authHeader(),
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
                displayName: m['id'] as String?,
                contextWindow: m['context_length'] as int?,
              ))
          .where((m) => m.id.isNotEmpty)
          .toList(growable: false);
    } on DioException catch (_) {
      // /models is optional on many gateways: fail soft, allow manual input.
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
    final body = <String, dynamic>{
      'model': request.model,
      'messages': <Map<String, dynamic>>[
        if (request.systemPrompt != null && request.systemPrompt!.isNotEmpty)
          <String, dynamic>{'role': 'system', 'content': request.systemPrompt},
        for (final m in request.messages)
          <String, dynamic>{
            'role': m.role,
            'content': m.content,
            if (m.toolCallId != null) 'tool_call_id': m.toolCallId,
            if (m.toolCalls.isNotEmpty)
              'tool_calls': <Map<String, dynamic>>[
                for (final tc in m.toolCalls)
                  <String, dynamic>{
                    'id': tc.id,
                    'type': 'function',
                    'function': <String, dynamic>{
                      'name': tc.name,
                      'arguments': jsonEncode(tc.arguments),
                    },
                  },
              ],
          },
      ],
      'temperature': request.temperature,
      'max_tokens': request.maxTokens,
      'stream': true,
    };
    if (request.tools.isNotEmpty) {
      body['tools'] = <Map<String, dynamic>>[
        for (final t in request.tools)
          <String, dynamic>{
            'type': 'function',
            'function': <String, dynamic>{
              'name': t.name,
              'description': t.description,
              'parameters': t.inputSchema,
            },
          },
      ];
    }

    final response = await _dio.post<ResponseBody>(
      '$_normalizedBase/chat/completions',
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

  /// Decodes the SSE byte stream into normalised [LlmEvent]s.
  ///
  /// Server-Sent Events are `data: <json>\n\n` frames and `[DONE]` ends the
  /// stream. Frames are consumed incrementally so we never keep duplicated
  /// copies of the whole answer (rule P-04).
  ///
  /// OpenAI streams tool calls in fragments: the first chunk carries the id
  /// and name, later chunks carry slices of the `arguments` JSON string.
  /// The accumulator below rebuilds the full arguments before emitting a
  /// [ToolCall]; a half-string would fail `jsonDecode` and silently strip
  /// the tool of its arguments.
  Stream<LlmEvent> _parseSse(Stream<List<int>> raw) async* {
    final buffer = <int>[];
    final acc = _ToolCallAccumulator();
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
        final line = utf8.decode(frame, allowMalformed: true).trim();
        if (line.isEmpty || !line.startsWith('data:')) continue;
        final payload = line.substring(5).trim();
        if (payload == '[DONE]') {
          for (final tc in acc.flush()) {
            yield tc;
          }
          yield const Done();
          return;
        }
        try {
          final json = jsonDecode(payload) as Map<String, dynamic>;
          for (final event in _decodeChunk(json, acc)) {
            yield event;
          }
        } catch (_) {
          // Skip malformed frames; the stream continues.
        }
      }
    }
    // Stream ended without [DONE]: still honour accumulated tool calls.
    for (final tc in acc.flush()) {
      yield tc;
    }
  }

  /// Maps ONE SSE chunk to events. Text deltas stream straight out; tool
  /// calls accumulate until `finish_reason: tool_calls` (or stream end)
  /// so their arguments are complete.
  List<LlmEvent> _decodeChunk(
    Map<String, dynamic> json,
    _ToolCallAccumulator acc,
  ) {
    final choices = json['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      final usage = json['usage'] as Map<String, dynamic>?;
      if (usage != null) {
        return <LlmEvent>[
          Usage(
            promptTokens: usage['prompt_tokens'] as int? ?? 0,
            completionTokens: usage['completion_tokens'] as int? ?? 0,
          ),
        ];
      }
      return const <LlmEvent>[];
    }
    final choice = choices.first as Map<String, dynamic>;
    final out = <LlmEvent>[];

    final delta = choice['delta'] as Map<String, dynamic>?;
    if (delta != null) {
      final text = delta['content'] as String?;
      if (text != null && text.isNotEmpty) out.add(TextDelta(text));

      final calls = delta['tool_calls'] as List?;
      if (calls != null) {
        for (final c in calls.whereType<Map<String, dynamic>>()) {
          acc.merge(c);
        }
      }
    }

    if (choice['finish_reason'] == 'tool_calls') {
      out.addAll(acc.flush());
    }
    return out;
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

/// Rebuilds [ToolCall]s from streamed fragments (OpenAI sends name and id
/// in the first chunk, then the `arguments` JSON in slices).
class _ToolCallAccumulator {
  final Map<int, _ProtoCall> _pending = {};

  void merge(Map<String, dynamic> chunk) {
    final index = chunk['index'] as int? ?? 0;
    final proto = _pending.putIfAbsent(index, () => _ProtoCall());
    final fn = chunk['function'] as Map<String, dynamic>?;
    if (fn == null) return;
    final id = chunk['id'] as String?;
    if (id != null && id.isNotEmpty) proto.id = id;
    final name = fn['name'] as String?;
    if (name != null && name.isNotEmpty) proto.name = name;
    final args = fn['arguments'] as String?;
    if (args != null) proto.argsBuffer.write(args);
  }

  /// Emits every accumulated call with parsed arguments and resets.
  List<ToolCall> flush() {
    if (_pending.isEmpty) return const <ToolCall>[];
    final out = <ToolCall>[];
    final keys = _pending.keys.toList()..sort();
    for (final k in keys) {
      final p = _pending.remove(k)!;
      Map<String, dynamic> parsed = <String, dynamic>{};
      final raw = p.argsBuffer.toString();
      if (raw.isNotEmpty) {
        try {
          parsed = jsonDecode(raw) as Map<String, dynamic>;
        } catch (_) {
          // Malformed arguments: send an empty payload rather than
          // dropping the call; the policy engine still gets to vet it.
        }
      }
      out.add(ToolCall(id: p.id, name: p.name, arguments: parsed));
    }
    return out;
  }
}

class _ProtoCall {
  String id = '';
  String name = '';
  final StringBuffer argsBuffer = StringBuffer();
}
