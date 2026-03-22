import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/shared/theme/color_tokens.dart';

/// Compute WCAG 2.1 contrast ratio between foreground and background.
double contrastRatio(Color fg, Color bg) {
  double linearize(int channel) {
    final s = channel / 255.0;
    return s <= 0.03928
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  double luminance(Color c) {
    return 0.2126 * linearize(c.red) +
        0.7152 * linearize(c.green) +
        0.0722 * linearize(c.blue);
  }

  final l1 = luminance(fg);
  final l2 = luminance(bg);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('WCAG AA contrast — light theme', () {
    final tokens = ColorTokens.light();

    test('onSurface on surface ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.onSurface, tokens.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('onSurfaceVariant on surface ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.onSurfaceVariant, tokens.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('primary on surface ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.primary, tokens.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('onPrimary on primary ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.onPrimary, tokens.primary),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('expense on surface ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.expense, tokens.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('income on surface ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.income, tokens.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('onIncomeContainer on incomeContainer ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.onIncomeContainer, tokens.incomeContainer),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('onExpenseContainer on expenseContainer ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.onExpenseContainer, tokens.expenseContainer),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('WCAG AA contrast — dark theme', () {
    final tokens = ColorTokens.dark();

    test('onSurface on surface ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.onSurface, tokens.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('onSurfaceVariant on surface ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.onSurfaceVariant, tokens.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('primary on surface ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.primary, tokens.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('expense on surface ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.expense, tokens.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('income on surface ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.income, tokens.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('onIncomeContainer on incomeContainer ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.onIncomeContainer, tokens.incomeContainer),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('onExpenseContainer on expenseContainer ≥ 4.5:1', () {
      expect(
        contrastRatio(tokens.onExpenseContainer, tokens.expenseContainer),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('Dynamic type scaling', () {
    testWidgets('text renders at 2x scale without overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: const [
                    Text('Net Worth'),
                    Text('₹1,00,000'),
                    Text('Monthly Budget'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.text('₹1,00,000'), findsOneWidget);
    });

    testWidgets('text renders at 0.8x scale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(0.8)),
            child: const Scaffold(body: Text('Small text')),
          ),
        ),
      );

      expect(find.text('Small text'), findsOneWidget);
    });
  });

  group('Semantics labels', () {
    testWidgets('Semantics widget wraps financial data', (tester) async {
      // Verify Semantics widget is usable with label
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              label: 'Net worth: rupees 1,00,000',
              child: const Text('₹1,00,000'),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.text('₹1,00,000'));
      expect(semantics.label, contains('Net worth'));
    });

    testWidgets('progress indicator has percentage label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              label: '75 percent saved',
              child: const LinearProgressIndicator(value: 0.75),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(
        find.byType(LinearProgressIndicator),
      );
      expect(semantics.label, contains('percent saved'));
    });
  });
}
