import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/planning/screens/allocation_screen.dart';
import 'package:vael/features/planning/screens/cash_flow_health_screen.dart';
import 'package:vael/features/planning/screens/emergency_fund_screen.dart';
import 'package:vael/features/planning/screens/fi_calculator_screen.dart';
import 'package:vael/features/planning/screens/savings_allocation_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Wraps a screen widget in ProviderScope + MaterialApp with light theme.
  Widget harness(Widget child) {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: child,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cash Flow Health
  // ---------------------------------------------------------------------------
  group('Cash Flow Health', () {
    testWidgets('renders cash flow health screen', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db,
          id: 'acc-1', name: 'Salary Account', type: 'savings', balance: 0);
      await seedTransactionOnly(db,
          id: 'tx-sal',
          amount: 7500000,
          date: DateTime(2026, 3, 5),
          kind: 'salary',
          accountId: 'acc-1',
          description: 'March Salary');
      await seedTransactionOnly(db,
          id: 'tx-exp',
          amount: 250000,
          date: DateTime(2026, 3, 10),
          kind: 'expense',
          accountId: 'acc-1',
          description: 'Groceries');

      await tester.pumpWidget(harness(
        const CashFlowHealthScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      ));
      await settle(tester, const Duration(seconds: 2));

      expect(find.text('Cash Flow Health'), findsOneWidget);
    });

    testWidgets('shows empty state with no data', (tester) async {
      await seedTestFamily(db);

      await tester.pumpWidget(harness(
        const CashFlowHealthScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      ));
      await settle(tester, const Duration(seconds: 2));

      expect(find.text('No cash flow data yet'), findsOneWidget);
    });

    testWidgets('shows income and expense sections', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db,
          id: 'acc-1', name: 'Salary Account', type: 'savings', balance: 0);
      await seedTransactionOnly(db,
          id: 'tx-sal',
          amount: 7500000,
          date: DateTime(2026, 3, 5),
          kind: 'salary',
          accountId: 'acc-1',
          description: 'March Salary');
      await seedTransactionOnly(db,
          id: 'tx-exp',
          amount: 250000,
          date: DateTime(2026, 3, 10),
          kind: 'expense',
          accountId: 'acc-1',
          description: 'Groceries');

      await tester.pumpWidget(harness(
        const CashFlowHealthScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      ));
      await settle(tester, const Duration(seconds: 2));

      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Savings Allocation
  // ---------------------------------------------------------------------------
  group('Savings Allocation', () {
    testWidgets('renders savings allocation screen', (tester) async {
      await seedTestFamily(db);

      await tester.pumpWidget(harness(
        const SavingsAllocationScreen(familyId: kTestFamilyId),
      ));
      await settle(tester, const Duration(seconds: 2));

      expect(find.text('Savings Allocation'), findsOneWidget);
    });

    testWidgets('shows empty state with no rules', (tester) async {
      await seedTestFamily(db);

      await tester.pumpWidget(harness(
        const SavingsAllocationScreen(familyId: kTestFamilyId),
      ));
      await settle(tester, const Duration(seconds: 2));

      expect(find.text('No allocation rules yet'), findsOneWidget);
    });

    testWidgets('shows allocation rules when seeded', (tester) async {
      await seedTestFamily(db);
      await db.into(db.savingsAllocationRules).insert(
            SavingsAllocationRulesCompanion.insert(
              id: 'sar-1',
              familyId: kTestFamilyId,
              priority: 1,
              targetType: 'emergencyFund',
              allocationType: 'percentage',
              percentageBp: const Value(3000), // 30%
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(harness(
        const SavingsAllocationScreen(familyId: kTestFamilyId),
      ));
      await settle(tester, const Duration(seconds: 2));

      expect(find.text('Emergency Fund'), findsOneWidget);
      expect(find.textContaining('30.0%'), findsOneWidget);
    });

    testWidgets('shows Add Rule button', (tester) async {
      await seedTestFamily(db);

      await tester.pumpWidget(harness(
        const SavingsAllocationScreen(familyId: kTestFamilyId),
      ));
      await settle(tester, const Duration(seconds: 2));

      // The "Add Rule" text appears in the header button and also in the
      // empty-state CTA — at least one must be present.
      expect(find.text('Add Rule'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Planning Empty States
  // ---------------------------------------------------------------------------
  group('Planning Empty States', () {
    testWidgets('FI calculator shows banner when no profile', (tester) async {
      await seedTestFamily(db);

      await tester.pumpWidget(harness(
        const FiCalculatorScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      ));
      await settle(tester, const Duration(seconds: 2));

      expect(
        find.text('Set up your life profile for personalized results'),
        findsOneWidget,
      );
      expect(find.text('Set Up'), findsOneWidget);
    });

    testWidgets('allocation screen shows empty state without investments',
        (tester) async {
      await seedTestFamily(db);

      await tester.pumpWidget(harness(
        const AllocationScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      ));
      await settle(tester, const Duration(seconds: 2));

      expect(find.text('No investments yet'), findsOneWidget);
    });

    testWidgets('emergency fund shows setup prompt without EF accounts',
        (tester) async {
      await seedTestFamily(db);

      await tester.pumpWidget(harness(
        const EmergencyFundScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      ));
      await settle(tester, const Duration(seconds: 2));

      // The EF screen shows "No accounts linked yet" when no accounts
      // are designated as emergency-fund accounts.
      expect(find.text('No accounts linked yet'), findsOneWidget);
      expect(find.text('Link Accounts'), findsOneWidget);
    });
  });
}
