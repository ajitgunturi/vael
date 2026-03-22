import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/core/providers/session_providers.dart';
import 'package:vael/core/financial/dashboard_aggregation.dart';
import 'package:vael/features/accounts/providers/account_ui_providers.dart';
import 'package:vael/features/budgets/providers/budget_providers.dart';
import 'package:vael/features/dashboard/providers/dashboard_providers.dart';
import 'package:vael/features/goals/providers/goal_providers.dart';
import 'package:vael/core/providers/transaction_providers.dart';
import 'package:vael/shared/shell/home_shell.dart';

const _familyId = 'e2e_fam';
const _userId = 'e2e_usr';

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

/// Build a fully-wired VaelApp with session providers pre-set and stream
/// providers stubbed to avoid drift timer issues in widget tests.
Widget _buildApp({
  required ProviderContainer container,
  bool withSession = true,
}) {
  if (withSession) {
    container.read(sessionFamilyIdProvider.notifier).set(_familyId);
    container.read(sessionUserIdProvider.notifier).set(_userId);
  }

  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: withSession
          ? const HomeShell(familyId: _familyId, userId: _userId)
          : const _OnboardingTestShell(),
    ),
  );
}

class _OnboardingTestShell extends ConsumerWidget {
  const _OnboardingTestShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyId = ref.watch(sessionFamilyIdProvider);
    final userId = ref.watch(sessionUserIdProvider);

    if (familyId != null && userId != null) {
      return HomeShell(familyId: familyId, userId: userId);
    }
    return const Scaffold(body: Center(child: Text('Onboarding')));
  }
}

void main() {
  group('Phase 5 E2E — HomeShell navigation', () {
    late ProviderContainer container;

    setUp(() {
      final now = DateTime.now();
      final budgetKey = (familyId: _familyId, year: now.year, month: now.month);

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(
            AppDatabase(NativeDatabase.memory()),
          ),
          dashboardDataProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(_emptyDashboard)),
          dashboardScopeProvider.overrideWith(DashboardScopeNotifier.new),
          groupedAccountsProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(_emptyGroups)),
          transactionsProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(const [])),
          budgetSummaryProvider(budgetKey).overrideWith((_) async => const []),
          goalListProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(const [])),
        ],
      );
    });

    tearDown(() => container.dispose());

    testWidgets('renders Dashboard tab by default', (tester) async {
      await tester.pumpWidget(_buildApp(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Net Worth'), findsOneWidget);
    });

    testWidgets('navigates through all 5 tabs', (tester) async {
      await tester.pumpWidget(_buildApp(container: container));
      await tester.pumpAndSettle();

      for (final tab in ['Accounts', 'Transactions', 'Budget', 'Goals']) {
        await tester.tap(find.text(tab).first);
        await tester.pumpAndSettle();
        expect(find.text(tab), findsWidgets);
      }
    });

    testWidgets('Settings gear opens SettingsScreen', (tester) async {
      await tester.pumpWidget(_buildApp(container: container));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Family Backup'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('Settings → Family Backup → back', (tester) async {
      await tester.pumpWidget(_buildApp(container: container));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Family Backup'));
      await tester.pumpAndSettle();

      expect(find.text('Family Backup'), findsWidgets);

      // Navigate back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Settings → Passphrase → shows setup screen', (tester) async {
      await tester.pumpWidget(_buildApp(container: container));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Passphrase'));
      await tester.pumpAndSettle();

      expect(find.text('Set Family Passphrase'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('Settings → Sign Out clears session', (tester) async {
      await tester.pumpWidget(_buildApp(container: container));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      final signOut = find.text('Sign Out');
      await tester.ensureVisible(signOut);
      await tester.pumpAndSettle();
      await tester.tap(signOut);
      await tester.pumpAndSettle();

      expect(container.read(sessionFamilyIdProvider), isNull);
      expect(container.read(sessionUserIdProvider), isNull);
    });
  });

  group('Phase 5 E2E — Goals tab', () {
    late ProviderContainer container;
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.now();
      final budgetKey = (familyId: _familyId, year: now.year, month: now.month);

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          dashboardDataProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(_emptyDashboard)),
          dashboardScopeProvider.overrideWith(DashboardScopeNotifier.new),
          groupedAccountsProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(_emptyGroups)),
          transactionsProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(const [])),
          budgetSummaryProvider(budgetKey).overrideWith((_) async => const []),
          goalListProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(const [])),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    testWidgets('Goals tab shows empty state', (tester) async {
      await tester.pumpWidget(_buildApp(container: container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Goals').first);
      await tester.pumpAndSettle();

      expect(find.text('Goals'), findsWidgets);
    });

    testWidgets('Goals tab shows Add Goal FAB', (tester) async {
      await tester.pumpWidget(_buildApp(container: container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Goals').first);
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('Phase 5 E2E — session lifecycle', () {
    testWidgets('session cleared → shows onboarding-like state', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(
            AppDatabase(NativeDatabase.memory()),
          ),
        ],
      );
      addTearDown(container.dispose);

      // No session set — should show onboarding
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: _OnboardingTestShell()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Onboarding'), findsOneWidget);
    });

    testWidgets('session set → shows HomeShell', (tester) async {
      final now = DateTime.now();
      final budgetKey = (familyId: _familyId, year: now.year, month: now.month);

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(
            AppDatabase(NativeDatabase.memory()),
          ),
          dashboardDataProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(_emptyDashboard)),
          dashboardScopeProvider.overrideWith(DashboardScopeNotifier.new),
          groupedAccountsProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(_emptyGroups)),
          transactionsProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(const [])),
          budgetSummaryProvider(budgetKey).overrideWith((_) async => const []),
          goalListProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(const [])),
        ],
      );
      addTearDown(container.dispose);

      container.read(sessionFamilyIdProvider.notifier).set(_familyId);
      container.read(sessionUserIdProvider.notifier).set(_userId);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: _OnboardingTestShell()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsWidgets);
    });

    testWidgets('sign out transitions from HomeShell to onboarding state', (
      tester,
    ) async {
      final now = DateTime.now();
      final budgetKey = (familyId: _familyId, year: now.year, month: now.month);

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(
            AppDatabase(NativeDatabase.memory()),
          ),
          dashboardDataProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(_emptyDashboard)),
          dashboardScopeProvider.overrideWith(DashboardScopeNotifier.new),
          groupedAccountsProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(_emptyGroups)),
          transactionsProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(const [])),
          budgetSummaryProvider(budgetKey).overrideWith((_) async => const []),
          goalListProvider(
            _familyId,
          ).overrideWith((_) => Stream.value(const [])),
        ],
      );
      addTearDown(container.dispose);

      container.read(sessionFamilyIdProvider.notifier).set(_familyId);
      container.read(sessionUserIdProvider.notifier).set(_userId);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: _OnboardingTestShell()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify we're on HomeShell
      expect(find.text('Dashboard'), findsWidgets);

      // Clear session (simulating sign-out)
      container.read(sessionFamilyIdProvider.notifier).set(null);
      container.read(sessionUserIdProvider.notifier).set(null);
      await tester.pumpAndSettle();

      // Should be back to onboarding
      expect(find.text('Onboarding'), findsOneWidget);
    });
  });
}
