import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../app/theme.dart';

/// Status pill used across the workspace (design PDF: status pills).
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = PillTone.neutral,
    this.icon,
  });

  final String label;
  final PillTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _background(colors),
        borderRadius: const BorderRadius.all(
          Radius.circular(DesignTokens.radiusSm),
        ),
        border: Border.all(color: _border(colors), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: _foreground(colors)),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _foreground(colors),
            ),
          ),
        ],
      ),
    );
  }

  Color _background(AppColors c) {
    switch (tone) {
      case PillTone.accent:
        return DesignTokens.accentDim;
      case PillTone.success:
        return const Color(0x213FB950);
      case PillTone.warning:
        return DesignTokens.warningBackground;
      case PillTone.danger:
        return const Color(0x33F85149);
      case PillTone.neutral:
        return c.surfaceTint;
    }
  }

  Color _foreground(AppColors c) {
    switch (tone) {
      case PillTone.accent:
        return DesignTokens.accent;
      case PillTone.success:
        return DesignTokens.success;
      case PillTone.warning:
        return DesignTokens.warning;
      case PillTone.danger:
        return DesignTokens.danger;
      case PillTone.neutral:
        return c.textSecondary;
    }
  }

  Color _border(AppColors c) => Colors.transparent;
}

enum PillTone { neutral, accent, success, warning, danger }
