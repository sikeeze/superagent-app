import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../app/theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_pill.dart';

/// Binance Agentic (design PDF: agent-managed trading workspace).
///
/// Fase 6: API key disimpan di SecureStore, tidak pernah ke log.
class BinancePage extends StatelessWidget {
  const BinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.gridGap),
      children: [
        AppCard(
          title: 'Binance Agentic',
          subtitle: 'Agen mengeksekusi strategi atas izin Anda',
          trailing: StatusPill(label: 'Belum terhubung', tone: PillTone.warning),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mode demo. Hubungkan API key Binance untuk memulai. '
                'Key disimpan terenkripsi di perangkat ini dan hanya '
                'mengizinkan izin yang Anda berikan.',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.link, size: 16),
                label: const Text('Hubungkan API'),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.gridGap),
        AppCard(
          title: 'Strategi',
          subtitle: 'Belum ada strategi aktif',
          child: Text(
            'Strategi dibuat sebagai skill deklaratif. Setiap eksekusi '
            'order membutuhkan izin eksplisit (risk level: high).',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}
