# Fase 7 — Modul Crypto Read-Only

Branch: `phase/7-crypto` (dari `main` setelah Fase 6)

## Yang dibangun

Modul crypto **read-only** — pantau saldo dompet publik tanpa menyimpan kunci
sensitif apa pun. Sesuai blueprint Fase 7 & aturan V-04: tidak ada Vault,
tidak ada kunci privat / seed phrase di aplikasi.

### Core (`lib/core/crypto/`)
- `rpc_client.dart` — klien JSON-RPC EVM minimal via Dio. Hanya method baca
  (`eth_getBalance`, `eth_call`, `eth_blockNumber`, `eth_getTransactionCount`,
  `eth_getTransactionReceipt`, `eth_chainId`). Parsing hex wei → BigInt.
  `RpcException` untuk error RPC.
- `address_validator.dart` — validasi alamat EVM (prefix `0x` + 40 hex).
  `isUnlimitedApprovalSig` (N-03): deteksi calldata `approve` tak terbatas
  (selector `0x095ea7b3` + amount `ff…ff`) dan `setApprovalForAll`
  (`0xa22cb465`) untuk diblokir otomatis.
- `wallet_watcher.dart` — `WalletWatcher`: refresh saldo semua watch-wallet
  via RPC, audit log per event (S-22), alert ambang saldo (V-08), kill switch
  (K-01) menghentikan refresh. **Hanya baca** — tidak ada tx yang dibuat.

### Data (`lib/data/`)
- `database/crypto_tables.dart` — 3 tabel baru:
  - `WatchWallets` — label, **address publik** (bukan kunci!), chainId, rpcUrl,
    alertThreshold.
  - `OnchainSettings` — mode manual/auto + batas (limitPerTx, limitPerDay,
    maxGasGwei, autoRevertDays).
  - `ContractAllowlist` — address kontrak terpercaya (N-01).
- `repositories/crypto_repository.dart` — CRUD watch-wallet, settings
  (upsert `insertOnConflictUpdate`), allowlist.

### UI (`lib/features/wallet/`)
- `wallet_page.dart` — daftar watch-wallet + saldo, form tambah (validasi
  alamat), kartu mode (Manual default), kill switch, peringatan bahwa hanya
  address publik yang diterima.
- `wallet_providers.dart` — `appDatabaseProvider`, `cryptoRepositoryProvider`,
  `walletNotifierProvider`, `auditLoggerProvider` (Provider biasa, override di
  `main()`).

### Wiring
- `main.dart` — satu `AppDatabase` instance dipakai bersama scheduler (Fase 6)
  dan watcher (Fase 7), `AuditLogger` di app data dir, override
  `appDatabaseProvider`/`auditLoggerProvider`/`walletNotifierProvider`.
- Schema v3 + `onUpgrade` (`if (from < 2)` tasks, `if (from < 3)` crypto).

## Verifikasi
- `flutter analyze lib/` — **No issues found**
- `flutter analyze` (termasuk test) — 20 info-level only, 0 error/warning
- `flutter test` — **101 pass**, 1 skip (sandbox butuh app runtime)
- `flutter build windows --release` — sukses (50.2s)
- RAM app — **131MB** (PID 26720)

## Kendala & catatan
1. **Tidak ada notifikasi native** — `flutter_local_notifications:19.0.0`
   crash `gen_snapshot.exe` (0xC0000409) saat AOT release (lihat
   `FASE-6-SCHEDULER.md`). Alert ambang saldo (V-08) hanya tercatat di audit
   log + UI, belum push notification. Alternatif: `local_notifier` atau toast
   Windows native di Fase 8.
2. **`auditLoggerProvider` adalah `Provider<AuditLogger>`** (bukan
   `FutureProvider`) yang wajib di-override di `main()` —
   `UnimplementedError` kalau tidak. Konsekuensi: instance audit logger
   tunggal dibuat saat startup, `dispose` di-attach ke window observer.
3. **Fase 6 slip yang ditemukan & diperbaiki disini:** `main.dart` tidak
   meng-override `taskNotifierProvider`/`auditLoggerProvider` — app akan crash
   saat tab Task dibuka. Sekarang semua provider inti di-override di `main()`.
4. **Layout calldata approve** — saya awalnya salah hitung offset parsing
   (selector 10 hex char + address 64 + amount 64 = 138). Test
   `isUnlimitedApprovalSig` awalnya pakai data terlalu pendek → false negative.
5. **Drift `update().write()` tidak bersifat upsert** — `saveSettings` lama
   mengupdate row yang belum ada → 0 affected → `settings()` insert default
   → perubahan hilang. Fix: `insertOnConflictUpdate`.
6. **RPC default kosong** — tanpa RPC URL, refresh mengembalikan map kosong
   + audit error per dompet (bukan crash). RPC URL per endpoint di-set di
   form tambah / settings (K-08: RPC custom user).
7. **YAGNI ditunda:** `OnchainPolicy` transaksi (10A.2) belum dibangun —
   di mode read-only tidak ada transaksi yang diputuskan. Vault terenkripsi +
   Signer Isolate + 3 mode Auto menyusul Fase 8.
8. RPC publik default belum di-ship (privasi & availabilitas) — user input
   sendiri. `eth_call` ke allowlist contract bisa dipakai untuk baca saldo
   token ERC-20 (selector `0x70a08231`), sudah dites di `crypto_test.dart`.

## File baru
- `lib/core/crypto/rpc_client.dart` (118 baris)
- `lib/core/crypto/address_validator.dart` (36 baris)
- `lib/core/crypto/wallet_watcher.dart` (127 baris)
- `lib/data/database/crypto_tables.dart` (47 baris)
- `lib/data/repositories/crypto_repository.dart` (145 baris)
- `lib/features/wallet/wallet_page.dart` (431 baris)
- `lib/features/wallet/wallet_providers.dart` (85 baris)
- `test/crypto_test.dart` (14 tes)
