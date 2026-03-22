import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DateTime now;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime.now();
  });
  tearDown(() => db.close());

  DateTime thisMonth(int day) => DateTime(now.year, now.month, day);

  group('Journey: Budget vs Actuals', () {
    testWidgets('should show budget with correct actuals from expenses', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 50000000);
      await seedCategory(db, id: 'cat_groc', name: 'Groceries', groupName: 'ESSENTIAL');
      await seedBudget(db, id: 'b1', categoryGroup: 'ESSENTIAL', limitAmount: 5000000, year: now.year, month: now.month);

      // Seed expense transactions on ESSENTIAL category
      await seedTransaction(db, id: 't1', amount: 1500000, date: thisMonth(3), kind: 'expense', accountId: 'a1', categoryId: 'cat_groc');
      await seedTransaction(db, id: 't2', amount: 1000000, date: thisMonth(7), kind: 'expense', accountId: 'a1', categoryId: 'cat_groc');

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Budget');

      // Actuals: 1500000 + 1000000 = 2500000 = ₹25,000
      // Limit: 5000000 = ₹50,000
      expect(find.text('Essential'), findsOneWidget);
      expect(find.textContaining('25,000'), findsWidgets);
      expect(find.textContaining('50,000'), findsWidgets);
      expect(find.textContaining('remaining'), findsOneWidget);
    });

    testWidgets('should detect overspent budget', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 50000000);
      await seedCategory(db, id: 'cat_groc', name: 'Groceries', groupName: 'ESSENTIAL');
      await seedBudget(db, id: 'b1', categoryGroup: 'ESSENTIAL', limitAmount: 2000000, year: now.year, month: now.month);

      // Overspend: ₹25,000 against ₹20,000 limit
      await seedTransaction(db, id: 't1', amount: 1500000, date: thisMonth(3), kind: 'expense', accountId: 'a1', categoryId: 'cat_groc');
      await seedTransaction(db, id: 't2', amount: 1000000, date: thisMonth(7), kind: 'expense', accountId: 'a1', categoryId: 'cat_groc');

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Budget');

      expect(find.text('Overspent'), findsOneWidget);
      expect(find.textContaining('25,000'), findsWidgets);
      expect(find.textContaining('20,000'), findsWidgets);
    });

    testWidgets('should exclude private account transactions from actuals', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a_shared', name: 'Shared', type: 'savings', balance: 50000000);
      await seedAccount(db, id: 'a_priv', name: 'Private', type: 'savings', balance: 50000000, visibility: 'hidden');
      await seedCategory(db, id: 'cat_groc', name: 'Groceries', groupName: 'ESSENTIAL');
      await seedBudget(db, id: 'b1', categoryGroup: 'ESSENTIAL', limitAmount: 5000000, year: now.year, month: now.month);

      // Shared expense: ₹10,000
      await seedTransaction(db, id: 't1', amount: 1000000, date: thisMonth(3), kind: 'expense', accountId: 'a_shared', categoryId: 'cat_groc');
      // Private expense: ₹15,000 (should be excluded from budget)
      await seedTransaction(db, id: 't2', amount: 1500000, date: thisMonth(5), kind: 'expense', accountId: 'a_priv', categoryId: 'cat_groc');

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Budget');

      // Actuals should be ₹10,000 only (private excluded)
      expect(find.text('Essential'), findsOneWidget);
      expect(find.textContaining('10,000'), findsWidgets);
      expect(find.textContaining('remaining'), findsOneWidget);
    });

    testWidgets('should exclude transfers from budget actuals', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 50000000);
      await seedAccount(db, id: 'a2', name: 'Current', type: 'current', balance: 10000000);
      await seedCategory(db, id: 'cat_groc', name: 'Groceries', groupName: 'ESSENTIAL');
      await seedBudget(db, id: 'b1', categoryGroup: 'ESSENTIAL', limitAmount: 5000000, year: now.year, month: now.month);

      // Transfer (should not count)
      await seedTransaction(db, id: 't1', amount: 2000000, date: thisMonth(3), kind: 'transfer', accountId: 'a1', toAccountId: 'a2');
      // Expense (should count): ₹10,000
      await seedTransaction(db, id: 't2', amount: 1000000, date: thisMonth(5), kind: 'expense', accountId: 'a1', categoryId: 'cat_groc');

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Budget');

      // Only expense counts: ₹10,000
      expect(find.text('Essential'), findsOneWidget);
      expect(find.textContaining('10,000'), findsWidgets);
    });
  });
}
