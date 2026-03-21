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

  group('Form Validation', () {
    testWidgets('account form rejects empty name', (tester) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Accounts');
      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);

      // Leave name blank, fill only balance
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Opening Balance'),
        '10000',
      );

      // Tap Save — should show validation error
      await tester.tap(find.text('Save'));
      await settle(tester);

      expect(find.text('Name is required'), findsOneWidget);
      // Should still be on form (not navigated back)
      expect(find.text('New Account'), findsOneWidget);
    });

    testWidgets('transaction form rejects empty amount', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 5000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Transactions');
      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);

      // Leave amount blank, just tap Save
      await tester.tap(find.text('Save'));
      await settle(tester);

      expect(find.text('Amount is required'), findsOneWidget);
      // Should still be on form
      expect(find.text('New Transaction'), findsOneWidget);
    });

    testWidgets('transaction form rejects zero amount', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 5000000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Transactions');
      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);

      // Enter zero
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '0');
      await tester.tap(find.text('Save'));
      await settle(tester);

      expect(find.text('Enter a valid amount'), findsOneWidget);
    });
  });
}
