import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../app/theme.dart';
import '../../shared/widgets/app_card.dart';

/// Model (design PDF: model selection & parameter page).
class ModelPage extends StatelessWidget {
  const ModelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.gridGap),
      children: [
        AppCard(
          title: 'Model aktif',
          subtitle: 'Dipilih per percakapan',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'grok-code-fast-1',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Provider: xAI · 256k konteks · default',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.gridGap),
        AppCard(
          title: 'Parameter',
          subtitle: 'Sesuaikan biaya vs kualitas',
          child: Column(
            children: [
              _param(colors, 'Suhu (temperature)', '0.7'),
              _param(colors, 'Token maksimum', '4096'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _param(AppColors colors, String label, String value) {
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
