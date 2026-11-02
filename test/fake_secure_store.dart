import 'package:superagent/core/security/secure_store.dart';

/// In-memory [SecureStore] for tests: same contract, no keychain needed.
class FakeSecureStore implements SecureStore {
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
