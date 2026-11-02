import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/llm/provider.dart';
import '../../core/security/secure_store.dart';

/// One saved provider profile (blueprint 5.1).
///
/// The API key lives ONLY in the OS keychain ([SecureStore]); the metadata
/// here is safe to persist anywhere (rule S-01).
@immutable
class ProviderProfile {
  const ProviderProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.baseUrl,
    required this.model,
    this.temperature = 0.2,
    this.maxTokens = 4096,
    this.dailyBudgetUsd = 5.0,
    this.timeoutSeconds = 60,
    this.retries = 2,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final ProviderType type;
  final String baseUrl;
  final String model;
  final double temperature;
  final int maxTokens;
  final double dailyBudgetUsd;
  final int timeoutSeconds;
  final int retries;
  final bool isPrimary;

  ProviderProfile copyWith({
    String? name,
    ProviderType? type,
    String? baseUrl,
    String? model,
    double? temperature,
    int? maxTokens,
    double? dailyBudgetUsd,
    int? timeoutSeconds,
    int? retries,
    bool? isPrimary,
  }) =>
      ProviderProfile(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        baseUrl: baseUrl ?? this.baseUrl,
        model: model ?? this.model,
        temperature: temperature ?? this.temperature,
        maxTokens: maxTokens ?? this.maxTokens,
        dailyBudgetUsd: dailyBudgetUsd ?? this.dailyBudgetUsd,
        timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
        retries: retries ?? this.retries,
        isPrimary: isPrimary ?? this.isPrimary,
      );
}

/// State container for the provider settings page.
@immutable
class ProviderConfigState {
  const ProviderConfigState({
    this.profiles = const <ProviderProfile>[],
    this.activeId,
    this.availableModels = const <ModelInfo>[],
    this.connectionStatus = ConnectionStatus.idle,
    this.lastTestMessage,
    this.lastTestLatencyMs,
  });

  final List<ProviderProfile> profiles;
  final String? activeId;
  final List<ModelInfo> availableModels;
  final ConnectionStatus connectionStatus;
  final String? lastTestMessage;
  final int? lastTestLatencyMs;

  ProviderProfile? get active =>
      profiles.where((p) => p.id == activeId).firstOrNull;

  ProviderConfigState copyWith({
    List<ProviderProfile>? profiles,
    String? activeId,
    List<ModelInfo>? availableModels,
    ConnectionStatus? connectionStatus,
    String? lastTestMessage,
    int? lastTestLatencyMs,
  }) =>
      ProviderConfigState(
        profiles: profiles ?? this.profiles,
        activeId: activeId ?? this.activeId,
        availableModels: availableModels ?? this.availableModels,
        connectionStatus: connectionStatus ?? this.connectionStatus,
        lastTestMessage: lastTestMessage,
        lastTestLatencyMs: lastTestLatencyMs ?? this.lastTestLatencyMs,
      );
}

enum ConnectionStatus { idle, testing, connected, failed }

/// Central provider for provider configuration (blueprint 5.1).
///
/// Navigator/Observable widget rebuilds stay narrow because consumers
/// `select` only the fields they render (rule P-06).
class ProviderConfigNotifier
    extends StateNotifier<ProviderConfigState> {
  ProviderConfigNotifier(this._secure) : super(const ProviderConfigState());

  final SecureStore _secure;

  /// Loads metadata and the id of the active profile from the keychain.
  Future<void> load() async {
    final json = await _secure.readJson('provider.profiles');
    if (json == null) return;
    final list = (json['profiles'] as List? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(_profileFromJson)
        .whereType<ProviderProfile>()
        .toList(growable: false);
    state = state.copyWith(
      profiles: list,
      activeId: json['active_id'] as String?,
    );
  }

  Future<void> _persist() async {
    await _secure.writeJson('provider.profiles', <String, dynamic>{
      'profiles': <Map<String, dynamic>>[
        for (final p in state.profiles) _profileToJson(p),
      ],
      'active_id': state.activeId,
    });
  }

  /// Saves or replaces a profile and persists metadata only.
  ///
  /// Upsert semantics: [profile] always lands in the list and any existing
  /// entry with the same id is replaced. The `if (!exists) profile` guard
  /// that used to sit here dropped the profile on update, turning an edit
  /// into a silent delete.
  Future<void> saveProfile(ProviderProfile profile, {String? apiKey}) async {
    final next = <ProviderProfile>[
      profile,
      for (final p in state.profiles)
        if (p.id != profile.id) p,
    ];
    state = state.copyWith(
      profiles: next,
      activeId: state.activeId ?? profile.id,
    );
    if (apiKey != null && apiKey.isNotEmpty) {
      await _secure.write('${SecureKeys.llmApiKey}.${profile.id}', apiKey);
    }
    await _persist();
  }

  Future<void> deleteProfile(String id) async {
    state = state.copyWith(
      profiles: state.profiles.where((p) => p.id != id).toList(growable: false),
      activeId: state.activeId == id ? null : state.activeId,
    );
    await _secure.delete('${SecureKeys.llmApiKey}.$id');
    await _persist();
  }

  Future<void> setActive(String id) async {
    state = state.copyWith(activeId: id);
    await _persist();
  }

  Future<String?> apiKeyFor(String profileId) =>
      _secure.read('${SecureKeys.llmApiKey}.$profileId');

  ProviderProfile? profileById(String id) =>
      state.profiles.where((p) => p.id == id).firstOrNull;

  Map<String, dynamic> _profileToJson(ProviderProfile p) =>
      <String, dynamic>{
        'id': p.id,
        'name': p.name,
        'type': p.type.name,
        'base_url': p.baseUrl,
        'model': p.model,
        'temperature': p.temperature,
        'max_tokens': p.maxTokens,
        'daily_budget_usd': p.dailyBudgetUsd,
        'timeout_seconds': p.timeoutSeconds,
        'retries': p.retries,
        'is_primary': p.isPrimary,
      };

  ProviderProfile? _profileFromJson(Map<String, dynamic> m) {
    final type = ProviderType.values
        .where((t) => t.name == (m['type'] as String?))
        .firstOrNull;
    if (type == null) return null;
    return ProviderProfile(
      id: m['id'] as String? ?? '',
      name: m['name'] as String? ?? '',
      type: type,
      baseUrl: m['base_url'] as String? ?? '',
      model: m['model'] as String? ?? '',
      temperature: (m['temperature'] as num?)?.toDouble() ?? 0.2,
      maxTokens: m['max_tokens'] as int? ?? 4096,
      dailyBudgetUsd: (m['daily_budget_usd'] as num?)?.toDouble() ?? 5.0,
      timeoutSeconds: m['timeout_seconds'] as int? ?? 60,
      retries: m['retries'] as int? ?? 2,
      isPrimary: m['is_primary'] as bool? ?? false,
    );
  }
}

/// Riverpod wiring.
final providerConfigProvider =
    StateNotifierProvider<ProviderConfigNotifier, ProviderConfigState>(
  (ref) => ProviderConfigNotifier(SecureStore()),
);
