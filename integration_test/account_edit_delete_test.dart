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

  group('Account Edit + Delete Flow', () {
    testWidgets('should create accounts of different types and see correct sections', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'sav1', name: 'HDFC Savings', type: 'savings', balance: 5000000);
      await seedAccount(db, id: 'cc1', name: 'Amex Card', type: 'creditCard', balance: 2500000);
      await seedAccount(db, id: 'inv1', name: 'PPF', type: 'investment', balance: 20000000);
      await seedAccount(db, id: 'wal1', name: 'Paytm Wallet', type: 'wallet', balance: 100000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Accounts');

      // All sections should render
      expect(find.text('Banking'), findsOneWidget);
      expect(find.text('Credit Cards'), findsOneWidget);
      expect(find.text('Investments'), findsOneWidget);

      // All account names visible
      expect(find.text('HDFC Savings'), findsOneWidget);
      expect(find.text('Amex Card'), findsOneWidget);
      expect(find.text('PPF'), findsOneWidget);
      expect(find.text('Paytm Wallet'), findsOneWidget);
    });

    testWidgets('should show liabilities with correct balance formatting', (tester) async {
      await seedTestFamily(db);
      // Liabilities: CC and loan balances should render
      await seedAccount(db, id: 'cc', name: 'ICICI CC', type: 'creditCard', balance: 3500000);
      await seedAccount(db, id: 'loan', name: 'Home Loan', type: 'loan', balance: 250000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Accounts');

      // Balance text should be present (Indian formatting)
      expect(find.textContaining('35,000'), findsOneWidget);
      expect(find.textContaining('25,00,000'), findsOneWidget);
    });

    testWidgets('should create account via form with Credit Card type', (tester) async {
      await seedTestFamily(db);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Accounts');

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);

      // Fill name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Account Name'),
        'SBI Card',
      );

      // Change type to Credit Card
      final typeDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(typeDropdown);
      await settle(tester);
      await tester.tap(find.text('Credit Card').last);
      await settle(tester);

      // Fill balance
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Opening Balance'),
        '15000',
      );

      // Save
      await tester.tap(find.text('Save'));
      await settle(tester);

      // Verify on list
      expect(find.text('Credit Cards'), findsOneWidget);
      expect(find.text('SBI Card'), findsOneWidget);
    });
  });
}
