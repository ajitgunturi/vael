import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Helper: navigate to Transactions, open form, select kind, enter amount, save.
  Future<void> createTransaction(
    WidgetTester tester, {
    required String amount,
    String? kind,
    String? description,
  }) async {
    await navigateToTab(tester, 'Transactions');
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);

    if (kind != null) {
      final kindDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(kindDropdown);
      await settle(tester);
      await tester.tap(find.text(kind).last);
      await settle(tester);
    }

    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), amount);
    if (description != null) {
      await tester.enterText(find.widgetWithText(TextFormField, 'Description'), description);
    }
    await tester.tap(find.text('Save'));
    await settle(tester);
  }

  group('Journey: Cross-Feature Consistency', () {
    testWidgets('full monthly cycle: salary → expense → verify all screens', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'HDFC Savings', type: 'savings', balance: 10000000);
      await seedAccount(db, id: 'a2', name: 'SBI Current', type: 'current', balance: 5000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Initial NW: ₹1,50,000
      expect(find.textContaining('1,50,000'), findsWidgets);

      // Step 1: Salary ₹1,50,000 into default account (HDFC Savings)
      await createTransaction(tester, kind: 'Salary', amount: '150000', description: 'March pay');

      // Step 2: Expense ₹35,000 from default account
      await createTransaction(tester, amount: '35000', description: 'Rent');

      // Verify Accounts
      await navigateToTab(tester, 'Accounts');
      // HDFC: 10000000 + 15000000 - 3500000 = 21500000 = ₹2,15,000
      expect(find.textContaining('2,15,000'), findsOneWidget);
      // SBI: unchanged ₹50,000
      expect(find.textContaining('50,000'), findsOneWidget);

      // Verify Dashboard
      await navigateToTab(tester, 'Dashboard');
      // NW: 21500000 + 5000000 = 26500000 = ₹2,65,000
      expect(find.textContaining('2,65,000'), findsWidgets);
      // Income: ₹1,50,000
      expect(find.textContaining('1,50,000'), findsWidgets);
      // Expenses: ₹35,000
      expect(find.textContaining('35,000'), findsWidgets);
    });

    testWidgets('dashboard and account list show consistent data', (tester) async {
      await seedTestFamily(db);
      // Mixed portfolio
      await seedAccount(db, id: 'sav', name: 'Savings', type: 'savings', balance: 25000000);
      await seedAccount(db, id: 'inv', name: 'MF', type: 'investment', balance: 50000000);
      await seedAccount(db, id: 'cc', name: 'CC', type: 'creditCard', balance: 7500000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // NW = 25000000 + 50000000 - 7500000 = 67500000 = ₹6,75,000
      expect(find.textContaining('6,75,000'), findsWidgets);

      // Verify accounts show individual balances
      await navigateToTab(tester, 'Accounts');
      expect(find.textContaining('2,50,000'), findsOneWidget); // Savings
      expect(find.textContaining('5,00,000'), findsOneWidget); // MF
      expect(find.textContaining('75,000'), findsWidgets); // CC

      // Back to dashboard — NW still consistent
      await navigateToTab(tester, 'Dashboard');
      expect(find.textContaining('6,75,000'), findsWidgets);
    });

    testWidgets('multiple transactions reflect in transaction list count', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 50000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Create 3 transactions
      await createTransaction(tester, kind: 'Salary', amount: '100000', description: 'Pay');
      await createTransaction(tester, amount: '20000', description: 'Groceries');
      await createTransaction(tester, amount: '10000', description: 'Utilities');

      // Transaction list should show all 3
      await navigateToTab(tester, 'Transactions');
      expect(find.text('Pay'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Utilities'), findsOneWidget);

      // Verify filter chips are visible (list is non-empty)
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
    });
  });
}
