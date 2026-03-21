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

  group('Journey: Net Worth Accuracy', () {
    testWidgets('should compute net worth with mixed assets and liabilities', (tester) async {
      await seedTestFamily(db);
      // Assets: savings 5000000 + current 15000000 + investment 100000000 + wallet 500000 = 120500000
      // Liabilities: CC 3500000 + loan 250000000 = 253500000
      // Net = 120500000 - 253500000 = -133000000 paise = -₹13,30,000
      await seedAccount(db, id: 'sav', name: 'HDFC Savings', type: 'savings', balance: 5000000);
      await seedAccount(db, id: 'cur', name: 'SBI Current', type: 'current', balance: 15000000);
      await seedAccount(db, id: 'cc', name: 'ICICI CC', type: 'creditCard', balance: 3500000);
      await seedAccount(db, id: 'loan', name: 'Home Loan', type: 'loan', balance: 250000000);
      await seedAccount(db, id: 'mf', name: 'Mutual Funds', type: 'investment', balance: 100000000);
      await seedAccount(db, id: 'wal', name: 'Paytm', type: 'wallet', balance: 500000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Net worth should be negative: -₹13,30,000
      expect(find.textContaining('13,30,000'), findsOneWidget);
      expect(find.text('Net Worth'), findsOneWidget);
    });

    testWidgets('should update net worth after salary via UI', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'sav', name: 'HDFC Savings', type: 'savings', balance: 5000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Initial NW: ₹50,000
      expect(find.textContaining('50,000'), findsWidgets);

      // Navigate to Transactions, create salary ₹75,000
      await navigateToTab(tester, 'Transactions');
      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);

      // Change kind to Salary via DropdownButton
      final kindDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(kindDropdown);
      await settle(tester);
      await tester.tap(find.text('Salary').last);
      await settle(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '75000');
      await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'Monthly salary');
      await tester.tap(find.text('Save'));
      await settle(tester);

      // Go to Dashboard — NW should be ₹1,25,000
      await navigateToTab(tester, 'Dashboard');
      expect(find.textContaining('1,25,000'), findsWidgets);
      // Income tile should show ₹75,000
      expect(find.textContaining('75,000'), findsWidgets);
    });

    testWidgets('should update net worth after expense via UI', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'sav', name: 'HDFC Savings', type: 'savings', balance: 10000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Create expense ₹30,000
      await navigateToTab(tester, 'Transactions');
      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '30000');
      await tester.tap(find.text('Save'));
      await settle(tester);

      // Verify Accounts shows ₹70,000
      await navigateToTab(tester, 'Accounts');
      expect(find.textContaining('70,000'), findsOneWidget);

      // Verify Dashboard NW matches
      await navigateToTab(tester, 'Dashboard');
      expect(find.textContaining('70,000'), findsWidgets);
    });

    testWidgets('should exclude private accounts from family net worth', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'shared', name: 'Shared Savings', type: 'savings', balance: 10000000);
      await seedAccount(db, id: 'priv', name: 'Private FD', type: 'savings', balance: 5000000, visibility: 'private_');

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Family scope: only shared ₹1,00,000
      expect(find.textContaining('1,00,000'), findsWidgets);
    });

    testWidgets('should show negative net worth with only liabilities', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'cc', name: 'Credit Card', type: 'creditCard', balance: 5000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // NW = -₹50,000
      expect(find.textContaining('50,000'), findsWidgets);
    });
  });
}
