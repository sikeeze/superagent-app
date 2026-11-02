import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../app/theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_pill.dart';

/// Wallet (design PDF: multi-chain asset list).
///
/// Data ilustratif; Fase 4 akan menyambungkan ke wallet adapter nyata.
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.gridGap),
      children: [
        AppCard(
          title: 'Total Aset',
          subtitle: 'Estimasi nilai portofolio',
          trailing: StatusPill(label: 'Data ilustratif', tone: PillTone.neutral),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\$12,480.20',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+\$296.40 (2.4%) · 24 jam terakhir',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.gridGap),
        AppCard(
          title: 'Aset',
          subtitle: '5 chain · 8 token',
          child: Column(
            children: const [
              _AssetRow(symbol: 'SOL', name: 'Solana', amount: '24.10', value: '\$3,614.20'),
              _AssetRow(symbol: 'ETH', name: 'Ethereum', amount: '2.42', value: '\$8,120.00'),
              _AssetRow(symbol: 'USDC', name: 'USD Coin', amount: '746.00', value: '\$746.00'),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({
    required this.symbol,
    required this.name,
    required this.amount,
    required this.value,
  });

  final String symbol;
  final String name;
  final String amount;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceTint,
              borderRadius: const BorderRadius.all(
                Radius.circular(DesignTokens.radiusSm),
              ),
            ),
            child: Text(
              symbol.substring(0, 1),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DesignTokens.accent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(symbol,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(name,
                    style: TextStyle(
                        fontSize: 11, color: colors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: TextStyle(
                      fontSize: 12, color: colors.textPrimary)),
              Text(value,
                  style: TextStyle(
                      fontSize: 11, color: colors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
