import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/dashboard_aggregation.dart';
import 'package:vael/features/dashboard/providers/dashboard_providers.dart';
import 'package:vael/features/dashboard/screens/dashboard_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

DashboardData _fakeData() {
  return DashboardData(
    grouped: AccountGroups(
      banking: [],
      investments: [],
      loans: [],
      creditCards: [],
    ),
    netWorth: 500000000,
    monthlySummary: const MonthlySummary(
      totalIncome: 10000000,
      totalExpenses: 6000000,
    ),
    savingsRate: 40.0,
  );
}

void main() {
  Widget buildTestApp({void Function(int)? onNavigateToTab}) {
    return ProviderScope(
      overrides: [
        dashboardDataProvider(
          'fam_a',
        ).overrideWith((_) => Stream.value(_fakeData())),
        dashboardScopeProvider.overrideWith(DashboardScopeNotifier.new),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: DashboardScreen(
          familyId: 'fam_a',
          onNavigateToTab: onNavigateToTab,
        ),
      ),
    );
  }

  group('Dashboard Card Tap Navigation', () {
    testWidgets('hero net worth card has tap feedback (InkWell)', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets(
      'tapping income tile calls onNavigateToTab(2) for transactions',
      (tester) async {
        int? tappedTab;
        await tester.pumpWidget(
          buildTestApp(onNavigateToTab: (tab) => tappedTab = tab),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Income'));
        expect(tappedTab, 2); // Transactions tab
      },
    );

    testWidgets('tapping expenses tile calls onNavigateToTab(3) for budget', (
      tester,
    ) async {
      int? tappedTab;
      await tester.pumpWidget(
        buildTestApp(onNavigateToTab: (tab) => tappedTab = tab),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Expenses'));
      expect(tappedTab, 3); // Budget tab
    });
  });
}
