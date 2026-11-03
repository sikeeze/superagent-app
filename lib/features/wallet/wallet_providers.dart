import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/crypto/wallet_watcher.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/crypto_repository.dart';
import '../task/task_providers.dart' show appDatabaseProvider;

/// Repository crypto (Fase 7).
final cryptoRepositoryProvider = FutureProvider<CryptoRepository>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return CryptoRepository(db);
});

/// Daftar dompet watch-only (stream DB).
final walletListProvider = StreamProvider<List<WatchWallet>>((ref) async* {
  final repo = await ref.watch(cryptoRepositoryProvider.future);
  yield* repo.watchWallets();
});

/// Pengaturan on-chain (10A.2). Single row id=1.
final onchainSettingsProvider =
    FutureProvider<OnchainSetting?>((ref) async {
  final repo = await ref.watch(cryptoRepositoryProvider.future);
  return repo.settings();
});

/// Kill switch state (K-01) — dipantau UI.
final killSwitchProvider = StateProvider<bool>((ref) {
  return KillSwitch.instance.stopped;
});

/// Notifier pemantau saldo watch-only.
class WalletNotifier extends StateNotifier<AsyncValue<void>> {
  WalletNotifier(this._repo, this._audit) : super(const AsyncValue.data(null));

  final CryptoRepository _repo;
  final dynamic _audit;

  late final WalletWatcher _watcher = WalletWatcher(
    repo: _repo,
    audit: _audit,
  );

  Future<Map<int, BigInt>> refresh() => _watcher.refresh();

  Future<void> addWallet({
    required String label,
    required String address,
    int chainId = 56,
  }) {
    return _repo.addWallet(
      label: label,
      address: address,
      chainId: chainId,
    );
  }

  Future<void> removeWallet(int id) => _repo.removeWallet(id);

  @override
  void dispose() {
    _watcher.stop();
    super.dispose();
  }
}

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<void>>((ref) {
  throw UnimplementedError('override di main()');
});
