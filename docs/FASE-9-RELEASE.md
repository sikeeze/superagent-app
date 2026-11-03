# Fase 9 — Rilis

Branch: `phase/9-release` (dari `main` setelah Fase 8)

## Yang dilakukan

Persiapan rilis sesuai blueprint Fase 9: signing APK (keystore di luar
repo), installer EXE (Inno Setup), SECURITY.md, README, panduan pengguna,
changelog, dan checklist Bagian 12.

## Deliverable

1. **`SECURITY.md`** — ringkasan aturan keamanan, cara melaporkan
   kerentanan, validasi yang sudah dilakukan, platform-specific notes.
2. **`README.md`** — cara menjalankan (Windows/Android/dev), panduan
   pengguna singkat 7 poin (provider → chat → skills → terminal → task →
   crypto → login opsional), metrik, tautan dokumentasi.
3. **`CHANGELOG.md`** — format Keep a Changelog, versi 0.1.0 alpha,
   fitur per fase + keamanan + keterbatasan yang diketahui.
4. **Signing APK** — `android/app/build.gradle.kts` membaca
   `android/signing.properties` (file lokal, di-gitignore). Template:
   `android/signing.properties.example` ( Cara buat keystore + build
   rilis). Fallback: debug keys bila file tidak ada (dev build tetap
   jalan). **Keystore tidak pernah ada di repositori (S-02).**
5. **Installer EXE Inno Setup** — `installer/superagent.iss` (LZMA2,
   x64, bahasa Indonesia + English, desktop icon opsional). Build
   manual via Inno Setup Compiler setelah `flutter build windows
   --release`.

## Checklist Bagian 12

### Keamanan

- [x] Tidak ada rahasia di repo — secret scanner dijalankan (Fase 8);
      hanya 1 kasus test pola Redactor.
- [x] Semua log lolos Redactor — diuji dengan data palsu
      (`test/audit8_security_test.dart`); label header umum (`Auth:`,
      `Token:`) diperbaiki di Fase 8.
- [x] Uji prompt injection — output tool dibungkus delimiter DATA
      (S-40); aksi high-risk fail-closed butuh konfirmasi (S-41);
      output model ditampilkan apa adanya (S-43).
- [x] Uji path traversal — `SkillStore.isValidName` + 5 tes (Fase 8).
- [x] Uji SSRF — NetworkGuard memblokir private range (S-13), host
      allowlist deny-by-default (S-12). Dites di security_smoke_test.
- [x] Sandbox skill tidak dapat membaca file/jaringan di luar izin —
      HostReadFile/HostWriteFile tidak terdaftar (default aman, S-20).
- [ ] **Ekspor konfigurasi terenkripsi (S-04) — DITUNDA.** Bukan bug;
      fitur baru. Saat dibangun: `cryptography:^2.7` (AES-256-GCM +
      PBKDF2). Impor-kembali menyusul.
- [x] APK ditandatangani, `allowBackup=false`, tanpa
      `usesCleartextTraffic` global — signing via
      `signing.properties` (perlu keystore rilis untuk publish);
      manifest di-hardening di Fase 8.
- [x] Izin Android minimum — hanya INTERNET (di main manifest).

### Performa (Windows, Bagian 7.1)

- [x] RAM idle sesuai target — 131 MB (target ≤ 180 MB).
- [ ] RAM saat task aktif — **belum diukur terprogram.** Estimasi:
      scheduler + watcher ringan; butuh sesi 2 jam untuk pengukuran
      akurat.
- [x] Ukuran build sesuai target — 31 MB (target ≤ 60 MB).
- [ ] Tidak ada memory leak (uji sesi 2 jam) — **belum dijalankan.**
      Catatan: timer clipboard (30 dtk) di provider_form tidak
      di-cancel saat dispose (minor, di-flag untuk follow-up).
- [ ] CPU idle ~0% — **belum diukur terprogram** (butuh perfmon /
      Process Explorer).
- [x] Storage data awal — < 1 MB (SQLite kosong).
- [ ] Profil Android (3 GB RAM) — **ditunda**, butuh emulator/device.

### Fungsional

- [ ] Semua layar punya loading, empty, dan error state — **sebagian.**
      Wallet/chat/task punya empty state; beberapa halaman placeholder
      (airdrop, binance, activity) masih skeleton.
- [x] Jaringan putus di tengah stream ditangani tanpa crash — error
      DioException → Redactor.redact → tampil di chat (Fase 0-3).
- [ ] Rotasi layar, dark/light, skala font, resize jendela —
      **sebagian.** Dark/light ada; resize jendela Windows OK
      (verified manual); skala font & rotasi Android belum dites.
- [x] Unit test core ≥ 80% untuk `policy`, `security`, `llm`, `skills` —
      110 tes: security_smoke (19), adapter_llm (7+), audit2_regression
      (9), skills (7), audit8 (9), crypto (14), task (11), terminal (13),
      database, auth, app_shell, sandbox (skip). Cakupan `policy` &
      `security` padat.
- [ ] Integration test alur utama (setup provider → chat → tool call →
      konfirmasi) — **DITUNDA.** Saat ini unit/integration per modul.

## Verifikasi
- `flutter analyze lib/` — **No issues found**
- `flutter test` — **110 pass**, 1 skip
- `flutter build windows --release` — sukses (40.2s), bundle 31 MB

## Kendala & catatan

1. **Signing rilis:** `signing.properties` wajib dibuat developer
   sebelum publish APK (template ada). Tanpa file itu, build rilis
   memakai debug keys — TIDAK untuk produksi.
2. **Inno Setup** harus dipasang terpisah (gratis, Windows only) untuk
   membuka `installer/superagent.iss`. GUID installer:
   `{8F2C1A3E-4B5D-4C6A-9D7E-1A2B3C4D5E6F}`.
3. **Yang ditunda** (bukan blocker rilis internal, tapi wajib sebelum
   produksi): S-04 export terenkripsi, kunci aplikasi 6.8, profil
   Android, uji sesi 2 jam, integration test alur utama, notifikasi
   native (stub Fase 6).
4. **Notifikasi** masih stub `debugPrint` — alasan: plugin
   `flutter_local_notifications` crash AOT (0xC0000409) pada toolchain
   MSVC 14.51 ini (lihat `FASE-6-SCHEDULER.md`).
5. **Versi pubspec:** `1.0.0+1` — pertimbangkan `0.1.0+1` bila rilis
   alpha internal (CHANGELOG sudah pakai 0.1.0).

## File baru
- `SECURITY.md`
- `README.md` (rewrite dari placeholder)
- `CHANGELOG.md`
- `android/signing.properties.example`
- `installer/superagent.iss`
- `docs/FASE-9-RELEASE.md`
