# Keamanan Superagent

Laporan keamanan dan panduan pelaporan kerentanan untuk Superagent.

## Aturan keamanan (ringkas)

Aplikasi ini menerapkan aturan keamanan dari `SUPERAGENT_BLUEPRINT.md`
Bagian 6. Aturan-aturan kunci:

1. **Tidak ada rahasia di repositori.** Hanya kunci publik (publishable/anon
   key Supabase) yang boleh ada di kode. Service-role/secret key TIDAK
   PERNAH boleh dibakar ke APK/EXE.
2. **API key pengguna disimpan di secure storage OS** (Keychain/Keystore),
   bukan di SharedPreferences, SQLite, atau file biasa.
3. **Semua log melewati Redactor** yang menyamarkan pola sensitif: `sk-…`,
   `Bearer …`, `x-api-key`, private key EVM, seed phrase, JWT.
4. **Aksi berisiko tinggi butuh konfirmasi pengguna.** PolicyEngine
   fail-closed: aksi high-risk tanpa callback konfirmasi ditolak otomatis.
5. **Sandbox skill.** Script skill berjalan di QuickJS tanpa akses file atau
   jaringan langsung; semua akses lewat host API yang diperiksa PolicyEngine.
6. **Mode Eksekusi default: Manual.** Transaksi/on-chain action memerlukan
   konfirmasi eksplisit.

## Melaporkan kerentanan

Kirim laporan ke maintainers. Sertakan:

- Deskripsi kerentanan dan dampaknya
- Langkah reproduksi (PoC bila ada)
- Versi aplikasi dan platform (Windows/Android)

## Validasi keamanan yang sudah dilakukan

- Audit otomatis Fase 8 (`docs/FASE-8-HARDENING.md`): path traversal, redaksi
  log, manifest Android, FLAG_SECURE, dependensi, SSRF, prompt injection.
- Secret scanner: tidak ada kunci/token rahasia di repositori.
- `pubspec.lock` terkunci; `dart pub outdated` bersih dari CVE pada versi
  yang dipasang.

## Yang TIDAK ada di aplikasi

- Tidak ada telemetri/analytics bawaan (S-50).
- Tidak ada iklan atau tracker pihak ketiga.
- Tidak ada service-role key Supabase di mana pun di repo atau build.

## Catatan khusus platform

- **Android:** `allowBackup=false`, `usesCleartextTraffic=false`, izin
  minimum (INTERNET saja). `FLAG_SECURE` aktif pada layar yang menampilkan
  kunci. Penyimpanan kunci memakai EncryptedSharedPreferences via
  flutter_secure_storage.
- **Windows:** API key disimpan via DPAPI (flutter_secure_storage_windows).
