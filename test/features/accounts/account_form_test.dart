import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/account_dao.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/accounts/screens/account_form_screen.dart';

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

  Widget buildTestApp({
    required String familyId,
    required String userId,
    Account? existingAccount,
  }) {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AccountFormScreen(
                    familyId: familyId,
                    userId: userId,
                    existingAccount: existingAccount,
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

  /// Simpler harness that directly shows the form (no navigation).
  Widget buildDirectForm({
    required String familyId,
    required String userId,
    Account? existingAccount,
  }) {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: AccountFormScreen(
          familyId: familyId,
          userId: userId,
          existingAccount: existingAccount,
        ),
      ),
    );
  }

  group('AccountFormScreen — create mode', () {
    testWidgets('shows form fields for name, type, balance, visibility',
        (tester) async {
      await _seedFamily('fam_a');
      await tester.pumpWidget(
          buildDirectForm(familyId: 'fam_a', userId: 'user_fam_a'));
      await tester.pumpAndSettle();

      expect(find.text('Account Name'), findsOneWidget);
      expect(find.text('Account Type'), findsOneWidget);
      expect(find.text('Opening Balance'), findsOneWidget);
      expect(find.text('Visibility'), findsOneWidget);
    });

    testWidgets('validates that name is required', (tester) async {
      await _seedFamily('fam_a');
      await tester.pumpWidget(
          buildDirectForm(familyId: 'fam_a', userId: 'user_fam_a'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('creates account with valid form data', (tester) async {
      await _seedFamily('fam_a');

      // Use navigation harness so Navigator.pop works
      await tester.pumpWidget(
          buildTestApp(familyId: 'fam_a', userId: 'user_fam_a'));
      await tester.pumpAndSettle();

      // Navigate to form
      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Account Name'), 'New Savings');

      // Enter balance
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Opening Balance'), '5000');

      // Tap save — use runAsync for DB write + Navigator.pop
      await tester.runAsync(() async {
        await tester.tap(find.text('Save'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify account was created in DB
      final dao = AccountDao(db);
      final accounts = await dao.getAll('fam_a');
      expect(accounts, hasLength(1));
      expect(accounts.first.name, 'New Savings');
      expect(accounts.first.balance, 500000); // 5000 * 100 paise
    });

    testWidgets('account type defaults to savings', (tester) async {
      await _seedFamily('fam_a');
      await tester.pumpWidget(
          buildDirectForm(familyId: 'fam_a', userId: 'user_fam_a'));
      await tester.pumpAndSettle();

      expect(find.text('Savings'), findsWidgets);
    });

    testWidgets('allows selecting account type from dropdown', (tester) async {
      await _seedFamily('fam_a');
      await tester.pumpWidget(
          buildDirectForm(familyId: 'fam_a', userId: 'user_fam_a'));
      await tester.pumpAndSettle();

      // Tap the current dropdown value to open it
      await tester.tap(find.text('Savings').first);
      await tester.pumpAndSettle();

      expect(find.text('Credit Card'), findsOneWidget);
      expect(find.text('Investment'), findsOneWidget);
      expect(find.text('Loan'), findsOneWidget);
    });

    testWidgets('visibility defaults to shared', (tester) async {
      await _seedFamily('fam_a');
      await tester.pumpWidget(
          buildDirectForm(familyId: 'fam_a', userId: 'user_fam_a'));
      await tester.pumpAndSettle();

      expect(find.text('Shared'), findsWidgets);
    });
  });

  group('AccountFormScreen — edit mode', () {
    testWidgets('pre-fills form with existing account data', (tester) async {
      await _seedFamily('fam_a');
      await db.into(db.accounts).insert(AccountsCompanion(
            id: const Value('existing'),
            name: const Value('HDFC Savings'),
            type: const Value('savings'),
            balance: const Value(324567),
            visibility: const Value('shared'),
            familyId: const Value('fam_a'),
            userId: const Value('user_fam_a'),
          ));

      final account = await (db.select(db.accounts)
            ..where((a) => a.id.equals('existing')))
          .getSingle();

      await tester.pumpWidget(buildDirectForm(
        familyId: 'fam_a',
        userId: 'user_fam_a',
        existingAccount: account,
      ));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextFormField, 'HDFC Savings'),
        findsOneWidget,
      );
    });
  });
}
