import 'dart:async';

import 'package:flutter/foundation.dart';

import '../audit/audit_logger.dart';
import '../crypto/rpc_client.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/crypto_repository.dart';

/// Status kill switch (K-01). Satz global: sek hashtags `stopped`, semua
/// pemantauan & aksi agent terhenti sampai pengguna menyalakan ulang.
class KillSwitch extends ChangeNotifier {
  KillSwitch._();
  static final KillSwitch instance = KillSwitch._();

  bool _stopped = false;
  bool get stopped => _stopped;

  void activate() {
    if (!_stopped) {
      _stopped = true;
      notifyListeners();
    }
  }

  void deactivate() {
    if (_stopped) {
      _stopped = false;
      notifyListeners();
    }
  }
}

/// Pemantau saldo watch-only (Fase 7: read-only).
///
/// Aturan yang ditegakkan:
/// - **V-08:** peringatan bila saldo > ambang pengguna.
/// - **K-01:** kill switch menghentikan polling.
/// - **S-22:** setiap fetch & peringatan masuk audit log.
///
/// ponytail: tidak ada transaksi/blob kunci di sini. Mode auto,
/// signer, dan simulasi menyusul di Fase 8 bersama PolicyEngine on-chain.
class WalletWatcher {
  WalletWatcher({
    required this.repo,
    required this.audit,
    this.defaultRpc = '',
  });

  final CryptoRepository repo;
  final AuditLogger audit;
  final String defaultRpc;

  final Map<String, RpcClient> _rpcs = {};
  final Map<int, BigInt> _lastBalances = {};
  bool _running = false;
  Timer? _timer;

  /// Mulai polling berkala (tiap 60 detik). Aman dipanggil berulang.
  Future<void> start({Duration interval = const Duration(seconds: 60)}) async {
    if (_running) return;
    _running = true;
    await refresh();
    _timer = Timer.periodic(interval, (_) => refresh());
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  RpcClient _client(String? rpc) {
    final url = (rpc != null && rpc.isNotEmpty ? rpc : defaultRpc);
    if (url.isEmpty) throw RpcException('RPC belum diisi di Pengaturan.');
    return _rpcs.putIfAbsent(url, () => RpcClient(url: url));
  }

  /// Ambil saldo semua dompet. Kill switch aktif = batal.
  Future<Map<int, BigInt>> refresh() async {
    if (KillSwitch.instance.stopped) {
      await audit.log(
        taskId: 'wallet:watch',
        event: 'skipped',
        tool: 'killswitch',
        result: 'pemantauan dilewati karena kill switch aktif (K-01)',
      );
      return {};
    }
    final wallets = await repo.wallets();
    final out = <int, BigInt>{};
    for (final w in wallets) {
      try {
        final bal = await _client(w.rpcUrl).getBalance(w.address);
        out[w.id] = bal;
        _maybeAlert(w, bal);
      } on RpcException {
        await audit.log(
          taskId: 'wallet:${w.id}',
          event: 'error',
          tool: 'rpc',
          result: 'gagal ambil saldo: [REDACTED]',
        );
      }
    }
    _lastBalances.addAll(out);
    return out;
  }

  /// V-08: peringatan saldo melebihi ambang.
  Future<void> _maybeAlert(WatchWallet w, BigInt wei) async {
    final thr = w.alertThreshold;
    if (thr == null) return;
    // Ambang disimpan dalam satuan native (mis. BNB). Konversi kasar:
    final amount = wei.toDouble() / 1e18;
    if (amount > thr) {
      await audit.log(
        taskId: 'wallet:${w.id}',
        event: 'alert',
        tool: 'watcher',
        result: 'saldo $amount melebihi ambang $thr (V-08)',
      );
    }
  }
}
