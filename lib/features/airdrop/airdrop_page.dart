import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../app/theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_pill.dart';

/// Airdrop (design PDF: task automation for airdrop campaigns).
///
/// Data ilustratif; Fase 5 menghubungkan ke task runner + skills.
class AirdropPage extends StatelessWidget {
  const AirdropPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.gridGap),
      children: [
        AppCard(
          title: 'Kampanye aktif',
          subtitle: 'Dieksekusi oleh agen dengan izin PolicyEngine',
          trailing: StatusPill(label: '3 berjalan', tone: PillTone.success),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _task(colors, 'daftar-airdrop-solana', 'Berjalan · langkah 2/4'),
              _task(colors, 'cek-eligibilitas-berachain', 'Antri'),
              _task(colors, 'klaim-token-jupiter', 'Selesai · 09:30'),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.gridGap),
        AppCard(
          title: 'Skill airdrop',
          subtitle: 'Deklaratif (markdown + manifest) · tanpa eksekusi JS',
          child: Text(
            'Belum ada skill terpasang. Skill ditambahkan dari Pengaturan '
            'dan dijalankan setelah izin diberikan.',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _task(AppColors colors, String name, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(name,
                style: TextStyle(
                    fontSize: 12, color: colors.textPrimary)),
          ),
          Text(status,
              style: TextStyle(
                  fontSize: 11, color: colors.textSecondary)),
        ],
      ),
    );
  }
}
