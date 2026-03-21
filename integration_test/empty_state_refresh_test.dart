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

  group('Empty States + Pull-to-Refresh', () {
    testWidgets('accounts tab shows empty state with CTA button', (tester) async {
      await seedTestFamily(db);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Accounts');

      // Empty state text
      expect(find.text('No accounts yet'), findsOneWidget);
      // CTA button
      expect(find.widgetWithText(FilledButton, 'Add Account'), findsOneWidget);
    });

    testWidgets('transactions tab shows empty state with CTA button', (tester) async {
      await seedTestFamily(db);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Transactions');

      expect(find.text('No transactions yet'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Add Transaction'), findsOneWidget);
    });

    testWidgets('budget tab shows empty state', (tester) async {
      await seedTestFamily(db);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Budget');

      expect(find.text('No budgets set'), findsOneWidget);
      expect(find.text('Set spending limits for category groups'), findsOneWidget);
    });

    testWidgets('empty state CTA on accounts navigates to form', (tester) async {
      await seedTestFamily(db);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      await navigateToTab(tester, 'Accounts');

      // Tap empty state CTA
      await tester.tap(find.widgetWithText(FilledButton, 'Add Account'));
      await settle(tester);

      // Should be on form
      expect(find.text('New Account'), findsOneWidget);
    });
  });
}
