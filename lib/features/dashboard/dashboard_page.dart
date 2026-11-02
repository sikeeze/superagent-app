import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../app/theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_pill.dart';

/// Ringkasan / Beranda (design PDF: workspace overview).
///
/// Semua angka di sini adalah data ilustratif sampai Fase 2 menyambungkan
/// wallet dan provider AI yang nyata.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.gridGap),
      children: [
        Text('Selamat datang kembali, Raka',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Workspace pribadi · 3 agen aktif · data ilustratif',
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
        const SizedBox(height: DesignTokens.gridGap),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width > 900 ? 4 : 2,
          shrinkWrap: true,
          // P-01: tidak ikut scroll induk.
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: DesignTokens.gridGap,
          crossAxisSpacing: DesignTokens.gridGap,
          childAspectRatio: 1.4,
          children: const [
            _StatCard(label: 'Total Aset', value: '\$12,480.20', delta: '+2.4%'),
            _StatCard(label: 'Airdrop Aktif', value: '7', delta: '+2 baru'),
            _StatCard(label: 'Token SDK', value: '1,240', delta: '≈\$48'),
            _StatCard(label: 'Tugas Agen', value: '3', delta: '1 berjalan'),
          ],
        ),
        const SizedBox(height: DesignTokens.gridGap),
        AppCard(
          title: 'Aktivitas terbaru',
          subtitle: 'Audit trail lokal · append-only',
          trailing: StatusPill(label: 'Lokal', tone: PillTone.success),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _activityRow(colors, '09:42', 'Provider AI · Grok dikonfigurasi'),
              _activityRow(colors, '09:15', 'Policy engine · izin http_fetch'),
              _activityRow(
                  colors, '08:58', 'Airdrop · task daftar-airdrop-solana'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _activityRow(AppColors colors, String time, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: TextStyle(
                fontSize: 11,
                color: colors.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 12, color: colors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.delta});

  final String label;
  final String value;
  final String delta;

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: colors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            delta,
            style: TextStyle(
              fontSize: 10,
              color: DesignTokens.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
