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

  group('Transaction Search + Filters', () {
    testWidgets('filter chips show All, Income, Expense, Transfer', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 50000000);
      final now = DateTime.now();
      await seedTransactionOnly(db, id: 'tx1', amount: 5000000, date: now, kind: 'salary', accountId: 'a1');
      await seedTransactionOnly(db, id: 'tx2', amount: 2000000, date: now, kind: 'expense', accountId: 'a1');

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Transactions');

      // Filter chips should be visible
      expect(find.widgetWithText(FilterChip, 'All'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Income'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Expense'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Transfer'), findsOneWidget);
    });

    testWidgets('tapping Expense filter hides income transactions', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 50000000);
      final now = DateTime.now();
      await seedTransactionOnly(db,
        id: 'tx1', amount: 10000000, date: now, kind: 'salary',
        accountId: 'a1', description: 'March Salary',
      );
      await seedTransactionOnly(db,
        id: 'tx2', amount: 3000000, date: now, kind: 'expense',
        accountId: 'a1', description: 'Grocery Shopping',
      );
      await seedTransactionOnly(db,
        id: 'tx3', amount: 1500000, date: now, kind: 'expense',
        accountId: 'a1', description: 'Electricity Bill',
      );

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Transactions');

      // Initially all visible
      expect(find.text('March Salary'), findsOneWidget);
      expect(find.text('Grocery Shopping'), findsOneWidget);
      expect(find.text('Electricity Bill'), findsOneWidget);

      // Tap "Expense" filter
      await tester.tap(find.widgetWithText(FilterChip, 'Expense'));
      await settle(tester);

      // Only expenses should be visible
      expect(find.text('Grocery Shopping'), findsOneWidget);
      expect(find.text('Electricity Bill'), findsOneWidget);
      // Salary should be hidden
      expect(find.text('March Salary'), findsNothing);

      // Tap "All" to restore
      await tester.tap(find.widgetWithText(FilterChip, 'All'));
      await settle(tester);

      expect(find.text('March Salary'), findsOneWidget);
      expect(find.text('Grocery Shopping'), findsOneWidget);
    });

    testWidgets('search filters transactions by description', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 50000000);
      final now = DateTime.now();
      await seedTransactionOnly(db,
        id: 'tx1', amount: 5000000, date: now, kind: 'expense',
        accountId: 'a1', description: 'Zomato Dinner',
      );
      await seedTransactionOnly(db,
        id: 'tx2', amount: 2000000, date: now, kind: 'expense',
        accountId: 'a1', description: 'Amazon Purchase',
      );
      await seedTransactionOnly(db,
        id: 'tx3', amount: 8000000, date: now, kind: 'salary',
        accountId: 'a1', description: 'Company Salary',
      );

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Transactions');

      // All 3 transactions visible
      expect(find.text('Zomato Dinner'), findsOneWidget);
      expect(find.text('Amazon Purchase'), findsOneWidget);
      expect(find.text('Company Salary'), findsOneWidget);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await settle(tester);

      // Type search query
      await tester.enterText(find.byType(TextField), 'Amazon');
      await settle(tester);

      // Only matching transaction visible
      expect(find.text('Amazon Purchase'), findsOneWidget);
      expect(find.text('Zomato Dinner'), findsNothing);
      expect(find.text('Company Salary'), findsNothing);
    });
  });
}
