import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/financial/dashboard_aggregation.dart';
import 'package:vael/core/providers/transaction_providers.dart';
import 'package:vael/features/accounts/providers/account_ui_providers.dart';
import 'package:vael/features/budgets/providers/budget_providers.dart';
import 'package:vael/features/dashboard/providers/dashboard_providers.dart';
import 'package:vael/features/goals/providers/goal_providers.dart';
import 'package:vael/shared/layout/adaptive_scaffold.dart';
import 'package:vael/shared/shell/home_shell.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'test_family';
const _userId = 'test_user';

const _emptyGroups = AccountGroups(
  banking: [],
  investments: [],
  loans: [],
  creditCards: [],
);

const _emptyDashboard = DashboardData(
  grouped: _emptyGroups,
  netWorth: 0,
  monthlySummary: MonthlySummary(totalIncome: 0, totalExpenses: 0),
);

Widget _buildApp() {
  final now = DateTime.now();
  final budgetKey = (familyId: _familyId, year: now.year, month: now.month);

  return ProviderScope(
    overrides: [
      // Dashboard
      dashboardDataProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(_emptyDashboard)),
      dashboardScopeProvider.overrideWith(DashboardScopeNotifier.new),
      // Accounts
      groupedAccountsProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(_emptyGroups)),
      // Transactions
      transactionsProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(const [])),
      // Budgets
      budgetSummaryProvider(budgetKey).overrideWith((_) async => const []),
      // Goals
      goalListProvider(_familyId).overrideWith((_) => Stream.value(const [])),
      sinkingFundGoalsProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(const [])),
      investmentGoalsProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(const [])),
      purchaseGoalsProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(const [])),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const HomeShell(familyId: _familyId, userId: _userId),
    ),
  );
}

void main() {
  group('HomeShell', () {
    testWidgets('renders AdaptiveScaffold with 5 tab labels', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      for (final dest in AdaptiveScaffold.destinations) {
        expect(find.text(dest.label), findsWidgets);
      }
    });

    testWidgets('shows Dashboard tab by default', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Net Worth'), findsOneWidget);
    });

    testWidgets('navigates to Accounts tab on tap', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accounts').first);
      await tester.pumpAndSettle();

      expect(find.text('Accounts'), findsWidgets);
    });

    testWidgets('navigates to Transactions tab on tap', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Transactions').first);
      await tester.pumpAndSettle();

      expect(find.text('Transactions'), findsWidgets);
    });

    testWidgets('navigates to Budget tab on tap', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Budget').first);
      await tester.pumpAndSettle();

      expect(find.text('Budget'), findsWidgets);
    });

    testWidgets('navigates to Goals tab on tap', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Goals').first);
      // Use pump instead of pumpAndSettle because GoalListScreen
      // TabController animation keeps the ticker running.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Goals'), findsWidgets);
    });

    testWidgets('shows Settings icon in navigation', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('tapping Settings navigates to SettingsScreen', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // SettingsScreen shows its app bar title
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
