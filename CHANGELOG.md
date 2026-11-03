# Changelog

Semua perubahan penting pada proyek Superagent didokumentasikan di sini.
Format mengikuti [Keep a Changelog](https://keepachangelog.com/id/1.1.0/),
versi mengikuti [Semantic Versioning](https://semver.org/lang/id/).

## [0.1.0] — 2026-11-03

Rilis alpha pertama. Aplikasi AI agent workspace lintas platform
(Windows + Android) dengan chat, skills, terminal virtual, task scheduler,
dan modul crypto read-only.

### Fitur
- **Chat LLM** (Fase 0–3): provider OpenAI-compatible + Anthropic, streaming
  SSE, stop/regenerate/edit, riwayat percakapan dengan pencarian, context
  pruning otomatis (keep 40). Penyimpanan drift/SQLite (WAL + indeks).
- **Login Supabase** (Fase 1B): email+password, magic link/OTP, OAuth via
  browser, reset password, sign-out semua perangkat. Opsional — app berfungsi
  100% tanpa login. Sesi disimpan di secure storage OS (PKCE).
- **Skills** (Fase 4): sistem skill deklaratif (markdown + manifest), script
  sandbox QuickJS dengan timeout 10 dtk + batas memori, hash SHA-256 per
  skill, manifest izin wajib ditinjau.
- **Terminal virtual** (Fase 5): terminal aman dengan allowlist perintah,
  audit setiap command, redaksi argumen.
- **Task scheduler** (Fase 6): task once/interval/cron sederhana, timer
  tunggal (tanpa polling), maks 2 task paralel, retensi 30 hari.
- **Crypto read-only** (Fase 7): watch wallet EVM via RPC publik custom,
  validasi alamat, deteksi approve tak terbatas, kill switch, alert ambang
  saldo. Tidak ada kunci privat di app.
- **Hardening** (Fase 8): path traversal protection, redaksi log
  menyeluruh, FLAG_SECURE Android, manifest hardening.

### Keamanan
- PolicyEngine fail-closed dengan matriks risiko (low/medium/high/forbidden).
- NetworkGuard: host allowlist deny-by-default, anti-SSRF (private range
  diblok), HTTPS wajib (loopback/LAN pengecualian), batas respons 5MB.
- Redactor untuk semua log: `sk-…`, `Bearer …`, private key, seed phrase,
  JWT.
- Audit log append-only untuk setiap tool call & task run.
- Sandbox QuickJS tanpa akses file/jaringan langsung.

### Dikenal terbatas
- Ekspor konfigurasi terenkripsi (S-04) belum tersedia (Fase berikutnya).
- Kunci aplikasi PIN/biometrik (6.8) belum tersedia.
- Notifikasi native distub: plugin `flutter_local_notifications` memicu
  crash AOT pada toolchain MSVC 14.51 ini; notifikasi sementara hanya
  `debugPrint` + UI.
- Profil performa Android (perangkat 3 GB RAM) belum diukur (profil Windows:
  131 MB RAM idle, bundle 31 MB).
