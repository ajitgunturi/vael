import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';

import 'simulator_test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  /// Seeds a savings account for transaction tests.
  Future<void> seedAccount() async {
    await seedTestFamily(db);
    await db.into(db.accounts).insert(
      const AccountsCompanion(
        id: Value('acc_1'),
        name: Value('HDFC Savings'),
        type: Value('savings'),
        balance: Value(10000000), // ₹1,00,000
        visibility: Value('shared'),
        familyId: Value(kTestFamilyId),
        userId: Value(kTestUserId),
      ),
    );
  }

  group('Transaction Flow', () {
    testWidgets('should show empty transaction state and FAB', (
      tester,
    ) async {
      await seedAccount();
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Transactions'));
      await tester.pumpAndSettle();

      expect(find.text('No transactions yet'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should open transaction form via FAB', (tester) async {
      await seedAccount();
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Transactions'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('New Transaction'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Transaction Type'), findsOneWidget);
    });

    testWidgets('should create expense transaction and see it in list', (
      tester,
    ) async {
      await seedAccount();
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      // Navigate to Transactions
      await tester.tap(find.text('Transactions'));
      await tester.pumpAndSettle();

      // Open form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Default kind is 'expense' — leave as is
      // Enter amount
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount'),
        '5000',
      );

      // Enter description
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'Groceries',
      );

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should be back on transaction list with the new transaction
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.textContaining('5,000'), findsOneWidget);
    });

    testWidgets(
      'should update account balance after expense transaction',
      (tester) async {
        await seedAccount();
        await tester.pumpWidget(SimulatorTestApp(db: db));
        await tester.pumpAndSettle();

        // Create an expense transaction
        await tester.tap(find.text('Transactions'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'),
          '20000',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Description'),
          'Rent',
        );
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Navigate to Accounts and check balance
        await tester.tap(find.text('Accounts'));
        await tester.pumpAndSettle();

        // Balance should be ₹1,00,000 - ₹20,000 = ₹80,000
        expect(find.textContaining('80,000'), findsOneWidget);
      },
    );

    testWidgets('should show filter chips on transaction list', (
      tester,
    ) async {
      await seedAccount();

      // Seed a transaction so filter chips appear
      await db.into(db.transactions).insert(
        TransactionsCompanion(
          id: const Value('txn_1'),
          amount: const Value(500000),
          date: Value(DateTime.now()),
          kind: const Value('expense'),
          description: const Value('Test'),
          accountId: const Value('acc_1'),
          familyId: const Value(kTestFamilyId),
        ),
      );

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Transactions'));
      await tester.pumpAndSettle();

      // Filter chips should be visible
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });

    testWidgets('should open empty state Add Transaction button', (
      tester,
    ) async {
      await seedAccount();
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Transactions'));
      await tester.pumpAndSettle();

      // Tap empty state button
      await tester.tap(find.widgetWithText(FilledButton, 'Add Transaction'));
      await tester.pumpAndSettle();

      expect(find.text('New Transaction'), findsOneWidget);
    });
  });
}
