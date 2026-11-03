# Fase 10 — Ekspor/Impor Konfigurasi Terenkripsi (S-04)

Branch: `phase/10-config-export` (dari `main` setelah Fase 9)

## Yang dibangun

Fitur S-04 dari checklist Bagian 12 yang sebelumnya ditunda: ekspor &
impor konfigurasi terenkripsi (AES-256-GCM + PBKDF2 iterasi tinggi).

### Core
- `lib/core/security/config_vault.dart` — format file `SEC1` (version 1):
  - Magic 4 byte + version + salt(16) + nonce-len + nonce + ct-len +
    ciphertext + MAC(16).
  - Kunci turunan: **PBKDF2-HMAC-SHA256, 200.000 iterasi**, 32 byte
    (AES-256) — blueprint: "Argon2id atau PBKDF2 dengan iterasi tinggi".
  - Cipher: **AES-256-GCM** (authenticated encryption: confidentiality +
    integrity). MAC GCM diverifikasi saat dekripsi → passphrase salah
    atau file rusak ditolak.
  - Passphrase min 8 karakter (cek saat encrypt).
  - Salt + nonce random per operasi (output berbeda untuk input sama).
  - Error dibungkus `ConfigVaultException` (pesan aman, tidak membocorkan
    struktur internal).
- `lib/core/services/config_export_service.dart` — payload: profil
  provider + API key dari secure storage. Upsert saat impor (id sama
  ditimpa). Tidak ada data percakapan (ada di DB), tidak ada kunci privat
  (Fase 7: tidak pernah disimpan).

### UI
- `lib/features/settings/export_import_dialogs.dart` — dialog ekspor
  (path + passphrase) & impor (path + passphrase), error inline, SnackBar
  konfirmasi.
- `lib/features/settings/settings_page.dart` — kartu "Cadangan (S-04)"
  dengan 2 SettingsTile (ekspor/impor).

## Verifikasi
- `flutter analyze lib/` — **No issues found**
- `flutter test` — **116 pass**, 1 skip
- `flutter build windows --release` — sukses (42.4s); `cryptography` pure
  Dart, tidak ada kode native → aman dari crash AOT gen_snapshot.

## Tes baru
- `test/config_vault_test.dart` (6 tes):
  - round-trip encrypt → decrypt
  - passphrase salah → ConfigVaultException (bukan SecretBoxAuthenticationError)
  - magic salah → exception
  - passphrase < 8 karakter → exception
  - data terpotong → exception
  - nonce/salt unik per encrypt (output berbeda, keduanya bisa didekrip)

## Kendala & catatan
1. **Paket `cryptography:^2.7.0`** — caret `^2.7` (dua segmen) TIDAK
   diterima parser pubspec Flutter; harus `^2.7.0`. Versi resolve: 2.9.0.
2. **API cryptography 2.9**: `Nonce` bukan constructor (pakai `List<int>`
   langsung); `SecureRandom.instance` tidak ada (pakai `Random.secure()`);
   `newNonce()` default **12 byte** untuk AES-GCM (format file awal salah
   mengasumsikan 16 → diperbaiki jadi panjang dinamis di header).
3. **`Mac.empty` tidak valid untuk decrypt** — `DartAesGcm.decrypt`
   verifikasi MAC selalu; harus simpan `box.mac.bytes` (16 byte) ke file
   dan pakai saat dekripsi.
4. **S-02 ditegakkan**: passphrase diminta dari pengguna saat runtime;
   tidak ada passphrase/kunci default di kode. File export disimpan
   pengguna di path yang dipilih — dokumentasi menyarankan di luar repo.

## Sisa checklist Bagian 12 (sebelumnya ditunda)
- [x] **Ekspor konfigurasi terenkripsi (S-04)** — SELESAI di fase ini.
- [ ] Kunci aplikasi PIN/biometrik/Windows Hello (6.8).
- [ ] Integration test alur utama (setup provider → chat → tool call →
      konfirmasi).
- [ ] Profil performa Android (butuh emulator/device).
- [ ] Notifikasi native alternatif.
