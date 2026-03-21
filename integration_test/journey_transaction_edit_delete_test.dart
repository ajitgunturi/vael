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

  group('Journey: Transaction Edit + Delete', () {
    testWidgets('expense creation reduces account balance and updates dashboard', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 10000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Verify initial NW ₹1,00,000
      expect(find.textContaining('1,00,000'), findsWidgets);

      // Create expense ₹25,000
      await navigateToTab(tester, 'Transactions');
      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);

      // Default kind is 'expense'
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '25000');
      await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'Groceries');
      await tester.tap(find.text('Save'));
      await settle(tester);

      // Verify account balance is now ₹75,000
      await navigateToTab(tester, 'Accounts');
      expect(find.textContaining('75,000'), findsOneWidget);

      // Verify dashboard NW updated
      await navigateToTab(tester, 'Dashboard');
      expect(find.textContaining('75,000'), findsWidgets);
    });

    testWidgets('transfer moves money between accounts without changing net worth', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'HDFC Savings', type: 'savings', balance: 10000000);
      await seedAccount(db, id: 'a2', name: 'SBI Current', type: 'current', balance: 5000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Initial NW = ₹1,00,000 + ₹50,000 = ₹1,50,000
      expect(find.textContaining('1,50,000'), findsWidgets);

      // Create transfer ₹20,000 from HDFC to SBI
      await navigateToTab(tester, 'Transactions');
      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);

      // Change kind to Transfer
      final kindDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(kindDropdown);
      await settle(tester);
      await tester.tap(find.text('Transfer').last);
      await settle(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '20000');

      // Select "To Account" (SBI Current)
      final toAccountDropdown = find.byType(DropdownButtonFormField<String>).at(1);
      await tester.tap(toAccountDropdown);
      await settle(tester);
      await tester.tap(find.text('SBI Current').last);
      await settle(tester);

      await tester.tap(find.text('Save'));
      await settle(tester);

      // NW should remain ₹1,50,000 (transfer is net-zero)
      await navigateToTab(tester, 'Dashboard');
      expect(find.textContaining('1,50,000'), findsWidgets);

      // But account balances should shift
      await navigateToTab(tester, 'Accounts');
      // HDFC: ₹1,00,000 - ₹20,000 = ₹80,000
      expect(find.textContaining('80,000'), findsOneWidget);
      // SBI: ₹50,000 + ₹20,000 = ₹70,000
      expect(find.textContaining('70,000'), findsOneWidget);
    });

    testWidgets('multiple transactions cascade correctly to dashboard', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Salary Account', type: 'savings', balance: 0);

      // Seed salary + expense via DB (with balance cascade)
      final now = DateTime.now();
      await seedTransaction(db,
        id: 'tx1', amount: 10000000, date: now,
        kind: 'salary', accountId: 'a1', description: 'March Salary',
      );
      await seedTransaction(db,
        id: 'tx2', amount: 3000000, date: now,
        kind: 'expense', accountId: 'a1', description: 'Rent',
      );
      await seedTransaction(db,
        id: 'tx3', amount: 500000, date: now,
        kind: 'expense', accountId: 'a1', description: 'Electricity',
      );

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Account balance: 0 + 1,00,000 - 30,000 - 5,000 = ₹65,000
      await navigateToTab(tester, 'Accounts');
      expect(find.textContaining('65,000'), findsOneWidget);

      // Dashboard NW should match
      await navigateToTab(tester, 'Dashboard');
      expect(find.textContaining('65,000'), findsWidgets);

      // Monthly summary: income ₹1,00,000, expenses ₹35,000
      expect(find.textContaining('1,00,000'), findsWidgets);
      expect(find.textContaining('35,000'), findsWidgets);
    });
  });
}
