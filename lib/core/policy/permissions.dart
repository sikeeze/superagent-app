import 'package:flutter/foundation.dart';

/// Risk levels for tool calls and agent actions (blueprint 6.6).
///
/// The level decides whether an action runs automatically, needs explicit
/// user confirmation, or is refused outright. The decision is always made
/// by this engine (code), never by the model (rules S-41, 10A.1).
enum RiskLevel {
  /// Read public data, compute, summarise. Runs automatically.
  low,

  /// Write to the sandbox folder, call an API with a stored key. Runs
  /// automatically when the active skill already grants the permission.
  medium,

  /// Move funds, sign, send messages, delete data, change permissions.
  /// Always requires human confirmation (plus device authentication) in
  /// Manual mode. In Auto modes the engine decides deterministically.
  high,

  /// Export private keys, disable audit, reach outside the sandbox.
  /// Refused in every mode, no exceptions.
  forbidden,
}

/// Permissions a tool can declare (blueprint 5.3).
enum Permission { network, files, notify, clipboard, terminal, sign }

/// Declarative description of a tool, used by the policy engine to decide
/// what the agent may do without asking (blueprint 5.3, 6.6).
@immutable
class ToolSpec {
  const ToolSpec({
    required this.name,
    required this.description,
    required this.inputSchema,
    required this.risk,
    this.permissions = const <Permission>[],
    this.timeoutMs = 30000,
  });

  /// JSON-schema-ish description shown to the model and reviewed by the user.
  final Map<String, dynamic> inputSchema;
  final String name;
  final String description;
  final RiskLevel risk;
  final List<Permission> permissions;
  final int timeoutMs;
}

///Outcome of a policy check.
@immutable
class PolicyDecision {
  const PolicyDecision({
    required this.allowed,
    required this.reason,
    this.needsConfirmation = false,
  });

  final bool allowed;
  final String reason;
  final bool needsConfirmation;

  /// Convenience for the audit logger.
  Map<String, dynamic> toMap() => <String, dynamic>{
        'allowed': allowed,
        'reason': reason,
        'needs_confirmation': needsConfirmation,
      };
}

/// Base class for all errors raised by the policy layer.
class PolicyException implements Exception {
  PolicyException(this.message);
  final String message;
  @override
  String toString() => 'PolicyException: $message';
}
