import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/budget_summary.dart';
import 'package:vael/features/budgets/providers/budget_providers.dart';
import 'package:vael/features/budgets/screens/budget_screen.dart';
import 'package:vael/shared/theme/color_tokens.dart';

void main() {
  Widget buildTestApp({required List<BudgetSummaryRow> rows}) {
    final key = (familyId: 'fam_a', year: 2025, month: 3);
    return ProviderScope(
      overrides: [
        budgetSummaryProvider(key).overrideWith((_) async => rows),
      ],
      child: const MaterialApp(
        home: BudgetScreen(familyId: 'fam_a', year: 2025, month: 3),
      ),
    );
  }

  group('BudgetScreen', () {
    testWidgets('shows budget groups with progress bars', (tester) async {
      await tester.pumpWidget(buildTestApp(rows: [
        const BudgetSummaryRow(
          categoryGroup: 'ESSENTIAL',
          limitAmount: 1000000,
          actualSpent: 600000,
          budgetId: 'b1',
        ),
        const BudgetSummaryRow(
          categoryGroup: 'NON_ESSENTIAL',
          limitAmount: 500000,
          actualSpent: 200000,
          budgetId: 'b2',
        ),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Essential'), findsOneWidget);
      expect(find.text('Non-Essential'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('highlights overspent groups', (tester) async {
      await tester.pumpWidget(buildTestApp(rows: [
        const BudgetSummaryRow(
          categoryGroup: 'ESSENTIAL',
          limitAmount: 500000,
          actualSpent: 700000,
          budgetId: 'b1',
        ),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Overspent'), findsOneWidget);

      // Verify overspent text is red
      final overspentWidget = tester.widget<Text>(find.text('Overspent'));
      expect(overspentWidget.style?.color, ColorTokens.negative);
    });

    testWidgets('shows formatted spend amounts in Indian notation',
        (tester) async {
      await tester.pumpWidget(buildTestApp(rows: [
        const BudgetSummaryRow(
          categoryGroup: 'ESSENTIAL',
          limitAmount: 10000000, // ₹1,00,000
          actualSpent: 5000000, // ₹50,000
          budgetId: 'b1',
        ),
      ]));
      await tester.pumpAndSettle();

      // "50,000" appears in spend line and remaining line.
      expect(find.textContaining('50,000'), findsWidgets);
      expect(find.textContaining('1,00,000'), findsOneWidget);
    });

    testWidgets('shows empty state when no budgets', (tester) async {
      await tester.pumpWidget(buildTestApp(rows: []));
      await tester.pumpAndSettle();

      expect(find.text('No budgets set'), findsOneWidget);
    });

    testWidgets('shows month and year in app bar', (tester) async {
      await tester.pumpWidget(buildTestApp(rows: []));
      await tester.pumpAndSettle();

      expect(find.text('Budget — Mar 2025'), findsOneWidget);
    });

    testWidgets('shows uncategorized group label for MISSING', (tester) async {
      await tester.pumpWidget(buildTestApp(rows: [
        const BudgetSummaryRow(
          categoryGroup: 'MISSING',
          limitAmount: 0,
          actualSpent: 150000,
        ),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Uncategorized'), findsOneWidget);
      expect(find.text('Overspent'), findsOneWidget);
    });
  });
}
