import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/account_dao.dart';
import 'package:vael/core/database/daos/transaction_dao.dart';
import 'package:vael/core/providers/account_providers.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/transactions/screens/transaction_form_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> _seedFamily(String familyId) async {
    await db.into(db.families).insert(FamiliesCompanion.insert(
          id: familyId,
          name: 'Test Family',
          createdAt: DateTime(2025),
        ));
    await db.into(db.users).insert(UsersCompanion.insert(
          id: 'user_$familyId',
          email: '$familyId@test.com',
          displayName: 'User',
          role: 'admin',
          familyId: familyId,
        ));
  }

  Future<void> _insertAccount({
    required String id,
    required String familyId,
    required String name,
    int balance = 0,
  }) async {
    await db.into(db.accounts).insert(AccountsCompanion(
          id: Value(id),
          name: Value(name),
          type: const Value('savings'),
          balance: Value(balance),
          visibility: const Value('shared'),
          familyId: Value(familyId),
          userId: Value('user_$familyId'),
        ));
  }

  Widget buildDirectForm({
    required String familyId,
    required String userId,
    required List<Account> accounts,
  }) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        // Override the stream provider to avoid drift timer issues
        accountsProvider(familyId)
            .overrideWith((_) => Stream.value(accounts)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TransactionFormScreen(
                    familyId: familyId,
                    userId: userId,
                  ),
                ),
              ),
              child: const Text('Open Form'),
            ),
          ),
        ),
      ),
    );
  }

  group('TransactionFormScreen', () {
    testWidgets('shows form fields for kind, amount, description, date',
        (tester) async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', name: 'Savings');

      final accounts = await AccountDao(db).getAll('fam_a');

      await tester.pumpWidget(
        buildDirectForm(
          familyId: 'fam_a',
          userId: 'user_fam_a',
          accounts: accounts,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to form
      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      expect(find.text('Transaction Type'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('From Account'), findsOneWidget);
    });

    testWidgets('validates that amount is required', (tester) async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', name: 'Savings');

      final accounts = await AccountDao(db).getAll('fam_a');

      await tester.pumpWidget(
        buildDirectForm(
          familyId: 'fam_a',
          userId: 'user_fam_a',
          accounts: accounts,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Amount is required'), findsOneWidget);
    });

    testWidgets('shows To Account picker when Transfer is selected',
        (tester) async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', name: 'Savings');
      await _insertAccount(id: 'acc_2', familyId: 'fam_a', name: 'Wallet');

      final accounts = await AccountDao(db).getAll('fam_a');

      await tester.pumpWidget(
        buildDirectForm(
          familyId: 'fam_a',
          userId: 'user_fam_a',
          accounts: accounts,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      // Initially no To Account
      expect(find.text('To Account'), findsNothing);

      // Select Transfer kind
      await tester.tap(find.text('Expense').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transfer').last);
      await tester.pumpAndSettle();

      // Now To Account should appear
      expect(find.text('To Account'), findsOneWidget);
    });

    testWidgets('creates transaction and updates account balance',
        (tester) async {
      await _seedFamily('fam_a');
      await _insertAccount(
        id: 'acc_1',
        familyId: 'fam_a',
        name: 'Savings',
        balance: 1000000, // ₹10,000
      );

      final accounts = await AccountDao(db).getAll('fam_a');

      await tester.pumpWidget(
        buildDirectForm(
          familyId: 'fam_a',
          userId: 'user_fam_a',
          accounts: accounts,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      // Enter amount (expense of ₹2,000)
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '2000');

      // Save
      await tester.runAsync(() async {
        await tester.tap(find.text('Save'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Verify transaction created
      final txnDao = TransactionDao(db);
      final txns = await txnDao.getAll('fam_a');
      expect(txns, hasLength(1));
      expect(txns.first.amount, 200000); // 2000 * 100 paise

      // Verify balance updated (expense subtracts)
      final accDao = AccountDao(db);
      final updatedAccounts = await accDao.getAll('fam_a');
      expect(updatedAccounts.first.balance, 800000); // 1000000 - 200000
    });

    testWidgets('kind defaults to expense', (tester) async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', name: 'Savings');

      final accounts = await AccountDao(db).getAll('fam_a');

      await tester.pumpWidget(
        buildDirectForm(
          familyId: 'fam_a',
          userId: 'user_fam_a',
          accounts: accounts,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      expect(find.text('Expense'), findsWidgets);
    });
  });
}
