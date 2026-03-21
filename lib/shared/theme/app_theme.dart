import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'spacing.dart';
import 'text_styles.dart';

/// Centralized theme configuration for Vael.
///
/// Uses custom color tokens from `UI_DESIGN.md` §1.1,
/// Inter font from §1.3, and card/spacing from §1.4.
class AppTheme {
  AppTheme._();

  /// Light theme — full design system.
  static ThemeData light() {
    final tokens = ColorTokens.light();
    final textTheme = AppTextStyles.textTheme();
    return _build(tokens, textTheme, Brightness.light);
  }

  /// Dark theme — full design system.
  static ThemeData dark() {
    final tokens = ColorTokens.dark();
    final textTheme = AppTextStyles.textTheme();
    return _build(tokens, textTheme, Brightness.dark);
  }

  static ThemeData _build(
      ColorTokens tokens, TextTheme textTheme, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: tokens.primary,
      onPrimary: tokens.onPrimary,
      primaryContainer: tokens.primaryContainer,
      onPrimaryContainer: tokens.onPrimaryContainer,
      secondary: tokens.secondary,
      onSecondary: tokens.onPrimary, // reuse
      secondaryContainer: tokens.primaryContainer,
      onSecondaryContainer: tokens.onPrimaryContainer,
      surface: tokens.surface,
      onSurface: tokens.onSurface,
      onSurfaceVariant: tokens.onSurfaceVariant,
      error: tokens.expense,
      onError: Colors.white,
      outline: tokens.outline,
      outlineVariant: tokens.outlineVariant,
      inverseSurface: tokens.inverseSurface,
      onInverseSurface: tokens.inverseOnSurface,
      surfaceDim: tokens.surfaceDim,
      surfaceContainer: tokens.surfaceContainer,
      surfaceContainerHigh: tokens.surfaceContainerHigh,
      surfaceContainerHighest: tokens.surfaceContainerHighest,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          side: BorderSide(color: tokens.outline),
        ),
        elevation: 0,
        color: tokens.surfaceContainer,
      ),
    );
  }
}
