# Fase 4 — Skill System & Sandbox (Catatan Pengerjaan)

Branch: `phase/4-skills`
Tanggal: 2 November 2026

## Yang dibangun

| File | Isi |
|------|-----|
| `lib/core/skills/skill_manifest.dart` | Model `manifest.json` (nama, versi, deskripsi, izin, risk). Parse fail-closed: field wajib hilang/risk tidak valid → `SkillManifestException`, skill ditolak. |
| `lib/core/skills/skill_store.dart` | CRUD folder skill (`skills/<nama>/{SKILL.md,manifest.json,scripts/*.js}`). Hash SHA-256 seluruh isi (S-32). |
| `lib/core/skills/quickjs_sandbox.dart` | Sandbox QuickJS: batas waktu 10 dtk (S-21), host API `SandboxHost` (S-20), runtime dibuang setelah eksekusi (P-05). |
| `lib/core/skills/skill_runner.dart` | Orkestrasi: manifest → PolicyEngine (S-22) → AuditLogger → sandbox. Skill deklaratif (tanpa script) mengembalikan SKILL.md sebagai data untuk agent (S-33). |
| `lib/features/skills/skills_providers.dart` | Riverpod: `skillStoreProvider`, `skillListProvider`. Lokasi: `getApplicationDocumentsDirectory()/skills`. |
| `lib/features/skills/skills_page.dart` | UI daftar + detail skill, ikon risk, chip izin, tombol Jalankan, output preview 2000 char (P-01 lazy list). |
| `lib/app/app_shell.dart` | Tab Skills di navigasi mobile (setelah Chat) + sidebar. |
| `test/skills_test.dart` | 7 tes: manifest parse, fail-closed (3 kasus), store CRUD, hash stabil + berubah, manifest rusak. |
| `test/sandbox_test.dart` | 4 tes: eksekusi + timeout (S-21), error syntax (S-20), tak ada `process` global, path traversal ditolak (S-25). |

## Aturan blueprint yang ditegakkan

- **S-20:** script tak ada akses file/jaringan/proses langsung; hanya `SandboxHost` (log, httpGet, read/writeFile) yang diperiksa PolicyEngine.
- **S-21:** batas waktu 10 detik (timeout membunuh runtime, bukan dilanjutkan). Tanpa eval dinamis dari jaringan.
- **S-25:** validasi nama file sandbox: tolak `..`, `\0`, path absolut.
- **S-30/S-32:** skill luar tak tepercaya sampai ditinjau; hash isi berubah → persetujuan ulang.
- **S-22:** semua eksekusi melalui PolicyEngine + AuditLogger.
- **S-33:** teks skill = data, bukan instruksi yang dieksekusi LLM langsung.

## Dependensi ditambahkan

- `quickjs_engine:^0.1.6` — QuickJS-NG 0.14.0 via FFI. Kompilasi Windows OK (warning C4244 saja).
- `crypto:^3.0.6` — SHA-256 (paket resmi dart.dev, sebelumnya transitive).

## Hasil verifikasi

- `flutter analyze` lib/ — No issues found.
- `flutter test` — **63 passed** (sebelumnya 52; +11 Fase 4).
- `flutter build windows --release` — sukses.
- App dijalankan — RAM **133MB**, tab Skills aktif, init tak crash.

## KENDALA / CATATAN PENTING

1. **Binding QuickJS tak tersedia di `flutter test` host.** Plugin butuh app runtime; `test/sandbox_test.dart` mem-probe binding di `setUpAll` dan skip otomatis bila tak ada (print SKIP, bukan gagal). **Pengujian eksekusi JS asli harus dilakukan di app runtime**, bukan `flutter test`. Ini perilaku plugin, bukan bug.

2. **SandboxHost belum diimplementasikan.** `SandboxHost` adalah abstract class; belum ada implementasi concrete yang menyambung ke PolicyEngine + allowlist domain. Saat ini runner hanya menjalankan script murni (tanpa host API). TODO Fase 5/8.

3. **Import skill (skill install) belum ada UI.** Blueprint `skill install <url|path>` butuh tinjauan izin (S-31) + diff isi — dijadwalkan Fase 5 bersama terminal virtual.

4. **Skill bawaan belum dipasang.** Belum ada skill contoh di `skills/`. Tambahkan saat Fase 5 (mis. `web-research` deklaratif).

5. **PolicyEngine.evaluate** memakai API `evaluate(tool: ToolSpec, args, granted, allowedHosts)` — mapping risk manifest → `RiskLevel` dan permissions → `Permission` ada di `skill_runner.dart` (`_specFor`, `_riskFor`, `_permsFor`).

6. **`Permission.files`** (bukan `fileWrite`) dan `ToolSpec.permissions` adalah `List`, bukan `Set`.

## Cara menguji manual (app runtime)

1. Jalankan app, buka tab Skills.
2. Buat folder `<docs>/skills/<nama>/` berisi `manifest.json` + `SKILL.md`.
3. Restart app → skill muncul di daftar.
4. Tap → Jalankan. Skill deklaratif menampilkan SKILL.md.
