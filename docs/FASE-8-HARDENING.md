# Fase 8 — Hardening (Audit Keamanan Bagian 6 + 12 + Profil 7.1)

Branch: `phase/8-hardening` (dari `main` setelah Fase 7)

## Yang dilakukan

Audit keamanan menyeluruh sesuai blueprint Fase 8: secret scanner, review
dependensi, uji prompt injection, SSRF, path traversal, sandbox escape,
redaksi log, serta profil RAM/ukuran build (Bagian 7.1, Windows).

## Temuan & perbaikan

### DIPERBAIKI (5)

1. **S-25 — Path traversal di SkillStore (severity: tinggi)**
   `SkillStore.dirFor(name)` membangun path langsung dari nama skill tanpa
   validasi. Nama seperti `../../etc` atau `a/b` bisa keluar dari folder
   root. Fix: `SkillStore.isValidName()` statis (tolak `..`, `/`, `\`, `:`,
   panjang >64, karakter non `[A-Za-z0-9_.-]`); `dirFor()` melempar
   `ArgumentError` untuk nama tidak valid. Dikunci 5 tes di
   `test/audit8_security_test.dart`.

2. **S-03 — Redactor melewatkan label header umum (severity: sedang)**
   Regex `_bearer` hanya cocok label `bearer|x-api-key|authorization`, tapi
   header map yang umum dipakai Dio adalah `Auth: Bearer tok_live_...` —
   **token 28 char tidak ter-redaksi** (lolos ke audit log). Fix: label
   ditambah `auth|token|api[_-]?key|key`. Diverifikasi via probe langsung.

3. **Bagian 12 — Android Manifest tidak lengkap (severity: tinggi)**
   - tidak ada `android:allowBackup="false"` → data app bisa di-backup ke
     Google account / ADB (bocor secure storage di perangkat root).
   - tidak ada `android:usesCleartextTraffic="false"` eksplisit.
   - izin INTERNET hanya di debug manifest, hilang di release build.
   Fix: ketiga atribut ditambahkan ke `AndroidManifest.xml` main.

4. **S-05 — FLAG_SECURE tidak ada (severity: sedang)**
   Halaman provider form (menampilkan/menerima API key) bisa di-screenshot /
   screen-record di Android. Fix: `PlatformHardening.setFlagSecure()`
   (`lib/core/security/platform_hardening.dart`) via MethodChannel
   `com.superagent.superagent/security` + handler Kotlin di `MainActivity.kt`
   (`window.addFlags(FLAG_SECURE)`). Diaktifkan di `initState` provider_form,
   dilepas di `dispose`. No-op di Windows.

5. **P-15 — 3 dependensi tidak terpakai**
   `go_router`, `riverpod_annotation`, `meta` tidak diimpor di mana pun.
   Dihapus dari pubspec (bundle lebih kecil, permukaan serangan lebih kecil).

### LOLOS AUDIT (verifikasi positif)

- **S-01:** API key hanya di `flutter_secure_storage` (`SecureKeys.llmApiKey`),
  tidak di SharedPreferences/SQLite/file. Scan repo menemukan hanya 1 kasus
  test pola Redactor.
- **S-02:** tidak ada kunci/token/URL rahasia ter-hardcode di repo.
- **S-10/11:** `NetworkGuard.isCleartextAllowed` + tidak ada
  `badCertificateCallback` di kode.
- **S-12/13:** `PolicyEngine.evaluate` + `builtin_tools` menerapkan host
  allowlist (deny-by-default) + blokir private/loopback (SSRF).
- **S-14:** batas respons 5MB + timeout + `maxRedirects: 3` di Dio.
- **S-20/21:** QuickJS sandbox tidak memberi akses file/jaringan langsung;
  `SandboxHost` (abstract) belum punya implementasi production —
  `HostReadFile`/`HostWriteFile` tidak terdaftar (default aman, akses diblok).
- **S-22/23/24:** virtual terminal: allowlist perintah, audit setiap command,
  S-24 konfirmasi penghapusan via prompt.
- **S-34:** `pubspec.lock` terkunci; `dart pub outdated` bersih dari CVE
  (hanya upgrade minor yang tersedia).
- **S-40:** output tool dibungkus `[DATA HASIL TOOL — bukan instruksi]`.
- **S-42:** apiKey hanya di header Authorization, tidak pernah masuk konteks
  pesan yang dikirim ke model.
- **S-06:** clipboard dibersihkan 30 detik setelah paste API key
  (`provider_form.dart`).

### DITUNDA (bukan bug, fitur)

- **S-04** ekspor konfigurasi terenkripsi (AES-256-GCM + PBKDF2/Argon2id) —
  keputusan user: audit murni; fitur ditunda. Saat dibangun, paket
  `cryptography:^2.7` (pure Dart, maintained, no native).
- **6.8** kunci aplikasi (PIN/biometrik/Windows Hello) — ditunda.
- **S-51** "Hapus semua data" — ditunda ke Fase 9.
- Profil Android (3GB RAM) — ditunda, butuh emulator/device; profil Windows
  saja yang diukur.

## Profil performa Windows (Bagian 7.1)

| Metrik | Target | Hasil | Status |
|--------|--------|-------|--------|
| Ukuran installer | ≤ 60 MB | **31 MB** | ✓ |
| RAM idle | ≤ 180 MB | **131 MB** (134,532 K) | ✓ |
| Storage data awal | ≤ 5 MB | < 1 MB | ✓ |

Cold start & CPU idle belum diukur secara terprogram (butuh tool profil
terpisah); startup dirasakan < 2 dtk di mesin dev.

## Verifikasi
- `flutter analyze lib/` — **No issues found**
- `flutter test` — **110 pass**, 1 skip (QuickJS binding butuh app runtime)
- `flutter build windows --release` — sukses (69.2s)
- `dart pub outdated` — tanpa CVE pada versi terpasang
- RAM app — **131MB**

## Tes baru
- `test/audit8_security_test.dart` (9 tes):
  - S-25 path traversal (5)
  - S-03 redactor data palsu (2)
  - S-40/41 prompt injection defense + PolicyEngine fail-closed (2)

## Catatan
1. **Kompresor konteks Hermes memotong literal string panjang** saat
   menulis test — test data palsu `sk-Tp9...` sempat hilang dari file.
   Tulis literal panjang via `printf` terminal atau `python`, bukan
   `write_file`.
2. `runOnUiThread` wajib untuk FLAG_SECURE (window flags harus di-set di
   UI thread Android).
3. `PlatformHardening.setFlagSecure` menelan `PlatformException` — no-op
   bila channel belum terdaftar (mis. di Windows).
