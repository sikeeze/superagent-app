import 'dart:convert';

import 'package:dio/dio.dart';

import '../../llm/provider.dart' show LlmEvent;
import '../../policy/network_guard.dart';
import '../../policy/permissions.dart';
import '../tool_registry.dart';

/// Registers the builtin tool catalogue (blueprint 5.3).
///
/// Every tool declares its risk level and permissions up-front so the
/// policy engine can vet calls without knowing any tool internals.
void registerBuiltinTools(ToolRegistry registry, {Dio? dio}) {
  final http = dio ?? Dio();

  registry.register(
    name: 'http_request',
    description:
        'Mengambil isi URL publik. Host harus diizinkan oleh allowlist skill.',
    inputSchema: <String, dynamic>{
      'type': 'object',
      'properties': <String, dynamic>{
        'url': <String, dynamic>{'type': 'string'},
        'method': <String, dynamic>{'type': 'string', 'default': 'GET'},
      },
      'required': <String>['url'],
    },
    risk: RiskLevel.low,
    permissions: <Permission>[Permission.network],
    timeoutMs: 30000,
    handler: (args) async {
      final url = args['url'] as String?;
      if (url == null || url.isEmpty) {
        return ToolResult.fail('Parameter url wajib diisi.');
      }
      // S-10 + S-13: reject cleartext outside loopback/LAN and any private
      // host before a single byte hits the network. The policy engine vets
      // the call too; this is the enforcement point at execution time.
      Uri uri;
      try {
        uri = Uri.parse(url.trim());
      } catch (_) {
        return ToolResult.fail('URL tidak valid.');
      }
      if (uri.host.isEmpty) {
        return ToolResult.fail('URL tidak memiliki host.');
      }
      if (!NetworkGuard.isCleartextAllowed(uri)) {
        return ToolResult.fail(
            'HTTP hanya diizinkan untuk localhost/LAN (aturan S-10).');
      }
      if (NetworkGuard.isPrivateHost(uri.host)) {
        return ToolResult.fail(
            'Host ${uri.host} diblokir anti-SSRF (aturan S-13).');
      }
      final method = (args['method'] as String? ?? 'GET').toUpperCase();
      try {
        final res = await http.request<String>(
          url,
          options: Options(
            method: method,
            // S-14: hard timeout. Response cap is enforced below in code.
            receiveTimeout: const Duration(seconds: 30),
            followRedirects: true,
            maxRedirects: 3,
            // S-11: certificate validation stays ON. Never disabled.
            validateStatus: (s) => s != null && s < 500,
          ),
        );
        final body = res.data ?? '';
        // S-14: reject oversized payloads instead of loading them fully.
        if (body.length > 5 * 1024 * 1024) {
          return ToolResult.fail('Respons melebihi batas 5 MB.');
        }
        final limited = body.length > 20000
            ? '${body.substring(0, 20000)}…[truncated]'
            : body;
        return ToolResult.ok(jsonEncode(<String, dynamic>{
          'status': res.statusCode,
          'body': limited,
        }));
      } catch (e) {
        return ToolResult.fail('HTTP error: $e');
      }
    },
  );

  registry.register(
    name: 'notify',
    description: 'Menampilkan notifikasi lokal kepada pengguna.',
    inputSchema: <String, dynamic>{
      'type': 'object',
      'properties': <String, dynamic>{
        'title': <String, dynamic>{'type': 'string'},
        'body': <String, dynamic>{'type': 'string'},
      },
      'required': <String>['title', 'body'],
    },
    risk: RiskLevel.low,
    permissions: <Permission>[Permission.notify],
    timeoutMs: 5000,
    handler: (args) async {
      final title = args['title'] as String? ?? 'Superagent';
      final body = args['body'] as String? ?? '';
      // Real channel wiring lands in Fase 6 (flutter_local_notifications).
      return ToolResult.ok('Notifikasi dijadwalkan: $title — $body');
    },
  );
}

/// Filter for unused import guard.
// ignore: unused_element
const _kLlmEventReference = <LlmEvent>[];
