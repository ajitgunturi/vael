import 'package:flutter/material.dart';

/// Centralized theme configuration for Vael.
///
/// Both light and dark themes use Material 3 with an indigo seed color.
/// WCAG AA contrast compliance is validated by tests.
class AppTheme {
  AppTheme._();

  static const _seed = Colors.indigo;

  /// Light theme — Material 3, indigo seed.
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
    );
  }

  /// Dark theme — Material 3, indigo seed.
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
    );
  }
}
