import 'package:drift/drift.dart';

/// Tabel tasks: prompt + skill + jadwal (blueprint 5.4).
///
/// Status: pending | running | waiting_confirmation | done | failed | cancelled.
/// Antrean serial (maks 2 paralel), dijalankan [TaskScheduler].
/// Log per task; retensi default 30 hari (P-13) dipangkas di [AppDatabase].
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get prompt => text()();
  TextColumn get skill => text().nullable()(); // nama skill (bisa null)
  TextColumn get kind =>
      text().withDefault(const Constant('once'))(); // once|interval|cron
  IntColumn get intervalSec =>
      integer().nullable()(); // untuk kind=interval
  TextColumn get cronExpr => text().nullable()(); // untuk kind=cron (menit-jam-himg)
  DateTimeColumn get nextRunAt => dateTime().nullable()();
  DateTimeColumn get lastRunAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get failCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
