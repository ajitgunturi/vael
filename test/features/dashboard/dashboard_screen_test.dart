import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/dashboard_aggregation.dart';
import 'package:vael/features/dashboard/providers/dashboard_providers.dart';
import 'package:vael/features/dashboard/screens/dashboard_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

DashboardData _makeData({
  int netWorth = 2500000000, // ₹2.5 crore
  int totalIncome = 15000000, // ₹1.5 lakh
  int totalExpenses = 8000000, // ₹80,000
  double? savingsRate,
}) {
  final summary = MonthlySummary(
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
  );
  return DashboardData(
    grouped: AccountGroups(
      banking: [],
      investments: [],
      loans: [],
      creditCards: [],
    ),
    netWorth: netWorth,
    monthlySummary: summary,
    savingsRate:
        savingsRate ?? DashboardAggregation.computeSavingsRate(summary),
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
        dashboardDataProvider('fam_a').overrideWith((_) => Stream.value(data)),
        dashboardScopeProvider.overrideWith((ref) => scope),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: DashboardScreen(familyId: 'fam_a', goals: goals),
      ),
    );
  }

  group('DashboardScreen', () {
    // ── 2.5.8 Hero Net Worth Card ──
    testWidgets('shows hero net worth with large formatted amount', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(data: _makeData()));
      await tester.pumpAndSettle();

      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.textContaining('2,50,00,000'), findsOneWidget);
    });

    testWidgets('shows negative net worth in expense color', (tester) async {
      await tester.pumpWidget(
        buildTestApp(data: _makeData(netWorth: -500000000)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('50,00,000'), findsOneWidget);
    });

    // ── 2.5.9 Compact Income/Expense Tiles ──
    testWidgets('shows compact income, expense, net savings tiles', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(data: _makeData()));
      await tester.pumpAndSettle();

      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Net Savings'), findsOneWidget);
      expect(find.textContaining('1,50,000'), findsWidgets);
      expect(find.textContaining('80,000'), findsWidgets);
    });

    // ── 2.5.10 Quick Actions Row ──
    testWidgets('shows quick action buttons', (tester) async {
      await tester.pumpWidget(buildTestApp(data: _makeData()));
      await tester.pumpAndSettle();

      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.text('View Accounts'), findsOneWidget);
    });

    // ── 2.5.11 Savings Rate Badge ──
    testWidgets('shows savings rate badge green when >= 20%', (tester) async {
      await tester.pumpWidget(buildTestApp(data: _makeData(savingsRate: 47)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Savings Rate: 47%'), findsOneWidget);
    });

    testWidgets('shows savings rate badge red when < 10%', (tester) async {
      await tester.pumpWidget(buildTestApp(data: _makeData(savingsRate: 5)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Savings Rate: 5%'), findsOneWidget);
    });

    // ── Goals (existing) ──
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

    testWidgets('scope toggle shows Family and Personal', (tester) async {
      await tester.pumpWidget(buildTestApp(data: _makeData()));
      await tester.pumpAndSettle();

      expect(find.text('Family'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
    });

    testWidgets('hides goals section when no goals', (tester) async {
      await tester.pumpWidget(buildTestApp(data: _makeData(), goals: []));
      await tester.pumpAndSettle();

      expect(find.text('Goals'), findsNothing);
    });
  });
}
