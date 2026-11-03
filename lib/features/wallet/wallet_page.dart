
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/design_tokens.dart';
import '../../app/theme.dart';
import '../../core/crypto/address_validator.dart';
import '../../core/crypto/wallet_watcher.dart';
import '../../data/database/app_database.dart';
import 'wallet_providers.dart';

/// Layar Eksekusi & Wallet (blueprint 10A.6, Fase 7: read-only).
///
/// ponytail: tanpa Signer & tanpa kunci privat. Dompet = watch-only.
/// Tombol Buat Baru / mode Auto menampilkan penjelasan (menyusul Fase 8).
class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  Map<int, BigInt> _balances = {};
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final notifier = ref.read(walletNotifierProvider.notifier);
      final balances = await notifier.refresh();
      setState(() => _balances = balances);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    final wallets = ref.watch(walletListProvider);
    final settings = ref.watch(onchainSettingsProvider);
    final stopped = ref.watch(killSwitchProvider);

    return ListView(
      padding: const EdgeInsets.all(DesignTokens.gridGap),
      children: [
        // --- Mode eksekusi (10A.6) ---
        _ModeCard(settings: settings, stopped: stopped),
        const SizedBox(height: DesignTokens.gridGap),

        // --- Kill switch (K-01) ---
        _KillSwitchCard(stopped: stopped),
        const SizedBox(height: DesignTokens.gridGap),

        // --- Daftar dompet ---
        Text('Wallet agent (watch-only)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: DesignTokens.gridGap / 2),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _error!,
              style: TextStyle(color: DesignTokens.danger, fontSize: 12),
            ),
          ),
        wallets.when(
          data: (list) => list.isEmpty
              ? _emptyWallets(colors)
              : Column(
                  children: list
                      .map((w) => _WalletTile(
                            label: w.label,
                            address: w.address,
                            balance: _balances[w.id],
                            threshold: w.alertThreshold,
                          ))
                      .toList(),
                ),
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Gagal baca dompet: [REDACTED]',
              style: TextStyle(color: DesignTokens.danger)),
        ),
        const SizedBox(height: DesignTokens.gridGap),
        Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: _showAddWallet,
              icon: const Icon(Icons.add),
              label: const Text('Tambah watch address'),
            ),
            const SizedBox(width: DesignTokens.gridGap),
            OutlinedButton.icon(
              onPressed: _loading ? null : _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh saldo'),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.gridGap),
        const _ReadonlyNotice(),
      ],
    );
  }

  Widget _emptyWallets(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Belum ada dompet yang dipantau.\n'
        'Tambahkan alamat publik (watch-only) untuk memantau saldo.',
        style: TextStyle(color: colors.textSecondary, fontSize: 13),
      ),
    );
  }

  void _showAddWallet() {
    final labelCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    String? err;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Tambah dompet watch-only'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hanya alamat publik yang disimpan. Kunci privat / seed '
                    'phrase TIDAK diterima di Fase 7 (V-04).',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(ctx).colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: labelCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Label',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addrCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Alamat EVM (0x…)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (err != null) ...[
                    const SizedBox(height: 8),
                    Text(err!,
                        style: TextStyle(
                            color: Theme.of(ctx).colorScheme.error,
                            fontSize: 12)),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () async {
                    final addr = addrCtrl.text.trim();
                    if (labelCtrl.text.trim().isEmpty) {
                      setState(() => err = 'Label wajib diisi.');
                      return;
                    }
                    if (!AddressValidator.isValid(addr)) {
                      setState(() => err = 'Alamat EVM tidak valid.');
                      return;
                    }
                    await ref.read(walletNotifierProvider.notifier).addWallet(
                          label: labelCtrl.text.trim(),
                          address: addr,
                        );
                    if (ctx.mounted) Navigator.pop(ctx);
                    _refresh();
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ModeCard extends ConsumerWidget {
  const _ModeCard({required this.settings, required this.stopped});
  final AsyncValue<OnchainSetting?> settings;
  final bool stopped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = appColors(context);
    final theme = Theme.of(context);
    return settings.when(
      data: (s) {
        final mode = s?.mode ?? 'manual';
        final label = switch (mode) {
          'auto_limited' => 'Auto Terbatas',
          'auto_full' => 'Auto Penuh',
          _ => 'Manual',
        };
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mode eksekusi', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: DesignTokens.success, size: 18),
                  const SizedBox(width: 6),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Batas per tx: ${s?.limitPerTx ?? 0.01} · '
                'per hari: ${s?.limitPerDay ?? 0.05} · '
                'gas maks: ${s?.maxGasGwei ?? 5} gwei',
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              if (mode != 'manual') ...[
                const SizedBox(height: 6),
                Text(
                  'Mode Auto menyusul di Fase 8 (Signer + simulasi). '
                  'Pengaturan sudah disimpan.',
                  style: TextStyle(color: DesignTokens.warning, fontSize: 12),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Gagal baca pengaturan: [REDACTED]',
          style: TextStyle(color: DesignTokens.danger)),
    );
  }
}

class _KillSwitchCard extends ConsumerWidget {
  const _KillSwitchCard({required this.stopped});
  final bool stopped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = appColors(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stopped ? DesignTokens.danger.withValues(alpha: 0.08) : colors.surface,
        border: Border.all(
            color: stopped ? DesignTokens.danger : colors.border, width: stopped ? 2 : 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(stopped ? Icons.stop_circle : Icons.pan_tool_outlined,
              color: stopped ? DesignTokens.danger : DesignTokens.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stopped ? 'Kill switch AKTIF' : 'Kill switch siaga',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  stopped
                      ? 'Semua pemantauan dihentikan (K-01).'
                      : 'Hentikan semua aktivitas agent crypto.',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: DesignTokens.danger,
            ),
            onPressed: () {
              final ks = KillSwitch.instance;
              if (ks.stopped) {
                ks.deactivate();
              } else {
                ks.activate();
              }
              ref.read(killSwitchProvider.notifier).state = ks.stopped;
            },
            child: Text(stopped ? 'Nyalakan ulang' : 'HENTIKAN'),
          ),
        ],
      ),
    );
  }
}

class _WalletTile extends StatelessWidget {
  const _WalletTile({
    required this.label,
    required this.address,
    required this.balance,
    required this.threshold,
  });
  final String label;
  final String address;
  final BigInt? balance;
  final double? threshold;

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    final short = address.length > 10
        ? '${address.substring(0, 6)}…${address.substring(address.length - 4)}'
        : address;
    final amount = balance == null
        ? '—'
        // Saldo native (18 desimal default; chain lain bisa beda — Fase 7
        // memakai default ini untuk EVM mayoritas).
        : (balance!.toDouble() / 1e18).toStringAsFixed(4);
    final over = threshold != null &&
        balance != null &&
        (balance!.toDouble() / 1e18) > threshold!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: DesignTokens.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(short,
                    style: TextStyle(
                        color: colors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (over)
                Text('⚠ saldo > ambang $threshold',
                    style: TextStyle(color: DesignTokens.warning, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadonlyNotice extends StatelessWidget {
  const _ReadonlyNotice();

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignTokens.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: DesignTokens.accent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Modul crypto Fase 7 bersifat read-only: memantau saldo dan '
              'kelayakan. Tidak ada kunci sensitif yang disimpan. '
              'eksekusi transaksi menyusul di Fase 8.',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
