import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Application theme (blueprint 8.1, 8A.6).
///
/// Dark is the default (OLED friendly). Motion is kept short and
/// transform/opacity only (M-03). Widgets read [AppColors] through
/// [ThemeExtension] so light/dark stay in sync.
class AppTheme {
  const AppTheme._();

  static ThemeData dark(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: DesignTokens.background,
      canvasColor: DesignTokens.background,
      colorScheme: const ColorScheme.dark(
        primary: DesignTokens.accent,
        onPrimary: Color(0xFF0D0F12),
        secondary: DesignTokens.accent,
        surface: DesignTokens.surface,
        onSurface: DesignTokens.textPrimary,
        error: DesignTokens.danger,
        onError: Colors.white,
      ),
      cardColor: DesignTokens.surface,
      dividerColor: DesignTokens.border,
      iconTheme: const IconThemeData(color: DesignTokens.textSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: DesignTokens.background,
        foregroundColor: DesignTokens.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: DesignTokens.sidebarBackground,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11)),
      ),
      inputDecorationTheme: _inputDecoration(dark: true),
      filledButtonTheme: _filledButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textTheme: _textTheme(base, dark: true),
      dividerTheme: const DividerThemeData(
        color: DesignTokens.border,
        thickness: 1,
        space: 1,
      ),
      extensions: const [AppColors.dark],
    );
  }

  static ThemeData light(BuildContext context) {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: DesignTokens.lightBackground,
      canvasColor: DesignTokens.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: DesignTokens.accent,
        onPrimary: Color(0xFF0D0F12),
        surface: DesignTokens.lightSurface,
        onSurface: DesignTokens.lightTextPrimary,
        error: DesignTokens.danger,
      ),
      cardColor: DesignTokens.lightSurface,
      dividerColor: DesignTokens.lightBorder,
      appBarTheme: const AppBarTheme(
        backgroundColor: DesignTokens.lightBackground,
        foregroundColor: DesignTokens.lightTextPrimary,
        elevation: 0,
      ),
      inputDecorationTheme: _inputDecoration(dark: false),
      filledButtonTheme: _filledButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textTheme: _textTheme(base, dark: false),
      extensions: const [AppColors.light],
    );
  }

  static InputDecorationTheme _inputDecoration({required bool dark}) {
    final border = dark ? DesignTokens.border : DesignTokens.lightBorder;
    final fill = dark ? DesignTokens.surface : DesignTokens.lightSurfaceTint;
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: TextStyle(
        color: dark ? DesignTokens.textSecondary : DesignTokens.lightTextSecondary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radius),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radius),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radius),
        borderSide: const BorderSide(color: DesignTokens.accent, width: 1.5),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme() => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DesignTokens.accent,
          foregroundColor: const Color(0xFF0D0D0D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme() =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.textPrimary,
          side: const BorderSide(color: DesignTokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      );

  /// High weight contrast: bold display values, muted metadata labels.
  static TextTheme _textTheme(ThemeData base, {required bool dark}) {
    final primary =
        dark ? DesignTokens.textPrimary : DesignTokens.lightTextPrimary;
    final secondary = dark
        ? DesignTokens.textSecondary
        : DesignTokens.lightTextSecondary;
    return base.textTheme.copyWith(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.15,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: primary),
      bodySmall: TextStyle(fontSize: 12, color: secondary),
      labelSmall: TextStyle(
        fontSize: 11,
        color: secondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Convenience accessor for the semantic colour extension.
///
/// Falls back to the dark [AppColors] when the enclosing theme carries no
/// extension (e.g. a bare MaterialApp in tests or an embedded subtree), so
/// a missing extension degrades visually instead of crashing the app.
AppColors appColors(BuildContext context) =>
    Theme.of(context).extension<AppColors>() ?? AppColors.dark;
