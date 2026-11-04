# Fase 11 — Kunci Aplikasi (Blueprint 6.8)

**Branch:** `phase/11-app-lock`
**Commit:** `feat: fase 11 — kunci aplikasi: pin pbkdf2, auto-lock, backoff brute-force`

## Yang dibangun

1. **`lib/core/security/app_lock_manager.dart`** (226 baris)
   - PIN 4–8 digit divalidasi, disimpan sebagai **hash PBKDF2-HMAC-SHA256
     100rb iterasi + salt** di secure storage OS (S-01: tidak plain, tidak
     di SharedPreferences).
   - **Auto-lock:** timer idle N menit (default 5, bisa 1–60) yang di-reset
     setiap interaksi pengguna. `onLockChanged` callback supaya UI reaktif.
   - **Backoff brute-force:** percobaan gagal menumpuk. 1–2 gagal bebas,
     percobaan ke-3+ menunggu 2s, 4s, 8s, 16s (capped 30s). Saat backoff
     aktif `unlock()` melempar `AppLockException` — **fail-closed**.
   - `disable()` butuh PIN benar; `verify()` reset counter saat berhasil.

2. **`lib/features/settings/app_lock_screen.dart`** (176 baris)
   - Layar kunci fullscreen: keypad 3×4, indikator 4 dot, pesan sisa
     backoff. Auto-submit saat 4 digit terisi (jika PIN 4 digit).

3. **`lib/features/settings/app_lock_providers.dart`** (32 baris)
   - `appLockManagerProvider` (Provider, override di main), `AppLockNotifier`
     (StateNotifier<bool>) untuk gate UI, `initAppLock()` helper.

4. **`lib/features/settings/app_lock_settings_card.dart`** (143 baris)
   - Kartu di SettingsPage: switch aktif/nonaktif (dialog PIN), slider
     auto-lock 1–30 menit, tombol "Kunci sekarang".

5. **Wiring:**
   - `main.dart`: `initAppLock()` + override provider + state awal terkunci
     bila PIN sebelumnya diset.
   - `app/app.dart`: `SuperagentApp` jadi `ConsumerStatefulWidget` +
     `WidgetsBindingObserver` yang mengunci saat app masuk background
     (`AppLifecycleState.paused`). Layar kunci dipasang via `builder` di
     atas Navigator (tidak bentrok `initialRoute`). `_ActivityReporter`
     memreset timer auto-lock pada setiap pointer down/signal.

## Yang sengaja ditunda

- **Windows Hello / biometrik (`local_auth`):** plugin native berisiko
  crash AOT pada toolchain MSVC 14.51 ini (lihat catatan Fase 8 tentang
  `flutter_local_notifications`). PIN + auto-lock adalah lapisan utama;
  Windows Hello dapat ditambahkan kemudian sebagai shortcut — pengguna
  tetap harus mempunyai PIN sebagai fallback.

## Verifikasi

- `flutter analyze` (lib/) → **No issues**
- `flutter test` → **126 pass, 1 skip** (sebelumnya 116; +10 app lock)
- `flutter build windows --release` → sukses, 42.1s
- RAM saat idle → **131 MB** (target ≤180 MB), bundle 31 MB

## Kendala

1. **Logika backoff awal keliru:** percobaan ke-2 seharusnya bebas, backoff
   baru berlaku setelah 2 gagal. Diperbaiki: `_backoffFor(attempts)` kembali
   0 untuk attempts ≤ 2, lalu 2^(attempts−2).
2. **Fail-closed counter:** setelah backoff aktif, `unlock()` melempar
   exception sebelum memanggil `verify()` sehingga `failedAttempts` tidak
   naik lagi. Itu perilaku yang diinginkan (akses tetap diblok), test
   disesuaikan (expect 3, bukan 5).
3. **`home: locked ? ... : null` bentrok `initialRoute`.** Solusi: pasang
   layar kunci via `builder` MaterialApp, bukan `home`.
4. **Lock saat `AppLifecycleState.inactive` terlalu agresif** — status
   `inactive` juga muncul saat dialog izin sistem terbuka (false-lock).
   Hanya `paused` yang digunakan.
