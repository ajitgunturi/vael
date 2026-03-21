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

  group('Navigation Flow', () {
    testWidgets('should navigate to Accounts tab and show empty state', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      // Tap Accounts in bottom nav
      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();

      expect(find.text('No accounts yet'), findsOneWidget);
      expect(find.text('Add Account'), findsOneWidget);
    });

    testWidgets('should navigate to Transactions tab and show empty state', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Transactions'));
      await tester.pumpAndSettle();

      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets('should navigate to Budget tab and show empty state', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();

      expect(find.text('No budgets set'), findsOneWidget);
      expect(find.text('Set spending limits for category groups'), findsOneWidget);
    });

    testWidgets('should navigate to Goals tab and show placeholder', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Goals'));
      await tester.pumpAndSettle();

      expect(find.textContaining('coming soon'), findsOneWidget);
    });

    testWidgets('should navigate across all tabs and back to Dashboard', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      // Accounts
      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();
      expect(find.text('No accounts yet'), findsOneWidget);

      // Transactions
      await tester.tap(find.text('Transactions'));
      await tester.pumpAndSettle();
      expect(find.text('No transactions yet'), findsOneWidget);

      // Budget
      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();
      expect(find.text('No budgets set'), findsOneWidget);

      // Goals
      await tester.tap(find.text('Goals'));
      await tester.pumpAndSettle();
      expect(find.textContaining('coming soon'), findsOneWidget);

      // Back to Dashboard
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Net Worth'), findsOneWidget);
    });

    testWidgets('should highlight selected navigation destination', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      // Tap Accounts tab
      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();

      // The BottomNavigationBar should have index 1 selected
      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, 1);
    });
  });
}
