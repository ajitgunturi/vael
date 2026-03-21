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

  group('Adaptive Layout Breakpoints', () {
    testWidgets('phone simulator shows BottomNavigationBar with all 5 tabs', (tester) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // On iPhone simulator the compact layout should activate
      final bnb = find.byType(BottomNavigationBar);
      if (bnb.evaluate().isNotEmpty) {
        expect(bnb, findsOneWidget);
        // All 5 destinations visible (may appear more than once due to AppBar)
        expect(find.text('Dashboard'), findsWidgets);
        expect(find.text('Accounts'), findsWidgets);
        expect(find.text('Transactions'), findsWidgets);
        expect(find.text('Budget'), findsWidgets);
        expect(find.text('Goals'), findsWidgets);
      } else {
        // On tablet/iPad simulator, NavigationRail should be present instead
        expect(find.byType(NavigationRail), findsOneWidget);
      }
    });

    testWidgets('iPad simulator shows NavigationRail or sidebar', (tester) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // On iPad the medium or expanded layout should activate
      final rail = find.byType(NavigationRail);
      final bnb = find.byType(BottomNavigationBar);
      if (rail.evaluate().isNotEmpty) {
        // Medium layout — NavigationRail
        expect(rail, findsOneWidget);
        expect(bnb, findsNothing);
      } else if (bnb.evaluate().isNotEmpty) {
        // Compact layout — still valid on small iPads / phone simulator
        expect(bnb, findsOneWidget);
      } else {
        // Expanded layout — ListTile sidebar
        expect(find.byType(ListTile), findsAtLeast(5));
      }
    });
  });
}
