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

  /// Current month date helper.
  DateTime thisMonth(int day) => DateTime(now.year, now.month, day);

  group('Journey: Monthly Summary', () {
    testWidgets('should aggregate mixed transaction types correctly', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 50000000);
      await seedAccount(db, id: 'a2', name: 'Current', type: 'current', balance: 10000000);

      // Seed transactions with balance cascade
      // Income: salary 15000000 + income 2500000 = 17500000 (₹1,75,000)
      await seedTransaction(db, id: 't1', amount: 15000000, date: thisMonth(1), kind: 'salary', accountId: 'a1');
      await seedTransaction(db, id: 't2', amount: 2500000, date: thisMonth(5), kind: 'income', accountId: 'a1');
      // Expenses: 3500000 + 1500000 + 1250000 = 6250000 (₹62,500)
      await seedTransaction(db, id: 't3', amount: 3500000, date: thisMonth(3), kind: 'expense', accountId: 'a1');
      await seedTransaction(db, id: 't4', amount: 1500000, date: thisMonth(7), kind: 'expense', accountId: 'a1');
      await seedTransaction(db, id: 't5', amount: 1250000, date: thisMonth(10), kind: 'emiPayment', accountId: 'a1');
      // Transfer (excluded from income/expenses)
      await seedTransaction(db, id: 't6', amount: 2000000, date: thisMonth(15), kind: 'transfer', accountId: 'a1', toAccountId: 'a2');

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Income: ₹1,75,000
      expect(find.textContaining('1,75,000'), findsWidgets);
      // Expenses: ₹62,500
      expect(find.textContaining('62,500'), findsWidgets);
      // Net Savings: +₹1,12,500
      expect(find.textContaining('1,12,500'), findsWidgets);
      // Savings Rate: (11250000/17500000)*100 = 64.28... -> 64%
      expect(find.textContaining('64%'), findsOneWidget);
    });

    testWidgets('should show green savings rate badge when >= 20%', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 50000000);

      await seedTransaction(db, id: 't1', amount: 10000000, date: thisMonth(1), kind: 'salary', accountId: 'a1');
      await seedTransaction(db, id: 't2', amount: 5000000, date: thisMonth(5), kind: 'expense', accountId: 'a1');

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Rate = 50%
      expect(find.textContaining('Savings Rate: 50%'), findsOneWidget);
    });

    testWidgets('should show amber savings rate badge when 10-19%', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 50000000);

      await seedTransaction(db, id: 't1', amount: 10000000, date: thisMonth(1), kind: 'salary', accountId: 'a1');
      await seedTransaction(db, id: 't2', amount: 8500000, date: thisMonth(5), kind: 'expense', accountId: 'a1');

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Rate = 15%
      expect(find.textContaining('Savings Rate: 15%'), findsOneWidget);
    });

    testWidgets('should show red savings rate badge when < 10%', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 50000000);

      await seedTransaction(db, id: 't1', amount: 10000000, date: thisMonth(1), kind: 'salary', accountId: 'a1');
      await seedTransaction(db, id: 't2', amount: 9500000, date: thisMonth(5), kind: 'expense', accountId: 'a1');

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Rate = 5%
      expect(find.textContaining('Savings Rate: 5%'), findsOneWidget);
    });

    testWidgets('should exclude transactions from other months', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 50000000);

      // Current month salary
      await seedTransaction(db, id: 't1', amount: 10000000, date: thisMonth(1), kind: 'salary', accountId: 'a1');
      // Last month salary (should be excluded)
      final lastMonth = DateTime(now.year, now.month - 1, 15);
      await seedTransaction(db, id: 't2', amount: 5000000, date: lastMonth, kind: 'salary', accountId: 'a1');

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // Income should be ₹1,00,000 (only current month)
      expect(find.textContaining('1,00,000'), findsWidgets);
      // Savings rate 100%
      expect(find.textContaining('Savings Rate: 100%'), findsOneWidget);
    });
  });
}
