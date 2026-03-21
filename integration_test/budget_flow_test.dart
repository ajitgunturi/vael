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

  group('Budget Flow', () {
    testWidgets('should show budget empty state with icon and text', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();

      expect(find.text('No budgets set'), findsOneWidget);
      expect(
        find.text('Set spending limits for category groups'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.pie_chart_outline), findsOneWidget);
    });

    testWidgets('should show correct month/year in budget app bar', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();

      // App bar should display current month and year
      final now = DateTime.now();
      final monthNames = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final expected = 'Budget — ${monthNames[now.month]} ${now.year}';
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('should have FAB to create new budget', (tester) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should open budget form when FAB tapped', (tester) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Budget form should appear (pushed via Navigator)
      expect(find.text('New Budget'), findsOneWidget);
    });
  });
}
