import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/budget_summary.dart';
import 'package:vael/features/budgets/widgets/budget_donut_chart.dart';

void main() {
  group('BudgetDonutChart', () {
    Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

    testWidgets('renders a PieChart', (tester) async {
      await tester.pumpWidget(
        wrap(
          BudgetDonutChart(
            rows: const [
              BudgetSummaryRow(
                categoryGroup: 'ESSENTIAL',
                limitAmount: 1000000,
                actualSpent: 600000,
                budgetId: 'b1',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('shows one section per budget row', (tester) async {
      await tester.pumpWidget(
        wrap(
          BudgetDonutChart(
            rows: const [
              BudgetSummaryRow(
                categoryGroup: 'ESSENTIAL',
                limitAmount: 1000000,
                actualSpent: 600000,
                budgetId: 'b1',
              ),
              BudgetSummaryRow(
                categoryGroup: 'NON_ESSENTIAL',
                limitAmount: 500000,
                actualSpent: 300000,
                budgetId: 'b2',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final pieChart = tester.widget<PieChart>(find.byType(PieChart));
      final sections = pieChart.data.sections;
      expect(sections, hasLength(2));
    });

    testWidgets('displays total spent in center', (tester) async {
      await tester.pumpWidget(
        wrap(
          BudgetDonutChart(
            rows: const [
              BudgetSummaryRow(
                categoryGroup: 'ESSENTIAL',
                limitAmount: 1000000,
                actualSpent: 600000,
                budgetId: 'b1',
              ),
              BudgetSummaryRow(
                categoryGroup: 'NON_ESSENTIAL',
                limitAmount: 500000,
                actualSpent: 300000,
                budgetId: 'b2',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Total: (600000 + 300000) / 100 = 9000 → ₹9,000
      expect(find.textContaining('9,000'), findsOneWidget);
    });

    testWidgets('handles empty rows gracefully', (tester) async {
      await tester.pumpWidget(wrap(const BudgetDonutChart(rows: [])));
      await tester.pumpAndSettle();

      // Should still render without crash
      expect(find.byType(BudgetDonutChart), findsOneWidget);
    });
  });
}
