import 'package:flutter/foundation.dart';

import '../policy/permissions.dart';

/// Outcome of a tool invocation.
@immutable
class ToolResult {
  const ToolResult({required this.success, required this.output, this.error});

  final bool success;
  final String output;
  final String? error;

  factory ToolResult.ok(String output) =>
      ToolResult(success: true, output: output);

  factory ToolResult.fail(String error) =>
      ToolResult(success: false, output: error, error: error);
}

/// Signature every builtin tool implements.
typedef ToolHandler = Future<ToolResult> Function(Map<String, dynamic> args);

/// Registry of tools the agent is allowed to call (blueprint 5.3).
///
/// Tools are registered once at bootstrap; the agent loop looks them up by
/// name and the policy engine vets each call before it runs. A tool that
/// is not registered cannot be invoked at all.
class ToolRegistry {
  ToolRegistry();

  final Map<String, _Entry> _tools = <String, _Entry>{};

  void register({
    required String name,
    required String description,
    required Map<String, dynamic> inputSchema,
    required RiskLevel risk,
    required List<Permission> permissions,
    required ToolHandler handler,
    int timeoutMs = 30000,
  }) {
    _tools[name] = _Entry(
      spec: ToolSpec(
        name: name,
        description: description,
        inputSchema: inputSchema,
        risk: risk,
        permissions: permissions,
        timeoutMs: timeoutMs,
      ),
      handler: handler,
    );
  }

  /// True when a tool with this exact name exists.
  bool has(String name) => _tools.containsKey(name);

  /// Spec for the model's tool catalogue and for policy vetting.
  ToolSpec? spec(String name) => _tools[name]?.spec;

  /// Every registered spec, used to build the request's `tools` array.
  List<ToolSpec> get specs =>
      _tools.values.map((e) => e.spec).toList(growable: false);

  /// Runs a vetted tool call. Timeouts are enforced per spec (blueprint 3.2).
  Future<ToolResult> invoke(String name, Map<String, dynamic> args) async {
    final entry = _tools[name];
    if (entry == null) {
      return ToolResult.fail('Tool "$name" tidak terdaftar.');
    }
    try {
      return await entry.handler(args)
          .timeout(Duration(milliseconds: entry.spec.timeoutMs));
    } catch (e) {
      return ToolResult.fail('Tool error: $e');
    }
  }
}

class _Entry {
  _Entry({required this.spec, required this.handler});
  final ToolSpec spec;
  final ToolHandler handler;
}
