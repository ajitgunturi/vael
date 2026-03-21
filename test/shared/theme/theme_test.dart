import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/shared/theme/app_theme.dart';
import 'package:vael/shared/theme/color_tokens.dart';
import 'package:vael/shared/theme/spacing.dart';

/// Computes WCAG 2.1 relative luminance for a [Color].
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
double _contrastRatio(Color foreground, Color background) {
  final lum1 = _relativeLuminance(foreground);
  final lum2 = _relativeLuminance(background);
  final lighter = max(lum1, lum2);
  final darker = min(lum1, lum2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

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

  group('Inter font integration', () {
    test('light theme uses Inter font family', () {
      final theme = AppTheme.light();
      expect(theme.textTheme.bodyMedium?.fontFamily, contains('Inter'));
    });

    test('dark theme uses Inter font family', () {
      final theme = AppTheme.dark();
      expect(theme.textTheme.bodyMedium?.fontFamily, contains('Inter'));
    });

    test('displayLarge has tabular figures for money alignment', () {
      final theme = AppTheme.light();
      final features = theme.textTheme.displayLarge?.fontFeatures;
      expect(features, isNotNull);
      expect(
        features!.any((f) => f.feature == 'tnum'),
        isTrue,
        reason: 'displayLarge should enable tabular figures for money',
      );
    });

    test('displayMedium has tabular figures', () {
      final theme = AppTheme.light();
      final features = theme.textTheme.displayMedium?.fontFeatures;
      expect(features, isNotNull);
      expect(features!.any((f) => f.feature == 'tnum'), isTrue);
    });
  });

  group('Card style (§1.4)', () {
    test('card has 12dp border radius', () {
      final theme = AppTheme.light();
      final shape = theme.cardTheme.shape as RoundedRectangleBorder;
      final radius = (shape.borderRadius as BorderRadius).topLeft.x;
      expect(radius, equals(Spacing.cardRadius));
      expect(radius, equals(12.0));
    });

    test('card has zero elevation (no shadows)', () {
      final theme = AppTheme.light();
      expect(theme.cardTheme.elevation, equals(0));
    });

    test('card uses surfaceContainer fill', () {
      final tokens = ColorTokens.light();
      final theme = AppTheme.light();
      expect(theme.cardTheme.color, equals(tokens.surfaceContainer));
    });

    test('card has outline border', () {
      final tokens = ColorTokens.light();
      final theme = AppTheme.light();
      final shape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(shape.side.color, equals(tokens.outline));
    });
  });

  group('Spacing constants (§1.4)', () {
    test('spacing values match spec', () {
      expect(Spacing.xs, equals(4.0));
      expect(Spacing.sm, equals(8.0));
      expect(Spacing.md, equals(16.0));
      expect(Spacing.lg, equals(24.0));
      expect(Spacing.xl, equals(32.0));
      expect(Spacing.xxl, equals(48.0));
    });

    test('card radius is 12dp', () {
      expect(Spacing.cardRadius, equals(12.0));
    });
  });

  group('ColorTokens legacy statics (backward compat)', () {
    test('positive is green', () {
      // ignore: deprecated_member_use
      expect(ColorTokens.positive, equals(const Color(0xFF2E7D32)));
    });

    test('negative is red', () {
      // ignore: deprecated_member_use
      expect(ColorTokens.negative, equals(const Color(0xFFC62828)));
    });

    test('neutralStatic is gray', () {
      // ignore: deprecated_member_use
      expect(ColorTokens.neutralStatic, equals(const Color(0xFF757575)));
    });
  });

  group('WCAG AA contrast', () {
    const wcagAAMinimum = 4.5;

    test('light theme — text on background has sufficient contrast', () {
      final theme = AppTheme.light();
      final textColor = theme.colorScheme.onSurface;
      final backgroundColor = theme.colorScheme.surface;
      final ratio = _contrastRatio(textColor, backgroundColor);
      expect(ratio, greaterThanOrEqualTo(wcagAAMinimum));
    });

    test('dark theme — text on background has sufficient contrast', () {
      final theme = AppTheme.dark();
      final textColor = theme.colorScheme.onSurface;
      final backgroundColor = theme.colorScheme.surface;
      final ratio = _contrastRatio(textColor, backgroundColor);
      expect(ratio, greaterThanOrEqualTo(wcagAAMinimum));
    });
  });
}
