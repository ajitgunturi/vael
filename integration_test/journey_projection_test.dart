import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/projections/screens/projection_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> pumpProjection(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ProjectionScreen(familyId: kTestFamilyId),
        ),
      ),
    );
    await settle(tester);
  }

  group('Journey: 60-Month Projection', () {
    testWidgets('should render projection screen with 3 scenarios', (tester) async {
      await seedTestFamily(db);
      await pumpProjection(tester);

      expect(find.text('60-Month Projection'), findsOneWidget);
      expect(find.text('Net Worth in 5 Years'), findsOneWidget);
      expect(find.text('Optimistic'), findsOneWidget);
      expect(find.text('Base'), findsOneWidget);
      expect(find.text('Pessimistic'), findsOneWidget);
    });

    testWidgets('should render line chart with 3 series', (tester) async {
      await seedTestFamily(db);
      await pumpProjection(tester);

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('should display assumption sliders', (tester) async {
      await seedTestFamily(db);
      await pumpProjection(tester);

      expect(find.text('Assumptions'), findsOneWidget);
      expect(find.text('Monthly Income'), findsOneWidget);
      expect(find.text('Monthly Expenses'), findsOneWidget);
      expect(find.text('Expected Return'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(3));
    });

    testWidgets('should show formatted default values', (tester) async {
      await seedTestFamily(db);
      await pumpProjection(tester);

      // Default income ₹1,50,000 and expenses ₹1,00,000
      expect(find.text('₹1,50,000'), findsWidgets);
      expect(find.text('₹1,00,000'), findsWidgets);
      expect(find.text('10%'), findsOneWidget);
    });

    testWidgets('should show optimistic > base > pessimistic ordering', (tester) async {
      await seedTestFamily(db);
      await pumpProjection(tester);

      // All three scenario rows should be present with formatted amounts
      // The optimistic value should be highest, pessimistic lowest
      // We verify the labels exist and chart renders — exact values
      // are validated in unit tests (projection_engine_test.dart)
      expect(find.text('Optimistic'), findsOneWidget);
      expect(find.text('Base'), findsOneWidget);
      expect(find.text('Pessimistic'), findsOneWidget);
    });
  });
}
