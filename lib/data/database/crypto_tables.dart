import 'package:drift/drift.dart';

/// Dompet watch-only (Fase 7: modul crypto read-only).
///
/// Hanya **alamat publik** — tidak ada kunci privat/seed phrase yang disimpan
/// di Fase ini (kriteria roadmap Fase 7: "tidak ada kunci sensitif tersimpan").
/// [alertThreshold] memenuhi V-08: peringatan bila saldo melebihi ambang.
class WatchWallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text()();
  TextColumn get address => text()(); // alamat EVM, 0x…
  IntColumn get chainId => integer().withDefault(const Constant(56))();
  TextColumn get rpcUrl => text().nullable()(); // override RPC per dompet
  /// Ambang saldo (V-08). Null = tanpa peringatan.
  RealColumn get alertThreshold => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Pengaturan eksekusi on-chain (blueprint 10A.2/10A.6).
///
/// Satu baris (id = 1). Mode default: **Manual**.
class OnchainSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  /// 'manual' | 'auto_limited' | 'auto_full'
  TextColumn get mode => text().withDefault(const Constant('manual'))();
  RealColumn get limitPerTx => real().withDefault(const Constant(0.01))();
  RealColumn get limitPerDay => real().withDefault(const Constant(0.05))();
  RealColumn get maxGasGwei => real().withDefault(const Constant(5))();
  IntColumn get autoRevertDays => integer().withDefault(const Constant(7))();
  DateTimeColumn get autoActivatedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column>? get primaryKey => {id};
}

/// Allowlist kontrak (N-01) dan fungsi (10A.2) untuk mode Auto Terbatas.
class ContractAllowlist extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get address => text()(); // alamat kontrak
  TextColumn get label => text().nullable()();
  /// Fungsi yang diizinkan dipanggil di kontrak ini (mis. 'claim', 'mint').
  /// Disimpan sebagai list yang dipisah koma; '*' = semua fungsi.
  TextColumn get functions => text().withDefault(const Constant('*'))();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
}
