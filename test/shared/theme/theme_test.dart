import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/shared/theme/app_theme.dart';
import 'package:vael/shared/theme/color_tokens.dart';

/// Computes WCAG 2.1 relative luminance for a [Color].
/// See https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
double _relativeLuminance(Color color) {
  double linearize(double channel) {
    return channel <= 0.04045
        ? channel / 12.92
        : pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = linearize(color.r);
  final g = linearize(color.g);
  final b = linearize(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Computes the WCAG contrast ratio between two colors.
/// Returns a value >= 1.0; higher means more contrast.
double _contrastRatio(Color foreground, Color background) {
  final lum1 = _relativeLuminance(foreground);
  final lum2 = _relativeLuminance(background);
  final lighter = max(lum1, lum2);
  final darker = min(lum1, lum2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('AppTheme', () {
    test('light() returns ThemeData with Brightness.light', () {
      final theme = AppTheme.light();

      expect(theme, isA<ThemeData>());
      expect(theme.brightness, equals(Brightness.light));
    });

    test('dark() returns ThemeData with Brightness.dark', () {
      final theme = AppTheme.dark();

      expect(theme, isA<ThemeData>());
      expect(theme.brightness, equals(Brightness.dark));
    });

    test('light() uses Material 3', () {
      final theme = AppTheme.light();

      // ignore: deprecated_member_use
      expect(theme.useMaterial3, isTrue);
    });

    test('dark() uses Material 3', () {
      final theme = AppTheme.dark();

      // ignore: deprecated_member_use
      expect(theme.useMaterial3, isTrue);
    });
  });

  group('ColorTokens', () {
    test('positive is green (for income/positive amounts)', () {
      expect(ColorTokens.positive, equals(const Color(0xFF2E7D32)));
    });

    test('negative is red (for expenses/negative amounts)', () {
      expect(ColorTokens.negative, equals(const Color(0xFFC62828)));
    });

    test('neutral is gray (for zero amounts)', () {
      expect(ColorTokens.neutral, equals(const Color(0xFF757575)));
    });
  });

  group('WCAG AA contrast', () {
    const wcagAAMinimum = 4.5;

    test(
      'light theme — text on background has sufficient contrast ratio >= 4.5:1',
      () {
        final theme = AppTheme.light();
        final textColor = theme.colorScheme.onSurface;
        final backgroundColor = theme.colorScheme.surface;
        final ratio = _contrastRatio(textColor, backgroundColor);

        expect(
          ratio,
          greaterThanOrEqualTo(wcagAAMinimum),
          reason:
              'Light theme onSurface on surface contrast ratio $ratio '
              'does not meet WCAG AA minimum of $wcagAAMinimum:1',
        );
      },
    );

    test(
      'dark theme — text on background has sufficient contrast ratio >= 4.5:1',
      () {
        final theme = AppTheme.dark();
        final textColor = theme.colorScheme.onSurface;
        final backgroundColor = theme.colorScheme.surface;
        final ratio = _contrastRatio(textColor, backgroundColor);

        expect(
          ratio,
          greaterThanOrEqualTo(wcagAAMinimum),
          reason:
              'Dark theme onSurface on surface contrast ratio $ratio '
              'does not meet WCAG AA minimum of $wcagAAMinimum:1',
        );
      },
    );
  });
}
