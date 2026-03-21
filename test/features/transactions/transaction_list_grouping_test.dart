import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/transaction_providers.dart';
import 'package:vael/features/transactions/screens/transaction_list_screen.dart';

Transaction _fakeTxn({
  required String id,
  required int amount,
  required String kind,
  required DateTime date,
  String? description,
}) {
  return Transaction(
    id: id,
    amount: amount,
    date: date,
    description: description,
    categoryId: null,
    accountId: 'acc_1',
    toAccountId: null,
    kind: kind,
    reconciliationKind: null,
    metadata: null,
    familyId: 'fam_a',
  );
}

void main() {
  Widget buildTestApp({
    required List<Transaction> transactions,
    String familyId = 'fam_a',
  }) {
    return ProviderScope(
      overrides: [
        transactionsProvider(familyId)
            .overrideWith((_) => Stream.value(transactions)),
      ],
      child: MaterialApp(
        home: TransactionListScreen(familyId: familyId, userId: 'user_fam_a'),
      ),
    );
  }

  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  final older = DateTime(today.year, today.month - 1, 10);

  group('Transaction List Grouping', () {
    testWidgets('shows date group headers', (tester) async {
      final txns = [
        _fakeTxn(
          id: 'tx1',
          amount: 100000,
          kind: 'salary',
          date: today,
          description: 'Today Pay',
        ),
        _fakeTxn(
          id: 'tx2',
          amount: 50000,
          kind: 'expense',
          date: yesterday,
          description: 'Yesterday Buy',
        ),
        _fakeTxn(
          id: 'tx3',
          amount: 30000,
          kind: 'expense',
          date: older,
          description: 'Old Purchase',
        ),
      ];

      await tester.pumpWidget(buildTestApp(transactions: txns));
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      // Older date should show as "dd MMM" format
      expect(find.text('Today Pay'), findsOneWidget);
      expect(find.text('Yesterday Buy'), findsOneWidget);
      expect(find.text('Old Purchase'), findsOneWidget);
    });
  });

  group('Transaction Search', () {
    testWidgets('search bar is visible', (tester) async {
      final txns = [
        _fakeTxn(
          id: 'tx1',
          amount: 100000,
          kind: 'salary',
          date: today,
          description: 'March Salary',
        ),
      ];

      await tester.pumpWidget(buildTestApp(transactions: txns));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('typing in search filters transactions', (tester) async {
      final txns = [
        _fakeTxn(
            id: 'tx1',
            amount: 100000,
            kind: 'salary',
            date: today,
            description: 'March Salary'),
        _fakeTxn(
            id: 'tx2',
            amount: 50000,
            kind: 'expense',
            date: today,
            description: 'Groceries'),
      ];

      await tester.pumpWidget(buildTestApp(transactions: txns));
      await tester.pumpAndSettle();

      // Tap search icon to activate search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Salary');
      await tester.pumpAndSettle();

      expect(find.text('March Salary'), findsOneWidget);
      expect(find.text('Groceries'), findsNothing);
    });
  });

  group('Transaction Filter Chips', () {
    testWidgets('shows filter chips for transaction kinds', (tester) async {
      final txns = [
        _fakeTxn(
            id: 'tx1',
            amount: 100000,
            kind: 'salary',
            date: today,
            description: 'Pay'),
        _fakeTxn(
            id: 'tx2',
            amount: 50000,
            kind: 'expense',
            date: today,
            description: 'Food'),
        _fakeTxn(
            id: 'tx3',
            amount: 25000,
            kind: 'transfer',
            date: today,
            description: 'Move Money'),
      ];

      await tester.pumpWidget(buildTestApp(transactions: txns));
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
    });

    testWidgets('tapping filter chip filters by kind', (tester) async {
      final txns = [
        _fakeTxn(
            id: 'tx1',
            amount: 100000,
            kind: 'salary',
            date: today,
            description: 'Pay'),
        _fakeTxn(
            id: 'tx2',
            amount: 50000,
            kind: 'expense',
            date: today,
            description: 'Food'),
      ];

      await tester.pumpWidget(buildTestApp(transactions: txns));
      await tester.pumpAndSettle();

      // Tap "Expense" filter
      await tester.tap(find.text('Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Pay'), findsNothing);
    });
  });
}
