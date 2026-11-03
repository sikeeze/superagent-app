# Superagent

Aplikasi AI agent workspace lintas platform (Windows + Android) — chat LLM,
sistem skill aman, terminal virtual, task scheduler, dan monitor crypto
read-only. Local-first: data percakapan disimpan di perangkat, API key
disimpan di secure storage OS.

Dirancang dan dibangun mengikuti `SUPERAGENT_BLUEPRINT.md`.

## Cara menjalankan

### Windows (rilis)

```bash
flutter build windows --release
build/windows/x64/runner/Release/superagent.exe
```

### Android

```bash
flutter build apk --split-per-abi --release
# output: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### Development

```bash
flutter pub get
flutter run
flutter test
flutter analyze
```

## Panduan pengguna singkat

1. **Setup provider** — buka tab Pengaturan → Provider AI. Isi base URL
   (mis. `https://api.openai.com/v1`), API key, dan model. Klik **Test
   Connection** untuk memverifikasi. API key disimpan di secure storage OS,
   tidak pernah ditampilkan di log atau dikirim ke model sebagai konteks.
2. **Chat** — buka tab Chat, ketik pesan. Tool call berjalan otomatis bila
   diizinkan skill; aksi berisiko tinggi (mis. kirim dana, hapus data)
   memerlukan konfirmasi Anda.
3. **Skills** — instal skill deklaratif (markdown + manifest). Tinjau
   manifest izin (jaringan, domain, file, notifikasi, risiko) sebelum
   menyetujui. Script skill berjalan di sandbox QuickJS dengan timeout 10
   detik, tanpa akses langsung ke file/jaringan.
4. **Terminal virtual** — terminal aman dengan allowlist perintah
   (`help`, `skill list`, `config`, `logs`, …). Tidak ada akses shell
   sistem. Setiap command tercatat di audit log.
5. **Task scheduler** — buat task berulang (once / interval / cron
   sederhana). Maks 2 task berjalan paralel; log retensi 30 hari.
6. **Crypto** — tambahkan **alamat publik** (watch-only) untuk memantau
   saldo EVM via RPC publik custom (K-08). Kill switch (K-01) menghentikan
   refresh kapan saja. Mode Eksekusi default: **Manual** — tidak ada
   transaksi yang diputuskan tanpa konfirmasi Anda.
7. **Login (opsional)** — akun Supabase hanya untuk sinkronisasi preferensi;
   app berfungsi 100% tanpa login (A-17).

## Keamanan

Lihat [SECURITY.md](SECURITY.md) untuk ringkasannya. Inti:

- API key di secure storage OS, bukan diSharedPreferences/SQLite.
- Semua log melewati Redactor (pola `sk-…`, Bearer, private key, seed
  phrase, JWT disamarkan).
- Aksi high-risk butuh konfirmasi pengguna (PolicyEngine fail-closed).
- Mode Eksekusi default: Manual. Tidak ada kunci privat di app.
- Tidak ada telemetri/analytics bawaan (S-50).

## Metrik (profil Windows, Bagian 7.1)

| Metrik | Hasil |
|--------|-------|
| RAM idle | 131 MB |
| Ukuran bundle | 31 MB |
| Storage data awal | < 1 MB |
| Tests | 110 pass, 1 skip |

## Dokumentasi

- [Blueprint lengkap](SUPERAGENT_BLUEPRINT.md)
- [Changelog](CHANGELOG.md)
- [Keamanan](SECURITY.md)
- Catatan per fase: `docs/FASE-*.md`

## Lisensi

Proprietary — semua hak dilindungi.
