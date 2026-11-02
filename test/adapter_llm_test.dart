import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superagent/core/llm/anthropic.dart';
import 'package:superagent/core/llm/openai_compat.dart';
import 'package:superagent/core/llm/provider.dart';

/// Adapter-level tests for the bugs found in Audit 2:
/// tool-call fragment accumulation, CRLF framing, multi-line Anthropic
/// frames, tool-result round-trip, and 4xx handling in testConnection.
void main() {
  group('OpenAiCompatibleProvider', () {
    test('fragmen tool_call terakumulasi menjadi argumen utuh', () async {
      final dio = _MockDio(frames: [
        jsonEncode({
          'choices': [
            {
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'id': 'call_1',
                    'function': {'name': 'http_request', 'arguments': '{"ur'},
                  }
                ]
              }
            }
          ]
        }),
        jsonEncode({
          'choices': [
            {
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'function': {'arguments': 'l":"https://a.example.com"}'},
                  }
                ]
              }
            }
          ]
        }),
        jsonEncode({
          'choices': [
            {'delta': {}, 'finish_reason': 'tool_calls'}
          ]
        }),
        '[DONE]',
      ]);

      final p = OpenAiCompatibleProvider(
        baseUrl: 'https://api.openai.com/v1',
        apiKey: 'sk-test',
        dio: dio,
      );
      final events = await p.chat(const ChatRequest(
        model: 'gpt-4o',
        messages: [ChatMessage(role: 'user', content: 'hai')],
      )).toList();

      final calls = events.whereType<ToolCall>().toList();
      expect(calls.length, 1, reason: 'satu tool call, bukan dua setengah');
      expect(calls.first.id, 'call_1');
      expect(calls.first.name, 'http_request');
      expect(calls.first.arguments['url'], 'https://a.example.com');
      expect(events.whereType<Done>().length, 1);
    });

    test('CRLF framing: \\r\\n\\r\\n dipecah dengan benar', () async {
      final dio = _MockDio(rawBody: [
        'data: {"choices":[{"delta":{"content":"A"}}]}\r\n\r\n'
            'data: {"choices":[{"delta":{"content":"B"}}]}\r\n\r\n'
            'data: [DONE]\r\n\r\n',
      ]);
      final p = OpenAiCompatibleProvider(
        baseUrl: 'https://x',
        apiKey: 'k',
        dio: dio,
      );
      final events = await p.chat(const ChatRequest(
        model: 'm',
        messages: [ChatMessage(role: 'user', content: 'hai')],
      )).toList();
      final text = events.whereType<TextDelta>().map((e) => e.text).join();
      expect(text, 'AB', reason: 'stream CRLF harus ter-frame');
      expect(events.whereType<Done>().length, 1);
    });

    test('testConnection menolak 401 (key salah)', () async {
      final dio = _MockDio(statusCode: 401);
      final p = OpenAiCompatibleProvider(
        baseUrl: 'https://x',
        apiKey: 'bad',
        dio: dio,
      );
      expect(await p.testConnection(), isFalse);
    });

    test('testConnection menerima 200', () async {
      final dio = _MockDio(statusCode: 200, getBody: '{"data":[]}');
      final p = OpenAiCompatibleProvider(
        baseUrl: 'https://x',
        apiKey: 'good',
        dio: dio,
      );
      expect(await p.testConnection(), isTrue);
    });

    test('pesan assistant dengan tool_calls diserialkan', () async {
      final dio = _MockDio(frames: ['[DONE]']);
      final p = OpenAiCompatibleProvider(
        baseUrl: 'https://x',
        apiKey: 'k',
        dio: dio,
      );
      await p.chat(const ChatRequest(
        model: 'm',
        messages: [
          ChatMessage(role: 'user', content: 'ambil data'),
          ChatMessage(
            role: 'assistant',
            content: '',
            toolCalls: [
              ToolCall(id: 'call_1', name: 'http_request', arguments: {'url': 'https://a.example.com'}),
            ],
          ),
          ChatMessage(role: 'tool', content: 'ok', toolCallId: 'call_1'),
        ],
      )).toList();

      final body = dio.lastBody as Map<String, dynamic>;
      final msgs = body['messages'] as List;
      final assistant = msgs[1] as Map<String, dynamic>;
      expect(assistant['role'], 'assistant');
      expect((assistant['tool_calls'] as List).length, 1);
      final tool = msgs[2] as Map<String, dynamic>;
      expect(tool['role'], 'tool');
      expect(tool['tool_call_id'], 'call_1');
    });
  });

  group('AnthropicProvider', () {
    test('frame multi-line (event: + data:) terdekode', () async {
      final dio = _MockDio(rawBody: [
        'event: content_block_delta\n'
            'data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Halo"}}\n\n',
        'event: message_stop\ndata: {"type":"message_stop"}\n\n',
      ]);
      final p = AnthropicProvider(
        baseUrl: 'https://api.anthropic.com',
        apiKey: 'k',
        dio: dio,
      );
      final events = await p.chat(const ChatRequest(
        model: 'claude-sonnet-4-5',
        messages: [ChatMessage(role: 'user', content: 'hai')],
      )).toList();

      final text = events.whereType<TextDelta>().map((e) => e.text).join();
      expect(text, 'Halo',
          reason: 'event: dan data: adalah dua baris dalam satu frame');
      expect(events.whereType<Done>().length, 1);
    });

    test('tool_use: argumen direkonstruksi dari input_json_delta', () async {
      final dio = _MockDio(rawBody: [
        'event: content_block_start\n'
            'data: {"type":"content_block_start","index":1,"content_block":{"type":"tool_use","id":"tu_1","name":"http_request"}}\n\n',
        'event: content_block_delta\n'
            'data: {"type":"content_block_delta","index":1,"delta":{"type":"input_json_delta","partial_json":"{\\"ur"}}\n\n',
        'event: content_block_delta\n'
            'data: {"type":"content_block_delta","index":1,"delta":{"type":"input_json_delta","partial_json":"l\\":\\"https://b.example.com\\"}"}}\n\n',
        'event: content_block_stop\n'
            'data: {"type":"content_block_stop","index":1}\n\n',
        'event: message_stop\ndata: {"type":"message_stop"}\n\n',
      ]);
      final p = AnthropicProvider(
        baseUrl: 'https://api.anthropic.com',
        apiKey: 'k',
        dio: dio,
      );
      final events = await p.chat(const ChatRequest(
        model: 'claude-sonnet-4-5',
        messages: [ChatMessage(role: 'user', content: 'ambil data')],
      )).toList();

      final calls = events.whereType<ToolCall>().toList();
      expect(calls.length, 1, reason: 'tool call hanya muncul saat block stop');
      expect(calls.first.id, 'tu_1');
      expect(calls.first.name, 'http_request');
      expect(calls.first.arguments['url'], 'https://b.example.com');
    });

    test('pesan assistant dengan tool_calls jadi content block tool_use',
        () async {
      final dio = _MockDio(rawBody: ['event: message_stop\ndata: {}\n\n']);
      final p = AnthropicProvider(
        baseUrl: 'https://api.anthropic.com',
        apiKey: 'k',
        dio: dio,
      );
      await p.chat(const ChatRequest(
        model: 'm',
        messages: [
          ChatMessage(role: 'user', content: 'ambil data'),
          ChatMessage(
            role: 'assistant',
            content: '',
            toolCalls: [
              ToolCall(id: 'tu_1', name: 'http_request', arguments: {'url': 'https://b.example.com'}),
            ],
          ),
          ChatMessage(role: 'tool', content: 'ok', toolCallId: 'tu_1'),
        ],
      )).toList();

      final body = dio.lastBody as Map<String, dynamic>;
      final msgs = body['messages'] as List;
      // user, assistant(tool_use), user(tool_result)
      expect(msgs.length, 3);
      final assistant = msgs[1] as Map<String, dynamic>;
      expect(assistant['role'], 'assistant');
      final content = assistant['content'] as List;
      final toolUse = content.where((b) => (b as Map)['type'] == 'tool_use');
      expect(toolUse.length, 1);
      final toolResult = msgs[2] as Map<String, dynamic>;
      expect(toolResult['role'], 'user');
      final blocks = toolResult['content'] as List;
      expect((blocks.first as Map)['type'], 'tool_result');
    });

    test('testConnection menolak 403', () async {
      final dio = _MockDio(statusCode: 403);
      final p = AnthropicProvider(
        baseUrl: 'https://api.anthropic.com',
        apiKey: 'bad',
        dio: dio,
      );
      expect(await p.testConnection(), isFalse);
    });
  });
}

