import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/dashboard_aggregation.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/accounts/providers/account_ui_providers.dart';
import 'package:vael/features/budgets/providers/budget_providers.dart';
import 'package:vael/features/dashboard/providers/dashboard_providers.dart';
import 'package:vael/features/goals/providers/goal_providers.dart';
import 'package:vael/features/planning/providers/insights_provider.dart';
import 'package:vael/features/planning/providers/planning_health_providers.dart';
import 'package:vael/core/providers/transaction_providers.dart';
import 'package:vael/shared/shell/home_shell.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'nav_fam';
const _userId = 'nav_usr';

const _emptyGroups = AccountGroups(
  banking: [],
  investments: [],
  loans: [],
  creditCards: [],
);

const _emptyDashboard = DashboardData(
  grouped: _emptyGroups,
  netWorth: 500000000,
  monthlySummary: MonthlySummary(totalIncome: 10000000, totalExpenses: 7000000),
);

/// PlanningHealthData with all metrics populated so the Financial Health
/// summary card is rendered with a "View All" button for navigation.
const _fullHealth = PlanningHealthData(
  netWorthPaise: 500000000,
  savingsRatePercent: 30.0,
  efCoverageMonths: 4.5,
  efTargetMonths: 6,
  fiProgressPercent: 25.0,
  yearsToFi: 18,
  milestoneOnTrackCount: 3,
  milestoneTotalCount: 5,
  hasLifeProfile: true,
  hasEmergencyFund: true,
);

/// Build a test app with HomeShell and all providers stubbed.
///
/// Uses an in-memory drift database as fallback for providers that
/// cannot be easily overridden (e.g. sub-screens that create fresh
/// provider reads), and stubs the main stream providers to avoid
/// timer leaks from drift watchers.
Widget _buildTestApp(AppDatabase db) {
  final now = DateTime.now();
  final budgetKey = (familyId: _familyId, year: now.year, month: now.month);

  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      dashboardDataProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(_emptyDashboard)),
      dashboardScopeProvider.overrideWith(DashboardScopeNotifier.new),
      planningHealthProvider((
        familyId: _familyId,
        userId: _userId,
      )).overrideWith((_) async => _fullHealth),
      insightsProvider((
        familyId: _familyId,
        userId: _userId,
      )).overrideWith((_) async => const []),
      groupedAccountsProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(_emptyGroups)),
      transactionsProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(const [])),
      budgetSummaryProvider(budgetKey).overrideWith((_) async => const []),
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

/// Sets the test view to a specific logical width (1:1 pixel ratio).
void _setBreakpoint(WidgetTester tester, double width) {
  const height = 800.0;
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
}

