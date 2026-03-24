import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/features/dashboard/providers/savings_rate_providers.dart';
import 'package:vael/features/dashboard/screens/savings_rate_detail_screen.dart';
import 'package:vael/features/dashboard/widgets/savings_rate_trend_chart.dart';
import 'package:vael/shared/theme/app_theme.dart';

/// Creates a [MonthlyMetric] for testing.
MonthlyMetric _metric({
  required String month,
  int incomePaise = 15000000,
  int expensesPaise = 8000000,
  int? rateBp,
}) {
  final rate = rateBp ??
      (incomePaise == 0
          ? 0
          : ((incomePaise - expensesPaise) * 10000 ~/ incomePaise));
  return MonthlyMetric(
    id: 'fam_a_$month',
    familyId: 'fam_a',
    month: month,
    totalIncomePaise: incomePaise,
    totalExpensesPaise: expensesPaise,
    savingsRateBp: rate,
    netWorthPaise: 0,
    computedAt: DateTime(2026, 3, 24),
  );
}

Widget _buildApp({
  required List<MonthlyMetric> metrics,
}) {
  return ProviderScope(
    overrides: [
      savingsRateMetricsProvider('fam_a').overrideWith(
        (_) async => metrics,
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const SavingsRateDetailScreen(familyId: 'fam_a'),
    ),
  );
}

void main() {
  group('SavingsRateDetailScreen', () {
    testWidgets('renders hero rate section', (tester) async {
      final metrics = [
        _metric(month: '2026-01', rateBp: 2500),
        _metric(month: '2026-02', rateBp: 3000),
        _metric(month: '2026-03', rateBp: 3200),
      ];
      await tester.pumpWidget(_buildApp(metrics: metrics));
      await tester.pumpAndSettle();

      // Hero shows current month rate (last metric = 32%)
      expect(find.text('32%'), findsOneWidget);
      expect(find.text('Healthy'), findsOneWidget);
      expect(find.text('This month'), findsOneWidget);
    });

    testWidgets('renders trend chart', (tester) async {
      final metrics = [
        _metric(month: '2026-01', rateBp: 2500),
        _metric(month: '2026-02', rateBp: 3000),
        _metric(month: '2026-03', rateBp: 3200),
      ];
      await tester.pumpWidget(_buildApp(metrics: metrics));
      await tester.pumpAndSettle();

      expect(find.text('12-Month Trend'), findsOneWidget);
      expect(find.byType(SavingsRateTrendChart), findsOneWidget);
    });

    testWidgets('health color green for rate >= 20%', (tester) async {
      final metrics = [_metric(month: '2026-03', rateBp: 2500)];
      await tester.pumpWidget(_buildApp(metrics: metrics));
      await tester.pumpAndSettle();

      // 25% -> Healthy label
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('Healthy'), findsOneWidget);
    });

    testWidgets('health color amber for rate 10-20%', (tester) async {
      final metrics = [_metric(month: '2026-03', rateBp: 1500)];
      await tester.pumpWidget(_buildApp(metrics: metrics));
      await tester.pumpAndSettle();

      // 15% -> Moderate label
      expect(find.text('15%'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
    });

    testWidgets('health color red for rate < 10%', (tester) async {
      final metrics = [_metric(month: '2026-03', rateBp: 500)];
      await tester.pumpWidget(_buildApp(metrics: metrics));
      await tester.pumpAndSettle();

      // 5% -> Low label
      expect(find.text('5%'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);
    });

    testWidgets('zero-income month shows 0% in breakdown', (tester) async {
      final metrics = [
        _metric(month: '2026-03', incomePaise: 0, expensesPaise: 0, rateBp: 0),
      ];
      await tester.pumpWidget(_buildApp(metrics: metrics));
      await tester.pumpAndSettle();

      // Hero shows 0%
      expect(find.text('0%'), findsOneWidget);
      // Breakdown shows 0.0%
      expect(find.text('0.0%'), findsOneWidget);
    });

    testWidgets('shows current month rate with only 1 month of history',
        (tester) async {
      final metrics = [_metric(month: '2026-03', rateBp: 4667)];
      await tester.pumpWidget(_buildApp(metrics: metrics));
      await tester.pumpAndSettle();

      // Shows the rate
      expect(find.text('47%'), findsOneWidget);
      // Shows "Showing 1 month of data" note
      expect(find.textContaining('Showing 1 month of data'), findsOneWidget);
    });

    testWidgets('handles empty metrics list gracefully', (tester) async {
      await tester.pumpWidget(_buildApp(metrics: []));
      await tester.pumpAndSettle();

      expect(find.text('No savings data yet'), findsOneWidget);
    });

    testWidgets('tapping month shows breakdown card', (tester) async {
      final metrics = [
        _metric(
          month: '2026-01',
          incomePaise: 20000000,
          expensesPaise: 10000000,
          rateBp: 5000,
        ),
        _metric(
          month: '2026-02',
          incomePaise: 18000000,
          expensesPaise: 12000000,
          rateBp: 3333,
        ),
        _metric(month: '2026-03', rateBp: 4667),
      ];
      await tester.pumpWidget(_buildApp(metrics: metrics));
      await tester.pumpAndSettle();

      // Default breakdown shows March 2026 (last month)
      expect(find.text('March 2026'), findsOneWidget);

      // Tap on the chart area to select a different month
      final chart = find.byType(SavingsRateTrendChart);
      expect(chart, findsOneWidget);

      // Tap at the left side of the chart to select January
      final chartBox = tester.getRect(chart);
      await tester.tapAt(Offset(chartBox.left + 45, chartBox.center.dy));
      await tester.pumpAndSettle();

      // Now January 2026 should be shown in breakdown
      expect(find.text('January 2026'), findsOneWidget);
    });

    testWidgets('shows fewer-than-12 months note', (tester) async {
      final metrics = [
        _metric(month: '2026-01', rateBp: 2500),
        _metric(month: '2026-02', rateBp: 3000),
        _metric(month: '2026-03', rateBp: 3200),
      ];
      await tester.pumpWidget(_buildApp(metrics: metrics));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Showing 3 months of data'),
        findsOneWidget,
      );
    });
  });
}