/// Dio minimal untuk tes: GET mengembalikan [getBody], POST mengirim stream
/// SSE yang sudah disiapkan. Semua metode lain lewat ke `noSuchMethod`.
class _MockDio implements Dio {
  _MockDio({
    List<String>? frames,
    List<String>? rawBody,
    this.statusCode = 200,
    this.getBody = '{}',
  }) {
    if (rawBody != null) {
      _postStream = _streamFrom(rawBody);
    } else if (frames != null) {
      _postStream = _streamFromFrames(frames);
    } else {
      _postStream = _streamFromFrames(const ['[DONE]']);
    }
  }

  late final Stream<Uint8List> _postStream;
  final int statusCode;
  final String getBody;

  /// Body JSON request POST terakhir (untuk assert bentuk payload).
  dynamic lastBody;

  Stream<Uint8List> _streamFromFrames(List<String> frames) =>
      Stream.fromIterable(frames.map((f) => Uint8List.fromList(utf8.encode('data: $f\n\n'))));

  Stream<Uint8List> _streamFrom(List<String> rawBody) {
    if (rawBody.isEmpty) {
      return Stream.fromIterable([Uint8List(0)]);
    }
    // CRLF bodies sering datang sebagai satu string panjang; pecah per frame
    // supaya mock mengirim chunk seperti server sungguhan.
    final frames = <String>[];
    for (final part in rawBody) {
      frames.addAll(part.split(RegExp(r'\r?\n\r?\n')));
    }
    return Stream.fromIterable(
      frames.where((f) => f.trim().isNotEmpty).map((f) {
        final sep = f.endsWith('\n') ? '' : '\n\n';
        return Uint8List.fromList(utf8.encode('$f$sep'));
      }),
    );
  }

  @override
  Future<Response<T>> get<T>(String path,
      {Options? options,
      Map<String, dynamic>? queryParameters,
      Object? data,
      CancelToken? cancelToken,
      void Function(int, int)? onReceiveProgress,
      void Function(int, int)? onSendProgress}) async {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: statusCode,
      data: _decodeBody(),
    );
  }

  dynamic _decodeBody() {
    // Adapter meminta Map<String,dynamic>; mock menyimpan body sebagai
    // string JSON, jadi decode dulu agar tipe cocok.
    if (getBody.startsWith('{') || getBody.startsWith('[')) {
      return jsonDecode(getBody);
    }
    return getBody;
  }

  @override
  Future<Response<T>> post<T>(String path,
      {Object? data,
      Options? options,
      Map<String, dynamic>? queryParameters,
      CancelToken? cancelToken,
      void Function(int, int)? onSendProgress,
      void Function(int, int)? onReceiveProgress}) async {
    lastBody = data;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: statusCode,
      data: ResponseBody(_postStream, statusCode) as T,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('MockDio: ${invocation.memberName}');
}
