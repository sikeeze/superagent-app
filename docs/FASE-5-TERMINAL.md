# Fase 5 — Terminal Virtual (Catatan Pengerjaan)

Branch: `phase/5-terminal`
Tanggal: 2 November 2026

## Yang dibangun

| File | Isi |
|------|-----|
| `lib/core/terminal/command_parser.dart` | Tokenisasi (hormati tanda kutip) + parse `ParsedCommand{name, args, sub, rest}`. |
| `lib/core/terminal/terminal_engine.dart` | Mesin terminal virtual: routing command, buffer 2000 baris, audit setiap command, Redactor pada riwayat. |
| `lib/features/terminal/terminal_page.dart` | UI terminal monospace, history panah atas/bawah, loading state, auto-scroll, KeyboardListener. |
| `lib/app/app_shell.dart` | Tab Terminal di navigasi mobile + sidebar. |
| `test/terminal_test.dart` | 13 tes: parser (4), engine (9). |

## Command virtual yang didukung (9.2)

```
help                          Daftar perintah
skill list                    Daftar skill terpasang
skill install <url|path>      [PLACEHOLDER] belum tersedia
skill remove <nama>           Hapus skill
skill inspect <nama>          Tampilkan isi & izin
skill run <nama>              Jalankan skill (via SkillRunner)
config get <kunci>            Baca pengaturan
config set <kunci> <nilai>    Ubah pengaturan
logs [n]                      Log terakhir
clear                         Bersihkan layar
```

## Aturan blueprint yang ditegakkan

- **S-23:** terminal virtual murni — command diimplementasikan dalam app, tidak ada akses shell sistem. Command tak dikenal → error, bukan dioper ke OS.
- **S-22:** setiap command masuk AuditLogger (`taskId: 'terminal'`).
- **9.3:** riwayat command dipakaikan `Redactor.redact()` sebelum dicatat (argumen rahasia tak disimpan).
- **9.3:** buffer layar dibatasi 2000 baris (`_trimBuffer`).
- **S-24:** `skill remove` adalah satu-satunya operasi destruktif; di Fase 5 ini langsung hapus (konfirmasi UI hold-to-confirm di luar cakupan minimal).
- **S-06:** `config set` menolak kunci yang mengandung `key`/`secret`/`token`/`password`/`seed`.

## Hasil verifikasi

- `flutter analyze` lib/ — No issues found.
- `flutter test` — **76 passed** (sebelumnya 63; +13 Fase 5).
- `flutter build windows --release` — sukses.
- App dijalankan — RAM **152MB**, tab Terminal aktif.

## KENDALA / CATATAN PENTING

1. **`skill install` masih placeholder.** Impor dari path/URL butuh tinjauan izin UI (S-31) dan unduh jaringan. Output: pesan "belum tersedia". TODO Fase 8.

2. **`config set` hanya in-memory.** Nilai disimpan di `Map<String,String>` sesi ini. Persistensi (SharedPreferences/SQLite) di luar cakupan minimal Fase 5.

3. **`task list|cancel` belum ada.** Butuh TaskScheduler Fase 6 — command `task` baru bisa diimplementasikan setelahnya.

4. **AuditLogger di terminal_page provider: positional ctor.** `AuditLogger(path)` — bukan named. `SkillRunner` butuh `granted` (Set<Permission>).

5. **Tes: AuditLogger pegang file.** di Windows, `Directory.delete` gagal bila `IOSink` masih terbuka. Tes wajib `await audit.dispose()` di tearDown sebelum hapus folder temp (lihat `test/terminal_test.dart`).

6. **Terminal Windows mode allowlist (S-22)**: saat ini semua command adalah implemented virtual command — tidak ada exec process sistem di Fase 5 ini, sehingga rule allowlist command Windows terpenuhi secara default (mode virtual). Mode "bebas" (exec command asli via `Process.run`) BUTUH opt-in + peringatan + allowlist; implementasinya ditunda ke Fase 8 hardening.

7. **KeyboardListener fokus:** `FocusNode()` baru dibuat saat build — setiap rebuild membuat node baru. Ikat ke field `State` bila fokus hilang setelah navigation.

## Cara menguji manual (app runtime)

1. Jalankan app → tab Terminal.
2. Ketik `help` → daftar command muncul.
3. Ketik `config set tema gelap` → `config get tema` → `tema = gelap`.
4. Ketik `config set apiKey x` → ditolak (S-06).
5. Ketik `rm -rf /` → "tidak dikenal" (S-23).
6. Ketik `clear` → layar bersih.
7. Panah atas/bawah → navigasi history.
