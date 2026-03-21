import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/transaction_providers.dart';
import 'package:vael/features/transactions/screens/transaction_list_screen.dart';
import 'package:vael/shared/theme/color_tokens.dart';

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

  group('TransactionListScreen', () {
    testWidgets('shows transactions with kind labels and dates',
        (tester) async {
      final txns = [
        _fakeTxn(
          id: 'tx1',
          amount: 5000000,
          kind: 'salary',
          date: DateTime(2025, 3, 1),
          description: 'March Salary',
        ),
        _fakeTxn(
          id: 'tx2',
          amount: 200000,
          kind: 'expense',
          date: DateTime(2025, 3, 5),
          description: 'Groceries',
        ),
      ];

      await tester.pumpWidget(buildTestApp(transactions: txns));
      await tester.pumpAndSettle();

      expect(find.text('March Salary'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.textContaining('Salary'), findsWidgets);
      expect(find.textContaining('Expense'), findsWidgets);
    });

    testWidgets('formats amounts in Indian notation', (tester) async {
      final txns = [
        _fakeTxn(
          id: 'tx1',
          amount: 32456700,
          kind: 'salary',
          date: DateTime(2025, 3, 1),
        ),
      ];

      await tester.pumpWidget(buildTestApp(transactions: txns));
      await tester.pumpAndSettle();

      expect(find.textContaining('3,24,567'), findsOneWidget);
    });

    testWidgets('colors income green and expenses red', (tester) async {
      final txns = [
        _fakeTxn(id: 'tx1', amount: 100000, kind: 'salary',
            date: DateTime(2025, 3, 1)),
        _fakeTxn(id: 'tx2', amount: 50000, kind: 'expense',
            date: DateTime(2025, 3, 2)),
      ];

      await tester.pumpWidget(buildTestApp(transactions: txns));
      await tester.pumpAndSettle();

      // Verify color helper
      expect(TransactionListScreen.amountColor('salary'),
          ColorTokens.positive);
      expect(TransactionListScreen.amountColor('expense'),
          ColorTokens.negative);
      expect(TransactionListScreen.amountColor('transfer'),
          ColorTokens.neutral);
    });

    testWidgets('shows empty state when no transactions', (tester) async {
      await tester.pumpWidget(buildTestApp(transactions: []));
      await tester.pumpAndSettle();

      expect(find.text('No transactions yet'), findsOneWidget);
      expect(find.text('Add Transaction'), findsOneWidget);
    });

    testWidgets('FAB is present', (tester) async {
      await tester.pumpWidget(buildTestApp(transactions: []));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows date for each transaction', (tester) async {
      final txns = [
        _fakeTxn(
          id: 'tx1',
          amount: 100000,
          kind: 'expense',
          date: DateTime(2025, 3, 15),
          description: 'Lunch',
        ),
      ];

      await tester.pumpWidget(buildTestApp(transactions: txns));
      await tester.pumpAndSettle();

      expect(find.textContaining('15 Mar 2025'), findsOneWidget);
    });
  });
}
