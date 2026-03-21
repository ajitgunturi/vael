import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/shared/theme/color_tokens.dart';

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

/// Helper to build a minimal MaterialApp with the given brightness
/// so that ColorTokens.of(context) can resolve the correct theme.
Widget _buildTestApp({
  required Brightness brightness,
  required Widget Function(BuildContext) builder,
}) {
  return MaterialApp(
    theme: ThemeData(brightness: brightness),
    home: Builder(builder: (context) => builder(context)),
  );
}

void main() {
  // ── Backward compatibility: old static constants still work ──
  group('ColorTokens legacy statics (backward compat)', () {
    test('positive is green', () {
      // ignore: deprecated_member_use_from_same_package
      expect(ColorTokens.positive, equals(const Color(0xFF2E7D32)));
    });

    test('negative is red', () {
      // ignore: deprecated_member_use_from_same_package
      expect(ColorTokens.negative, equals(const Color(0xFFC62828)));
    });

    test('neutralStatic is gray', () {
      // ignore: deprecated_member_use_from_same_package
      expect(ColorTokens.neutralStatic, equals(const Color(0xFF757575)));
    });
  });

  // ── Light theme returns correct hex values from UI_DESIGN.md §1.1 ──
  group('ColorTokens.of(context) — light mode', () {
    testWidgets('returns surface tokens matching spec', (tester) async {
      late ColorTokens tokens;
      await tester.pumpWidget(_buildTestApp(
        brightness: Brightness.light,
        builder: (ctx) {
          tokens = ColorTokens.of(ctx);
          return const SizedBox();
        },
      ));

      expect(tokens.surface, equals(const Color(0xFFFAFAF9)));
      expect(tokens.surfaceDim, equals(const Color(0xFFF0EFED)));
      expect(tokens.surfaceContainer, equals(const Color(0xFFF2F1EF)));
      expect(tokens.surfaceContainerHigh, equals(const Color(0xFFE8E7E5)));
      expect(tokens.surfaceContainerHighest, equals(const Color(0xFFDEDDDB)));
      expect(tokens.inverseSurface, equals(const Color(0xFF1A1A1A)));
    });

    testWidgets('returns text tokens matching spec', (tester) async {
      late ColorTokens tokens;
      await tester.pumpWidget(_buildTestApp(
        brightness: Brightness.light,
        builder: (ctx) {
          tokens = ColorTokens.of(ctx);
          return const SizedBox();
        },
      ));

      expect(tokens.onSurface, equals(const Color(0xFF1A1A1A)));
      expect(tokens.onSurfaceVariant, equals(const Color(0xFF6B6B6B)));
      expect(tokens.onSurfaceDisabled, equals(const Color(0xFFB0B0B0)));
      expect(tokens.inverseOnSurface, equals(const Color(0xFFF5F5F5)));
    });

    testWidgets('returns semantic tokens matching spec', (tester) async {
      late ColorTokens tokens;
      await tester.pumpWidget(_buildTestApp(
        brightness: Brightness.light,
        builder: (ctx) {
          tokens = ColorTokens.of(ctx);
          return const SizedBox();
        },
      ));

      expect(tokens.income, equals(const Color(0xFF2D7A2D)));
      expect(tokens.incomeContainer, equals(const Color(0xFFE8F5E3)));
      expect(tokens.onIncomeContainer, equals(const Color(0xFF1A4A1A)));
      expect(tokens.expense, equals(const Color(0xFFB3261E)));
      expect(tokens.expenseContainer, equals(const Color(0xFFFCECEA)));
      expect(tokens.onExpenseContainer, equals(const Color(0xFF6E1610)));
      expect(tokens.warning, equals(const Color(0xFF8B6914)));
      expect(tokens.warningContainer, equals(const Color(0xFFFFF3D6)));
      expect(tokens.onWarningContainer, equals(const Color(0xFF5C4400)));
      expect(tokens.neutral, equals(const Color(0xFF6B6B6B)));
    });

    testWidgets('returns action tokens matching spec', (tester) async {
      late ColorTokens tokens;
      await tester.pumpWidget(_buildTestApp(
        brightness: Brightness.light,
        builder: (ctx) {
          tokens = ColorTokens.of(ctx);
          return const SizedBox();
        },
      ));

      expect(tokens.primary, equals(const Color(0xFF2D5A27)));
      expect(tokens.primaryContainer, equals(const Color(0xFFD4EDCF)));
      expect(tokens.onPrimary, equals(const Color(0xFFFFFFFF)));
      expect(tokens.onPrimaryContainer, equals(const Color(0xFF0A1A08)));
      expect(tokens.secondary, equals(const Color(0xFF1A4A7A)));
      expect(tokens.outline, equals(const Color(0xFFD4D3D1)));
      expect(tokens.outlineVariant, equals(const Color(0xFFEDEDEB)));
    });

    testWidgets('returns chart tokens matching spec', (tester) async {
      late ColorTokens tokens;
      await tester.pumpWidget(_buildTestApp(
        brightness: Brightness.light,
        builder: (ctx) {
          tokens = ColorTokens.of(ctx);
          return const SizedBox();
        },
      ));

      expect(tokens.chartLine1, equals(const Color(0xFF2D5A27)));
      expect(tokens.chartLine2, equals(const Color(0xFFB3261E)));
      expect(tokens.chartLine3, equals(const Color(0xFF1A4A7A)));
      expect(tokens.chartFill1, equals(const Color(0x202D5A27)));
      expect(tokens.chartGrid, equals(const Color(0xFFEDEDEB)));
      expect(tokens.chartTooltipBg, equals(const Color(0xFF1A1A1A)));
    });
  });

  // ── Dark theme returns correct hex values from UI_DESIGN.md §1.1 ──
  group('ColorTokens.of(context) — dark mode', () {
    testWidgets('returns surface tokens matching spec', (tester) async {
      late ColorTokens tokens;
      await tester.pumpWidget(_buildTestApp(
        brightness: Brightness.dark,
        builder: (ctx) {
          tokens = ColorTokens.of(ctx);
          return const SizedBox();
        },
      ));

      expect(tokens.surface, equals(const Color(0xFF0F0F0F)));
      expect(tokens.surfaceDim, equals(const Color(0xFF0F0F0F)));
      expect(tokens.surfaceContainer, equals(const Color(0xFF1A1A1A)));
      expect(tokens.surfaceContainerHigh, equals(const Color(0xFF252525)));
      expect(tokens.surfaceContainerHighest, equals(const Color(0xFF303030)));
      expect(tokens.inverseSurface, equals(const Color(0xFFE8E8E8)));
    });

    testWidgets('returns text and semantic tokens matching spec',
        (tester) async {
      late ColorTokens tokens;
      await tester.pumpWidget(_buildTestApp(
        brightness: Brightness.dark,
        builder: (ctx) {
          tokens = ColorTokens.of(ctx);
          return const SizedBox();
        },
      ));

      // Text
      expect(tokens.onSurface, equals(const Color(0xFFE8E6E3)));
      expect(tokens.onSurfaceVariant, equals(const Color(0xFFA3A3A0)));
      expect(tokens.onSurfaceDisabled, equals(const Color(0xFF555555)));
      expect(tokens.inverseOnSurface, equals(const Color(0xFF1A1A1A)));

      // Semantic
      expect(tokens.income, equals(const Color(0xFF6ECF6E)));
      expect(tokens.expense, equals(const Color(0xFFF2B8B5)));
      expect(tokens.warning, equals(const Color(0xFFD4A843)));
      expect(tokens.neutral, equals(const Color(0xFFA3A3A0)));
    });

    testWidgets('returns action and chart tokens matching spec',
        (tester) async {
      late ColorTokens tokens;
      await tester.pumpWidget(_buildTestApp(
        brightness: Brightness.dark,
        builder: (ctx) {
          tokens = ColorTokens.of(ctx);
          return const SizedBox();
        },
      ));

      // Action
      expect(tokens.primary, equals(const Color(0xFF7BC470)));
      expect(tokens.primaryContainer, equals(const Color(0xFF1A3317)));
      expect(tokens.onPrimary, equals(const Color(0xFF0A1A08)));
      expect(tokens.onPrimaryContainer, equals(const Color(0xFFD4EDCF)));
      expect(tokens.secondary, equals(const Color(0xFF7EB3E0)));
      expect(tokens.outline, equals(const Color(0xFF3A3A3A)));
      expect(tokens.outlineVariant, equals(const Color(0xFF252525)));

      // Chart
      expect(tokens.chartLine1, equals(const Color(0xFF7BC470)));
      expect(tokens.chartLine2, equals(const Color(0xFFF2B8B5)));
      expect(tokens.chartLine3, equals(const Color(0xFF7EB3E0)));
      expect(tokens.chartFill1, equals(const Color(0x207BC470)));
      expect(tokens.chartGrid, equals(const Color(0xFF252525)));
      expect(tokens.chartTooltipBg, equals(const Color(0xFF303030)));
    });
  });

  // ── WCAG AA contrast verification on all text/surface pairs ──
  group('WCAG AA contrast (4.5:1 minimum)', () {
    const wcagAA = 4.5;

    // Light mode pairs
    test('light — onSurface on surface', () {
      final tokens = ColorTokens.light();
      final ratio = _contrastRatio(tokens.onSurface, tokens.surface);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'light onSurface/surface ratio: $ratio');
    });

    test('light — onSurfaceVariant on surface', () {
      final tokens = ColorTokens.light();
      final ratio = _contrastRatio(tokens.onSurfaceVariant, tokens.surface);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'light onSurfaceVariant/surface ratio: $ratio');
    });

    test('light — income on surface', () {
      final tokens = ColorTokens.light();
      final ratio = _contrastRatio(tokens.income, tokens.surface);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'light income/surface ratio: $ratio');
    });

    test('light — expense on surface', () {
      final tokens = ColorTokens.light();
      final ratio = _contrastRatio(tokens.expense, tokens.surface);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'light expense/surface ratio: $ratio');
    });

    test('light — onIncomeContainer on incomeContainer', () {
      final tokens = ColorTokens.light();
      final ratio =
          _contrastRatio(tokens.onIncomeContainer, tokens.incomeContainer);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'light onIncomeContainer/incomeContainer ratio: $ratio');
    });

    test('light — onExpenseContainer on expenseContainer', () {
      final tokens = ColorTokens.light();
      final ratio =
          _contrastRatio(tokens.onExpenseContainer, tokens.expenseContainer);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'light onExpenseContainer/expenseContainer ratio: $ratio');
    });

    test('light — onPrimary on primary', () {
      final tokens = ColorTokens.light();
      final ratio = _contrastRatio(tokens.onPrimary, tokens.primary);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'light onPrimary/primary ratio: $ratio');
    });

    // Dark mode pairs
    test('dark — onSurface on surface', () {
      final tokens = ColorTokens.dark();
      final ratio = _contrastRatio(tokens.onSurface, tokens.surface);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'dark onSurface/surface ratio: $ratio');
    });

    test('dark — onSurfaceVariant on surface', () {
      final tokens = ColorTokens.dark();
      final ratio = _contrastRatio(tokens.onSurfaceVariant, tokens.surface);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'dark onSurfaceVariant/surface ratio: $ratio');
    });

    test('dark — income on surface', () {
      final tokens = ColorTokens.dark();
      final ratio = _contrastRatio(tokens.income, tokens.surface);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'dark income/surface ratio: $ratio');
    });

    test('dark — expense on surface', () {
      final tokens = ColorTokens.dark();
      final ratio = _contrastRatio(tokens.expense, tokens.surface);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'dark expense/surface ratio: $ratio');
    });

    test('dark — onIncomeContainer on incomeContainer', () {
      final tokens = ColorTokens.dark();
      final ratio =
          _contrastRatio(tokens.onIncomeContainer, tokens.incomeContainer);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'dark onIncomeContainer/incomeContainer ratio: $ratio');
    });

    test('dark — onExpenseContainer on expenseContainer', () {
      final tokens = ColorTokens.dark();
      final ratio =
          _contrastRatio(tokens.onExpenseContainer, tokens.expenseContainer);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'dark onExpenseContainer/expenseContainer ratio: $ratio');
    });

    test('dark — onPrimary on primary', () {
      final tokens = ColorTokens.dark();
      final ratio = _contrastRatio(tokens.onPrimary, tokens.primary);
      expect(ratio, greaterThanOrEqualTo(wcagAA),
          reason: 'dark onPrimary/primary ratio: $ratio');
    });
  });
}