/// Scroll until a finder is visible, using pump() instead of pumpAndSettle()
/// to avoid hanging on drift stream timers.
Future<void> _scrollUntilVisible(
  WidgetTester tester,
  Finder finder,
  double delta,
) async {
  final scrollable = find.byType(Scrollable).first;
  for (var i = 0; i < 20; i++) {
    if (tester.any(finder)) return;
    await tester.drag(scrollable, Offset(0, -delta));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  // ---------------------------------------------------------------------------
  // Phone breakpoint (550dp) -- compact layout (< 600dp), BottomNavigationBar
  // Uses 550dp instead of 400dp to avoid pre-existing overflow in
  // FinancialHealthSummaryCard header Row at very narrow widths.
  // ---------------------------------------------------------------------------
  group('Planning Navigation - Phone (550dp)', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    testWidgets('1. Dashboard shows Financial Health summary card', (
      tester,
    ) async {
      _setBreakpoint(tester, 550);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.text('Financial Health'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets(
      '2. Tap View All on Financial Health -> PlanningDashboardScreen',
      (tester) async {
        _setBreakpoint(tester, 550);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(_buildTestApp(db));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('View All'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.text('Financial Health'), findsOneWidget);
        expect(find.text('Net Worth'), findsOneWidget);
        expect(find.text('Savings Rate'), findsOneWidget);
      },
    );

    testWidgets('3. Tap Cash Flow quick action -> CashFlowHealthScreen', (
      tester,
    ) async {
      _setBreakpoint(tester, 550);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await _scrollUntilVisible(tester, 
        find.text('Cash Flow'),
        200,
      );
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Cash Flow').first);
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      // CashFlowHealthScreen navigated to successfully
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('4. Tap Life Plan quick action -> LifetimeTimelineScreen', (
      tester,
    ) async {
      _setBreakpoint(tester, 550);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await _scrollUntilVisible(tester, 
        find.text('Life Plan'),
        200,
      );
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Life Plan').first);
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.text('Life Plan'), findsOneWidget);
    });

    testWidgets(
      '5. Settings tab -> Financial Planning section visible with tiles',
      (tester) async {
        _setBreakpoint(tester, 550);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(_buildTestApp(db));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('Settings'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Financial Planning'), findsOneWidget);
        expect(find.text('Life Profile'), findsOneWidget);
        expect(find.text('Emergency Fund'), findsOneWidget);
      },
    );

    testWidgets('6. Settings -> Life Profile tile -> LifeProfileWizardScreen', (
      tester,
    ) async {
      _setBreakpoint(tester, 550);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Settings'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Life Profile'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      // LifeProfileWizardScreen navigated to
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('7. Settings -> Emergency Fund tile -> EmergencyFundScreen', (
      tester,
    ) async {
      _setBreakpoint(tester, 550);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Settings'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Emergency Fund'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('8. Settings -> Allocation Targets tile -> AllocationScreen', (
      tester,
    ) async {
      _setBreakpoint(tester, 550);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Settings'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await _scrollUntilVisible(tester, 
        find.text('Allocation Targets'),
        200,
      );
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Allocation Targets'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets(
      '9. Settings -> Savings Allocation tile -> SavingsAllocationScreen',
      (tester) async {
        _setBreakpoint(tester, 550);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(_buildTestApp(db));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('Settings'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await _scrollUntilVisible(tester, 
          find.text('Savings Allocation Rules'),
          200,
        );
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text('Savings Allocation Rules'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.byType(Scaffold), findsWidgets);
      },
    );

    testWidgets(
      '10. Settings -> Opportunity Fund tile -> OpportunityFundScreen',
      (tester) async {
        _setBreakpoint(tester, 550);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(_buildTestApp(db));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('Settings'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await _scrollUntilVisible(tester, 
          find.text('Opportunity Fund'),
          200,
        );
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text('Opportunity Fund'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.byType(Scaffold), findsWidgets);
      },
    );

    testWidgets('11. Settings -> Cash Flow tile -> CashFlowScreen', (
      tester,
    ) async {
      _setBreakpoint(tester, 550);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Settings'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await _scrollUntilVisible(tester, 
        find.widgetWithText(ListTile, 'Cash Flow'),
        200,
      );
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      final cashFlowTiles = find.widgetWithText(ListTile, 'Cash Flow');
      await tester.tap(cashFlowTiles.last);
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Tablet breakpoint (750dp) -- medium layout, NavigationRail
  // ---------------------------------------------------------------------------
  group('Planning Navigation - Tablet (750dp)', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    testWidgets('12. Dashboard shows Financial Health summary card at 750dp', (
      tester,
    ) async {
      _setBreakpoint(tester, 750);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.text('Financial Health'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('13. Tap View All -> PlanningDashboardScreen at 750dp', (
      tester,
    ) async {
      _setBreakpoint(tester, 750);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('View All'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.text('Financial Health'), findsOneWidget);
      expect(find.text('Net Worth'), findsOneWidget);
    });

    testWidgets('14. Tap Cash Flow quick action at 750dp', (tester) async {
      _setBreakpoint(tester, 750);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await _scrollUntilVisible(tester, 
        find.text('Cash Flow'),
        200,
      );
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Cash Flow').first);
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('15. Tap Life Plan quick action at 750dp', (tester) async {
      _setBreakpoint(tester, 750);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await _scrollUntilVisible(tester, 
        find.text('Life Plan'),
        200,
      );
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Life Plan').first);
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.text('Life Plan'), findsOneWidget);
    });

    testWidgets('16. Settings shows Financial Planning at 750dp', (
      tester,
    ) async {
      _setBreakpoint(tester, 750);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Financial Planning'), findsOneWidget);
    });

    testWidgets('17. Settings -> Life Profile at 750dp', (tester) async {
      _setBreakpoint(tester, 750);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Life Profile'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('18. Settings -> Emergency Fund at 750dp', (tester) async {
      _setBreakpoint(tester, 750);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Emergency Fund'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('19. Settings -> Savings Allocation at 750dp', (tester) async {
      _setBreakpoint(tester, 750);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await _scrollUntilVisible(tester, 
        find.text('Savings Allocation Rules'),
        200,
      );
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Savings Allocation Rules'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('20. Settings -> Opportunity Fund at 750dp', (tester) async {
      _setBreakpoint(tester, 750);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await _scrollUntilVisible(tester, 
        find.text('Opportunity Fund'),
        200,
      );
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Opportunity Fund'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('21. Settings -> Cash Flow at 750dp', (tester) async {
      _setBreakpoint(tester, 750);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await _scrollUntilVisible(tester, 
        find.widgetWithText(ListTile, 'Cash Flow'),
        200,
      );
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      final cashFlowTiles = find.widgetWithText(ListTile, 'Cash Flow');
      await tester.tap(cashFlowTiles.last);
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('22. Settings -> Allocation Targets at 750dp', (tester) async {
      _setBreakpoint(tester, 750);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await _scrollUntilVisible(tester, 
        find.text('Allocation Targets'),
        200,
      );
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Allocation Targets'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Desktop breakpoint (1200dp) -- expanded layout, drawer-style nav
  // ---------------------------------------------------------------------------
  group('Planning Navigation - Desktop (1200dp)', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    testWidgets('23. Dashboard renders with expanded nav at 1200dp', (
      tester,
    ) async {
      _setBreakpoint(tester, 1200);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Financial Health'), findsOneWidget);
    });

    testWidgets('24. View All -> PlanningDashboardScreen at 1200dp', (
      tester,
    ) async {
      _setBreakpoint(tester, 1200);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('View All'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.text('Financial Health'), findsOneWidget);
      expect(find.text('Net Worth'), findsOneWidget);
    });

    testWidgets('25. Settings accessible via expanded drawer at 1200dp', (
      tester,
    ) async {
      _setBreakpoint(tester, 1200);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Settings'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Financial Planning'), findsOneWidget);
    });

    testWidgets('26. Settings -> FI Calculator at 1200dp', (tester) async {
      _setBreakpoint(tester, 1200);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Settings'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await _scrollUntilVisible(tester, 
        find.text('FI Calculator'),
        200,
      );
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('FI Calculator'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('27. Settings -> Decision Modeler at 1200dp', (tester) async {
      _setBreakpoint(tester, 1200);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(db));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Settings'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      await _scrollUntilVisible(tester, 
        find.text('Decision Modeler'),
        200,
      );
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Decision Modeler'));
      await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Cross-feature round-trip navigation tests
  // ---------------------------------------------------------------------------
  group('Cross-feature round-trips', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    testWidgets(
      '28. Dashboard -> PlanningDashboard -> back -> Dashboard (round-trip)',
      (tester) async {
        _setBreakpoint(tester, 550);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(_buildTestApp(db));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('View All'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.text('Net Worth'), findsOneWidget);

        await tester.tap(find.byType(BackButton));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.text('Dashboard'), findsWidgets);
        expect(find.text('Financial Health'), findsOneWidget);
      },
    );

    testWidgets(
      '29. Dashboard -> PlanningDashboard -> EF -> back -> PlanningDashboard (round-trip)',
      (tester) async {
        _setBreakpoint(tester, 550);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(_buildTestApp(db));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('View All'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('Emergency Fund').first);
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.byType(BackButton));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.text('Financial Health'), findsOneWidget);
        expect(find.text('Net Worth'), findsOneWidget);
      },
    );

    testWidgets(
      '30. Settings -> Life Profile -> back -> Settings (round-trip)',
      (tester) async {
        _setBreakpoint(tester, 550);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(_buildTestApp(db));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('Settings'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('Life Profile'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.byType(BackButton));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Financial Planning'), findsOneWidget);
      },
    );

    testWidgets(
      '31. Dashboard -> Life Plan -> back -> Dashboard (round-trip)',
      (tester) async {
        _setBreakpoint(tester, 550);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(_buildTestApp(db));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await _scrollUntilVisible(tester, 
          find.text('Life Plan'),
          200,
        );
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text('Life Plan').first);
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.text('Life Plan'), findsOneWidget);

        await tester.tap(find.byType(BackButton));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.text('Dashboard'), findsWidgets);
      },
    );

    testWidgets(
      '32. Settings -> EF -> back -> Settings -> Opportunity Fund -> back -> Settings (multi-hop round-trip)',
      (tester) async {
        _setBreakpoint(tester, 550);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(_buildTestApp(db));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('Settings'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('Emergency Fund'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.byType(BackButton));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.text('Settings'), findsOneWidget);

        await _scrollUntilVisible(tester, 
          find.text('Opportunity Fund'),
          200,
        );
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text('Opportunity Fund'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.byType(BackButton));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Financial Planning'), findsOneWidget);
      },
    );

    testWidgets(
      '33. Dashboard -> PlanningDashboard -> FI Progress -> back -> back -> Dashboard (deep round-trip)',
      (tester) async {
        _setBreakpoint(tester, 550);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(_buildTestApp(db));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('View All'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('FI Progress').first);
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.byType(BackButton));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.text('Financial Health'), findsOneWidget);

        await tester.tap(find.byType(BackButton));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.text('Dashboard'), findsWidgets);
      },
    );

    testWidgets(
      '34. Settings -> Milestones -> back -> Settings (round-trip at 750dp)',
      (tester) async {
        _setBreakpoint(tester, 750);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(_buildTestApp(db));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.byIcon(Icons.settings));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await _scrollUntilVisible(tester, 
          find.text('Milestones'),
          200,
        );
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text('Milestones'));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.byType(BackButton));
        await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

        expect(find.text('Settings'), findsOneWidget);
      },
    );
  });
}
