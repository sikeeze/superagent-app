import 'package:drift/drift.dart';

/// Skema persistensi chat (blueprint Fase 2).
///
/// Satu database SQLite untuk semua percakapan; API key TIDAK PERNAH
/// disimpan di sini (aturan S-01) — hanya di secure storage. Index dibuat
/// di [AppDatabase] untuk kecepatan pencarian riwayat.
///
/// Kolom [content] menyimpan teks pesan final. Pesan yang sedang
/// streaming ditahan di memori UI dulu, baru ditulis saat selesai —
/// menulis setiap delta ke SQLite akan menghancurkan performa (aturan P-04).
class Conversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant('Percakapan baru'))();
  TextColumn get providerId => text().nullable()();
  TextColumn get model => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  /// Total token perkiraan untuk pemangkasan konteks (sliding window).
  IntColumn get tokenEstimate => integer().withDefault(const Constant(0))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
}

class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationId => integer().references(Conversations, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()(); // 'user' | 'assistant' | 'tool'
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  /// Meta untuk pesan tool: nama tool, status, durasi (ditampilkan sebagai
  /// kartu tool di UI, wireframe A).
  TextColumn get toolName => text().nullable()();
  TextColumn get toolStatus => text().nullable()(); // 'running' | 'ok' | 'failed'
  IntColumn get toolDurationMs => integer().nullable()();
  TextColumn get toolArgsJson => text().nullable()();
}
