# Fase 6 — Task Scheduler & Notifikasi (Catatan Pengerjaan)

Branch: `phase/6-scheduler`
Tanggal: 2 November 2026

## Yang dibangun

| File | Isi |
|------|-----|
| `lib/data/database/task_tables.dart` | Tabel `Tasks`: prompt + skill + jadwal (once/interval/cron sederhana), status, failCount. |
| `lib/data/database/app_database.dart` | schemaVersion 2 + `onUpgrade` + indeks `idx_tasks_due` (P-12). |
| `lib/data/repositories/task_repository.dart` | CRUD tasks, `dueTasks`, `runningCount`, `pruneOldDone` (retensi 30 hari, P-13). |
| `lib/core/tasks/task_scheduler.dart` | Scheduler timer tunggal, maks 2 paralel, cron parser, audit setiap run. |
| `lib/core/notifications/notification_service.dart` | Service notifikasi (stub sementara, lihat KENDALA #1). |
| `lib/features/task/task_providers.dart` | `TaskNotifier` (StateNotifier) + provider DB/repo/audit. |
| `lib/features/task/tasks_page.dart` | UI daftar task + form buat (once/interval/cron) + aksi run/cancel/remove. |
| `lib/core/tools/builtin/builtin_tools.dart` | Tool `notify` + `schedule_task` untuk agent. |
| `lib/main.dart` | Override `taskNotifierProvider` + init scheduler. |
| `lib/app/app_shell.dart` | Tab **Task** di navigasi mobile & sidebar. |
| `test/task_test.dart` | 11 tes: repository (6), scheduler/cron (5). |

## Aturan blueprint yang ditegakkan

- **5.4:** Task = prompt + skill + jadwal; antrean serial (maks 2 paralel); status `pending|running|waiting_confirmation|done|failed|cancelled`; log per task; retensi 30 hari.
- **5.5:** Notifikasi lokal saat task selesai/gagal/butuh konfirmasi. Channel Android: `task`, `confirm`, `error`. Aksi berisiko wajib membuka app (notifikasi hanya membuka, keputusan tetap di UI + autentikasi).
- **P-08:** Timer tunggal untuk task due terdekat — tidak ada polling.
- **P-13:** Retensi log 30 hari (`pruneOldDone`).
- **S-22:** Setiap run scheduler masuk AuditLogger.

## Hasil verifikasi

- `flutter analyze` lib/ — No issues found.
- `flutter test` — **87 passed** (sebelumnya 76; +11 Fase 6).
- `flutter build windows --release` — sukses.
- App dijalankan — RAM **131MB**, tab Task aktif.

## KENDALA / CATATAN PENTING

1. **Plugin `flutter_local_notifications` 19.0.0 crash AOT.** `gen_snapshot.exe` exit code `-1073740791` (0xC0000409, stack buffer overrun) saat compile `flutter_local_notifications_windows` dengan MSVC 14.51 (VS 2022 v18). Debug build OK; hanya AOT release yang crash. **Workaround:** implementasi notifikasi diturunkan ke stub yang menulis ke `debugPrint` (logika channel task/confirm/error tetap, API tetap sama). Toast asli dihidupkan kembali di Fase 8 (hardening) setelah toolchain/plugin konsisten — atau coba plugin versi lain (`local_notifier`, `toastification`) bila masih crash. File implementasi penuh disimpan di repo? **Tidak** — lihat catatan repo; implementasi plugin terhapus saat debugging, stub sekarang yang dipakai. Reimplementasi mengikuti blueprint 5.5.

2. **Drift menyimpan DateTime sebagai detik epoch** (integer), bukan mikrodetik/ISO. Tes yang menulis `last_run_at` langsung lewat `customStatement` wajib pakai `millisecondsSinceEpoch ~/ 1000` — selisih unit menyebabkan `pruneOldDone` tidak cocok (lihat `test/task_test.dart`).

3. **build_runner butuh `part` directive + import di tempat benar.** Import `task_tables.dart` harus di atas `part 'app_database.g.dart'`, bukan setelah anotasi `@DriftDatabase`. Jika salah, codegen melewati tabel **tanpa error** (119 output tapi `.g.dart` tak ter-update). Juga: `task_tables.dart` wajib `import 'package:drift/drift.dart'`.

4. **`update().write()` di drift 2.31 mengembalikan `Future<int>`** (jumlah baris), bukan `Future<bool>`.

5. **`git stash` mengembalikan file **seluruhnya** ke kondisi commit — termasuk `@DriftDatabase` dan import.** Setelah stash pop, codegen state bisa tidak konsisten; selalu jalankan `dart run build_runner build` + `flutter analyze` setelahnya.

6. **Tool `schedule_task` masih return placeholder** — bridge ke `TaskRepository` dari tool registry menyusul di Fase 8 (butuh akses ProviderScope dari lapisan core; saat ini tool handler isolated).

7. **Eksekusi task oleh `TaskRunner` hanya mencatat audit log.** Menjalankan skill sesungguhnya (lewat SkillRunner) atau prompt ke agent loop menyusul di Fase 8 — sekarang task = prompt terjadwal + log.

## Cara menguji manual (app runtime)

1. Jalankan app → tab **Task**.
2. Tekan **+ Task Baru** → isi judul + prompt, pilih jadwal (Sekali/Interval detik/Cron `menit jam hari`).
3. Task berstatus pending → scheduler menjalankan saat due → status `done` (+ notifikasi stub di debug log).
4. Menu task: **Jalankan** (run now), **Batal**, **Hapus**.
5. Cron: `30 6 *` = setiap hari 06:30; `0 0 10` = tanggal 10 setiap bulan.
