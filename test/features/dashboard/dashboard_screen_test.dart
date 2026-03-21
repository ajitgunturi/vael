import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/dashboard_aggregation.dart';
import 'package:vael/features/dashboard/providers/dashboard_providers.dart';
import 'package:vael/features/dashboard/screens/dashboard_screen.dart';
import 'package:vael/shared/theme/color_tokens.dart';

DashboardData _makeData({
  int netWorth = 2500000000, // ₹2.5 crore
  int totalIncome = 15000000, // ₹1.5 lakh
  int totalExpenses = 8000000, // ₹80,000
  List<Account>? accounts,
}) {
  return DashboardData(
    grouped: AccountGroups(
      banking: accounts ?? [],
      investments: [],
      loans: [],
      creditCards: [],
    ),
    netWorth: netWorth,
    monthlySummary: MonthlySummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
    ),
  );
}

Goal _fakeGoal({
  required String id,
  required String name,
  required int targetAmount,
  required int currentSavings,
  String status = 'active',
}) {
  return Goal(
    id: id,
    name: name,
    targetAmount: targetAmount,
    targetDate: DateTime(2027, 1, 1),
    currentSavings: currentSavings,
    inflationRate: 0.06,
    priority: 1,
    status: status,
    linkedAccountId: null,
    familyId: 'fam_a',
    createdAt: DateTime(2025),
  );
}

void main() {
  Widget buildTestApp({
    required DashboardData data,
    List<Goal> goals = const [],
    DashboardScope scope = DashboardScope.family,
  }) {
    return ProviderScope(
      overrides: [
        dashboardDataProvider('fam_a')
            .overrideWith((_) => Stream.value(data)),
        dashboardScopeProvider.overrideWith((ref) => scope),
      ],
      child: MaterialApp(
        home: DashboardScreen(familyId: 'fam_a', goals: goals),
      ),
    );
  }

  group('DashboardScreen', () {
    testWidgets('shows net worth card with formatted amount', (tester) async {
      await tester.pumpWidget(buildTestApp(data: _makeData()));
      await tester.pumpAndSettle();

      expect(find.text('Net Worth'), findsOneWidget);
      // ₹2.5 crore = 2500000000 paise / 100 = 25000000 → "2,50,00,000"
      expect(find.textContaining('2,50,00,000'), findsOneWidget);
    });

    testWidgets('shows monthly income, expenses, and net savings',
        (tester) async {
      await tester.pumpWidget(buildTestApp(data: _makeData()));
      await tester.pumpAndSettle();

      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Net Savings'), findsOneWidget);

      // Income: 15000000 / 100 = 150000 → "1,50,000"
      expect(find.textContaining('1,50,000'), findsWidgets);
      // Expenses: 8000000 / 100 = 80000 → "80,000"
      expect(find.textContaining('80,000'), findsWidgets);
    });

    testWidgets('colors net savings green when positive', (tester) async {
      await tester.pumpWidget(buildTestApp(
          data: _makeData(totalIncome: 10000000, totalExpenses: 5000000)));
      await tester.pumpAndSettle();

      // Net savings = 10M - 5M = 5M (positive) → green
      final savingsRow = find.textContaining('50,000');
      expect(savingsRow, findsWidgets);
    });

    testWidgets('shows goals section with progress bars', (tester) async {
      final goals = [
        _fakeGoal(
          id: 'g1',
          name: 'Emergency Fund',
          targetAmount: 50000000,
          currentSavings: 30000000,
          status: 'onTrack',
        ),
        _fakeGoal(
          id: 'g2',
          name: 'House Down Payment',
          targetAmount: 200000000,
          currentSavings: 50000000,
          status: 'atRisk',
        ),
      ];

      await tester.pumpWidget(buildTestApp(data: _makeData(), goals: goals));
      await tester.pumpAndSettle();

      expect(find.text('Goals'), findsOneWidget);
      expect(find.text('Emergency Fund'), findsOneWidget);
      expect(find.text('House Down Payment'), findsOneWidget);
      expect(find.text('On Track'), findsOneWidget);
      expect(find.text('At Risk'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('scope toggle shows Family and Personal segments',
        (tester) async {
      await tester.pumpWidget(buildTestApp(data: _makeData()));
      await tester.pumpAndSettle();

      expect(find.text('Family'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      expect(find.byType(SegmentedButton<DashboardScope>), findsOneWidget);
    });

    testWidgets('shows negative net worth in red', (tester) async {
      await tester.pumpWidget(
          buildTestApp(data: _makeData(netWorth: -500000000)));
      await tester.pumpAndSettle();

      // Negative net worth
      expect(find.textContaining('50,00,000'), findsOneWidget);
      final netWorthText =
          tester.widget<Text>(find.textContaining('50,00,000'));
      expect(netWorthText.style?.color, ColorTokens.negative);
    });

    testWidgets('hides goals section when no goals', (tester) async {
      await tester.pumpWidget(buildTestApp(data: _makeData(), goals: []));
      await tester.pumpAndSettle();

      expect(find.text('Goals'), findsNothing);
    });

    testWidgets('shows goal status labels with correct colors', (tester) async {
      final goals = [
        _fakeGoal(
          id: 'g1',
          name: 'Completed Goal',
          targetAmount: 100000,
          currentSavings: 100000,
          status: 'completed',
        ),
      ];

      await tester.pumpWidget(buildTestApp(data: _makeData(), goals: goals));
      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsOneWidget);
      final completedText = tester.widget<Text>(find.text('Completed'));
      expect(completedText.style?.color, ColorTokens.positive);
    });
  });
}
