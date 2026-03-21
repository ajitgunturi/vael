import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';

import 'simulator_test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Account CRUD Flow', () {
    testWidgets('should create account via FAB and see it in the list', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      // Navigate to Accounts tab
      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();

      // Tap FAB to open account form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify we're on the New Account screen
      expect(find.text('New Account'), findsOneWidget);

      // Fill in account name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Account Name'),
        'HDFC Savings',
      );

      // Fill in opening balance
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Opening Balance'),
        '50000',
      );

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should be back on account list with the new account
      expect(find.text('HDFC Savings'), findsOneWidget);
      expect(find.textContaining('50,000'), findsOneWidget);
    });

    testWidgets(
      'should show account in Banking section when type is savings',
      (tester) async {
        await seedTestFamily(db);
        await tester.pumpWidget(SimulatorTestApp(db: db));
        await tester.pumpAndSettle();

        // Navigate to Accounts and create one
        await tester.tap(find.text('Accounts'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Account Name'),
          'SBI Savings',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Opening Balance'),
          '100000',
        );
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Default type is 'savings' which falls under Banking section
        expect(find.text('Banking'), findsOneWidget);
        expect(find.text('SBI Savings'), findsOneWidget);
      },
    );

    testWidgets(
      'should reflect new account balance in dashboard net worth',
      (tester) async {
        await seedTestFamily(db);

        // Pre-seed an account so dashboard has data
        await db.into(db.accounts).insert(
          const AccountsCompanion(
            id: Value('acc_1'),
            name: Value('Savings Account'),
            type: Value('savings'),
            balance: Value(10000000), // ₹1,00,000
            visibility: Value('shared'),
            familyId: Value(kTestFamilyId),
            userId: Value(kTestUserId),
          ),
        );

        await tester.pumpWidget(SimulatorTestApp(db: db));
        await tester.pumpAndSettle();

        // Dashboard should show ₹1,00,000 net worth
        expect(find.textContaining('1,00,000'), findsWidgets);
      },
    );

    testWidgets('should show empty state button that opens form', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();

      // Tap the "Add Account" button in empty state (not FAB)
      await tester.tap(find.widgetWithText(FilledButton, 'Add Account'));
      await tester.pumpAndSettle();

      expect(find.text('New Account'), findsOneWidget);
    });

    testWidgets('should create multiple accounts across sections', (
      tester,
    ) async {
      await seedTestFamily(db);

      // Seed different account types directly
      await db.into(db.accounts).insert(
        const AccountsCompanion(
          id: Value('acc_sav'),
          name: Value('HDFC Savings'),
          type: Value('savings'),
          balance: Value(5000000),
          visibility: Value('shared'),
          familyId: Value(kTestFamilyId),
          userId: Value(kTestUserId),
        ),
      );
      await db.into(db.accounts).insert(
        const AccountsCompanion(
          id: Value('acc_cc'),
          name: Value('ICICI Credit Card'),
          type: Value('creditCard'),
          balance: Value(2500000),
          visibility: Value('shared'),
          familyId: Value(kTestFamilyId),
          userId: Value(kTestUserId),
        ),
      );

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();

      // Should show both sections
      expect(find.text('Banking'), findsOneWidget);
      expect(find.text('Credit Cards'), findsOneWidget);
      expect(find.text('HDFC Savings'), findsOneWidget);
      expect(find.text('ICICI Credit Card'), findsOneWidget);
    });
  });
}
