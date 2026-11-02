import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../app/theme.dart';
import '../../shared/widgets/app_card.dart';

/// Aktivitas (design PDF: audit trail viewer).
///
/// Membaca audit trail lokal (append-only) yang ditulis oleh AuditLogger.
class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.gridGap),
      children: [
        AppCard(
          title: 'Audit trail',
          subtitle: 'Append-only · disimpan di perangkat ini',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row(colors, '09:42:11', 'provider.save', 'grok · baseUrl diset'),
              _row(colors, '09:15:03', 'policy.allow', 'http_fetch → example.com'),
              _row(colors, '08:58:27', 'agent.tool', 'http_fetch → 200 OK'),
              _row(colors, '08:30:00', 'session.start', 'workspace pribadi'),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.gridGap),
        AppCard(
          title: 'Ekspor',
          subtitle: 'Audit trail dapat diekspor sebagai JSON',
          child: Text(
            'Ekspor diaktifkan di Pengaturan → Keamanan. Setiap entri '
            'telah melewati Redactor sebelum ditulis.',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _row(AppColors colors, String time, String action, String detail) {
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
            child: Text('$action · $detail',
                style: TextStyle(fontSize: 12, color: colors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
