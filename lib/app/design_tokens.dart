import 'package:flutter/material.dart';

/// Centralised design tokens (blueprint 8A.6).
///
/// One source of truth for colour, spacing, motion duration and curves so
/// that every screen stays consistent and cheap to rebuild (rule P-06).
/// Visual language follows the latest product design: flat dark surfaces,
/// 1px borders, single neon-lime accent.
abstract final class DesignTokens {
  // ── Colour ─────────────────────────────────────────────────────
  static const Color background = Color(0xFF0D0F12);
  static const Color sidebarBackground = Color(0xFF08090B);
  static const Color surface = Color(0xFF16191E);
  static const Color surfaceTint = Color(0xFF1E222A);
  static const Color border = Color(0xFF252932);
  static const Color accent = Color(0xFFC8F526);
  static const Color accentDim = Color(0xFF2A2E1A);
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFE5B842);
  static const Color warningBackground = Color(0xFF2A2415);
  static const Color danger = Color(0xFFF85149);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A909E);

  // Light theme counterparts (rule 8.1: light mode available).
  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceTint = Color(0xFFF0F2F5);
  static const Color lightBorder = Color(0xFFE1E4EA);
  static const Color lightTextPrimary = Color(0xFF0D0F12);
  static const Color lightTextSecondary = Color(0xFF5A616E);

  // ── Shape ──────────────────────────────────────────────────────
  static const double radiusSm = 6.0;
  static const double radius = 8.0;
  static const double radiusLg = 12.0;
  static const double cardPadding = 20.0;
  static const double gridGap = 16.0;

  // ── Motion (blueprint 8A.1: M-02) ─────────────────────────────
  static const Duration micro = Duration(milliseconds: 160);
  static const Duration transition = Duration(milliseconds: 280);
  static const Duration sheet = Duration(milliseconds: 240);
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;

  // ── Layout breakpoints (blueprint 8.2) ────────────────────────
  static const double singleColumn = 600;
  static const double threeColumn = 1000;
  static const double sidebarWidth = 240.0;
}

/// Semantic colour helpers so widgets never hard-code hex values.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.sidebar,
    required this.surface,
    required this.surfaceTint,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color background;
  final Color sidebar;
  final Color surface;
  final Color surfaceTint;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  static const dark = AppColors(
    background: DesignTokens.background,
    sidebar: DesignTokens.sidebarBackground,
    surface: DesignTokens.surface,
    surfaceTint: DesignTokens.surfaceTint,
    border: DesignTokens.border,
    textPrimary: DesignTokens.textPrimary,
    textSecondary: DesignTokens.textSecondary,
  );

  static const light = AppColors(
    background: DesignTokens.lightBackground,
    sidebar: DesignTokens.lightSurface,
    surface: DesignTokens.lightSurface,
    surfaceTint: DesignTokens.lightSurfaceTint,
    border: DesignTokens.lightBorder,
    textPrimary: DesignTokens.lightTextPrimary,
    textSecondary: DesignTokens.lightTextSecondary,
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? sidebar,
    Color? surface,
    Color? surfaceTint,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
  }) =>
      AppColors(
        background: background ?? this.background,
        sidebar: sidebar ?? this.sidebar,
        surface: surface ?? this.surface,
        surfaceTint: surfaceTint ?? this.surfaceTint,
        border: border ?? this.border,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}
