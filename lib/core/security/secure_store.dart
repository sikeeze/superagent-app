import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'redactor.dart';

/// OS-backed secret storage (blueprint rule S-01).
///
/// Android: Keystore. Windows: DPAPI. Secrets NEVER touch SQLite, plain
/// files, logs, crash reports or the LLM context (also A-05, C-04, V-04).
///
/// Because the platform plugins are only available on real devices, a
/// debug fallback ([_MemoryVault]) keeps the same contract on the host
/// machine for tests. It is NEVER used on release builds.
abstract class SecureStore {
  factory SecureStore() {
    if (kReleaseMode) {
      return _KeystoreSecureStore(const FlutterSecureStorage());
    }
    return _DebugSecureStore();
  }

  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<bool> containsKey(String key);
}

/// Namespace prefixes keep the OS keychain organised and prevent collisions.
class SecureKeys {
  const SecureKeys._();

  static const llmApiKey = 'llm.apikey';
  static const exchangeApiKey = 'exchange.apikey';
  static const exchangeApiSecret = 'exchange.apisecret';
  

  /// Auth session tokens (rule A-05).
  static const authAccessToken = 'auth.access_token';
  static const authRefreshToken = 'auth.refresh_token';

  /// Sesi Supabase yang dipersisten (A-05: secure storage, bukan default).
  static const authPersisted = 'auth.persisted_session';

  /// Vault master key material (rule V-01).
  static const vaultKey = 'vault.master';
}

class _KeystoreSecureStore implements SecureStore {
  final FlutterSecureStorage _storage;
  _KeystoreSecureStore(this._storage);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();

  @override
  Future<bool> containsKey(String key) => _storage.containsKey(key: key);
}

/// Host-machine fallback so unit tests can run without a keychain. The data
/// lives in process memory only and is wiped on app exit.
class _DebugSecureStore implements SecureStore {
  final Map<String, String> _vault = {};

  @override
  Future<String?> read(String key) async => _vault[key];

  @override
  Future<void> write(String key, String value) async {
    _vault[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _vault.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _vault.clear();
  }

  @override
  Future<bool> containsKey(String key) async => _vault.containsKey(key);
}

/// Helper: persist a JSON payload containing secret fields.
extension SecureStoreJson on SecureStore {
  Future<void> writeJson(String key, Map<String, dynamic> json) =>
      write(key, jsonEncode(json));

  Future<Map<String, dynamic>?> readJson(String key) async {
    final raw = await read(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      // Corrupt payload: fail closed rather than leaking partial data.
      return null;
    }
  }
}

/// Development-only logger that ALWAYS redacts before printing. Production
/// builds compile this away via [kReleaseMode] guards at call sites.
void secureLog(String tag, String message) {
  if (kDebugMode) {
    debugPrint('[$tag] ${Redactor.redact(message)}');
  }
}
