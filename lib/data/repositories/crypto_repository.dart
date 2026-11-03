import 'package:drift/drift.dart';

import '../../data/database/app_database.dart';

/// Repository modul crypto (Fase 7).
///
/// **Read-only:** hanya alamat publik + pengaturan yang disimpan.
/// Tidak ada kunci privat, seed phrase, atau API key exchange di repo ini.
class CryptoRepository {
  CryptoRepository(this._db);

  final AppDatabase _db;

  // --- Watch wallets ------------------------------------------------------

  Future<List<WatchWallet>> wallets() {
    final q = _db.select(_db.watchWallets)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return q.get();
  }

  Stream<List<WatchWallet>> watchWallets() {
    final q = _db.select(_db.watchWallets)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return q.watch();
  }

  Future<int> addWallet({
    required String label,
    required String address,
    int chainId = 56,
    String? rpcUrl,
    double? alertThreshold,
  }) {
    return _db.into(_db.watchWallets).insert(WatchWalletsCompanion.insert(
          label: label,
          address: address,
          chainId: Value(chainId),
          rpcUrl: Value(rpcUrl),
          alertThreshold: Value(alertThreshold),
        ));
  }

  Future<int> removeWallet(int id) {
    return (_db.delete(_db.watchWallets)..where((t) => t.id.equals(id))).go();
  }

  // --- On-chain settings ----------------------------------------------------

  /// Ambil pengaturan; buat default bila belum ada (id selalu 1).
  Future<OnchainSetting> settings() async {
    final q = _db.select(_db.onchainSettings)..where((t) => t.id.equals(1));
    final row = await q.getSingleOrNull();
    if (row != null) return row;
    await _db.into(_db.onchainSettings).insert(
          OnchainSettingsCompanion.insert(id: const Value(1)),
        );
    return (await q.getSingle());
  }

  /// Tulis pengaturan (mode batas, V-14/10A.2). Upsert: insert bila belum
  /// ada, update bila sudah (single row id=1).
  Future<void> saveSettings({
    required String mode,
    required double limitPerTx,
    required double limitPerDay,
    required double maxGasGwei,
    required int autoRevertDays,
    DateTime? autoActivatedAt,
  }) {
    return _db.into(_db.onchainSettings).insertOnConflictUpdate(
          OnchainSettingsCompanion.insert(
            id: const Value(1),
            mode: Value(mode),
            limitPerTx: Value(limitPerTx),
            limitPerDay: Value(limitPerDay),
            maxGasGwei: Value(maxGasGwei),
            autoRevertDays: Value(autoRevertDays),
            autoActivatedAt: Value(autoActivatedAt),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  // --- Contract allowlist (N-01, 10A.2) -----------------------------------

  Future<List<ContractAllowlistData>> allowlist() {
    final q = _db.select(_db.contractAllowlist)
      ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]);
    return q.get();
  }

  Future<int> addContract({
    required String address,
    String? label,
    String functions = '*',
  }) {
    return _db.into(_db.contractAllowlist).insert(
          ContractAllowlistCompanion.insert(
            address: address,
            label: Value(label),
            functions: Value(functions),
          ),
        );
  }

  Future<int> removeContract(int id) {
    return (_db.delete(_db.contractAllowlist)..where((t) => t.id.equals(id)))
        .go();
  }
}
