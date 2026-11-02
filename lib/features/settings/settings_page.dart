import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../app/theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_pill.dart';
import '../provider/provider_settings_page.dart';

/// Pengaturan (design PDF: settings index).
///
/// Menampilkan status keamanan + jalan pintas ke konfigurasi provider.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.gridGap),
      children: [
        AppCard(
          title: 'Keamanan',
          subtitle: 'Status perlindungan perangkat',
          trailing: StatusPill(label: 'Aktif', tone: PillTone.success),
          child: Column(
            children: [
              _row(colors, 'Penyimpanan aman', 'Keystore / Enclave'),
              _row(colors, 'Redaksi secret', 'Audit & log'),
              _row(colors, 'Policy engine', 'Konfirmasi per aksi'),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.gridGap),
        AppCard(
          title: 'Integrasi',
          subtitle: 'Provider AI, Binance, Supabase',
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.hub_outlined,
                title: 'Provider AI',
                subtitle: 'Konfigurasi kunci & model',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProviderSettingsPage(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.gridGap),
        AppCard(
          title: 'Tentang',
          subtitle: 'superagent v0.1.0 · Fase 0–3',
          child: Text(
            'Workspace agen AI lokal-pertama. Data Anda tetap di '
            'perangkat ini kecuali Anda menghubungkannya.',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _row(AppColors colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 12, color: colors.textPrimary)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 12, color: colors.textSecondary)),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext formContext) {
    final colors = appColors(formContext);
    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.all(
        Radius.circular(DesignTokens.radiusSm),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(
          Radius.circular(DesignTokens.radiusSm),
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11, color: colors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
