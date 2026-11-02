import 'package:flutter/foundation.dart';

import '../policy/permissions.dart';

/// Normalised LLM events shared by every provider adapter (blueprint 3.3).
///
/// Streaming answers arrive as a single event stream; adapters translate
/// their vendor format into these so the agent loop never cares which
/// provider is connected (rule 3.3).
@immutable
sealed class LlmEvent {
  const LlmEvent();
}

/// Incremental text chunk. Buffers stay small (rule P-04).
class TextDelta extends LlmEvent {
  const TextDelta(this.text);
  final String text;
  @override
  String toString() => 'TextDelta(\${text.length} chars)';
}

/// The model wants to call a tool. [name] and [arguments] are already
/// normalised to the internal format.
class ToolCall extends LlmEvent {
  const ToolCall({required this.id, required this.name, required this.arguments});
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  @override
  String toString() => 'ToolCall($name)';
}

/// Token usage and cost accounting for the session budget (rule 3.2).
class Usage extends LlmEvent {
  const Usage({required this.promptTokens, required this.completionTokens});
  final int promptTokens;
  final int completionTokens;
  int get total => promptTokens + completionTokens;
}

/// Stream finished cleanly.
class Done extends LlmEvent {
  const Done();
}

/// Stream failed. [retryable] hints whether backoff should apply.
class LlmError extends LlmEvent {
  const LlmError(this.message, {this.retryable = false});
  final String message;
  final bool retryable;
  @override
  String toString() => 'LlmError($message)';
}

/// Metadata about a model offered by a provider endpoint.
@immutable
class ModelInfo {
  const ModelInfo({required this.id, this.displayName, this.contextWindow});
  final String id;
  final String? displayName;
  final int? contextWindow;

  String get label => displayName ?? id;
}

/// Request payload in the internal normalised format.
@immutable
class ChatRequest {
  const ChatRequest({
    required this.model,
    required this.messages,
    this.systemPrompt,
    this.temperature = 0.2,
    this.maxTokens = 4096,
    this.tools = const <ToolSpec>[],
  });

  final String model;
  final List<ChatMessage> messages;
  final String? systemPrompt;
  final double temperature;
  final int maxTokens;
  final List<ToolSpec> tools;
}

/// One message in the conversation window (rule P-03).
@immutable
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    this.toolCalls = const <ToolCall>[],
    this.toolCallId,
  });

  final String role; // 'system' | 'user' | 'assistant' | 'tool'
  final String content;
  final List<ToolCall> toolCalls;
  final String? toolCallId;
}

/// The single provider contract every adapter implements (blueprint 3.3).
abstract interface class LlmProvider {
  /// Lists models offered by the endpoint. Must tolerate a missing
  /// `/models` route by returning an empty list (blueprint 3.3).
  Future<List<ModelInfo>> listModels();

  /// Streaming chat completion. Events arrive as [LlmEvent]s.
  Stream<LlmEvent> chat(ChatRequest request);

  /// Lightweight reachability + credential check.
  Future<bool> testConnection();
}

/// Vendor flavours the app knows how to talk to (blueprint 3.3, 5.1).
enum ProviderType { openaiCompatible, anthropic }

extension ProviderTypeLabel on ProviderType {
  String get label => switch (this) {
        ProviderType.openaiCompatible => 'OpenAI-compatible',
        ProviderType.anthropic => 'Anthropic',
      };
}
