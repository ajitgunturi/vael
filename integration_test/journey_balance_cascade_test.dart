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
      // Tap the DropdownButton widget itself to open the popup
      final kindDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(kindDropdown);
      await settle(tester);
      // Select the desired kind from the overlay menu
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

  group('Journey: Balance Cascade', () {
    testWidgets('income credits account balance', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 1000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await createTransaction(tester, kind: 'Income', amount: '25000', description: 'Freelance');

      await navigateToTab(tester, 'Accounts');
      // 1000000 + 2500000 = 3500000 paise = ₹35,000
      expect(find.textContaining('35,000'), findsOneWidget);
    });

    testWidgets('salary credits account balance', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Current', type: 'current', balance: 20000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await createTransaction(tester, kind: 'Salary', amount: '150000', description: 'March salary');

      await navigateToTab(tester, 'Accounts');
      // 20000000 + 15000000 = 35000000 paise = ₹3,50,000
      expect(find.textContaining('3,50,000'), findsOneWidget);
    });

    testWidgets('expense debits account balance', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 10000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await createTransaction(tester, amount: '15000', description: 'Groceries');

      await navigateToTab(tester, 'Accounts');
      // 10000000 - 1500000 = 8500000 paise = ₹85,000
      expect(find.textContaining('85,000'), findsOneWidget);
    });

    testWidgets('EMI payment debits account balance', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Current', type: 'current', balance: 5000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await createTransaction(tester, kind: 'EMI Payment', amount: '12500', description: 'Home loan EMI');

      await navigateToTab(tester, 'Accounts');
      // 5000000 - 1250000 = 3750000 paise = ₹37,500
      expect(find.textContaining('37,500'), findsOneWidget);
    });

    testWidgets('transfer debits from and credits to', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'HDFC Savings', type: 'savings', balance: 10000000);
      await seedAccount(db, id: 'a2', name: 'SBI Current', type: 'current', balance: 5000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Create transfer
      await navigateToTab(tester, 'Transactions');
      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);

      // Select Transfer kind via DropdownButton
      final kindDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(kindDropdown);
      await settle(tester);
      await tester.tap(find.text('Transfer').last);
      await settle(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '20000');

      // Select To Account — tap the "To Account" dropdown and pick SBI Current
      final toAccountDropdown = find.byType(DropdownButtonFormField<String>).last;
      await tester.tap(toAccountDropdown);
      await settle(tester);
      await tester.tap(find.text('SBI Current').last);
      await settle(tester);

      await tester.tap(find.text('Save'));
      await settle(tester);

      // Verify balances
      await navigateToTab(tester, 'Accounts');
      // HDFC: 10000000 - 2000000 = 8000000 = ₹80,000
      expect(find.textContaining('80,000'), findsOneWidget);
      // SBI: 5000000 + 2000000 = 7000000 = ₹70,000
      expect(find.textContaining('70,000'), findsOneWidget);

      // Dashboard NW unchanged: ₹1,50,000
      await navigateToTab(tester, 'Dashboard');
      expect(find.textContaining('1,50,000'), findsWidgets);
    });

    testWidgets('chained transactions accumulate correctly', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 20000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Step 1: Salary +₹1,00,000
      await createTransaction(tester, kind: 'Salary', amount: '100000');
      // Step 2: Expense -₹45,000
      await createTransaction(tester, amount: '45000');
      // Step 3: Expense -₹5,000
      await createTransaction(tester, amount: '5000');

      // Balance: 20000000 + 10000000 - 4500000 - 500000 = 25000000 = ₹2,50,000
      await navigateToTab(tester, 'Accounts');
      expect(find.textContaining('2,50,000'), findsOneWidget);

      // Dashboard: NW ₹2,50,000, Income ₹1,00,000, Expenses ₹50,000, Rate 50%
      await navigateToTab(tester, 'Dashboard');
      expect(find.textContaining('2,50,000'), findsWidgets);
      expect(find.textContaining('1,00,000'), findsWidgets);
      expect(find.textContaining('50,000'), findsWidgets);
      expect(find.textContaining('50%'), findsOneWidget);
    });
  });
}
