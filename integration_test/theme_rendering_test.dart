import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/dashboard/screens/dashboard_screen.dart';
import 'package:vael/core/financial/dashboard_aggregation.dart';
import 'package:vael/shared/theme/app_theme.dart';

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

  Widget buildThemed({required ThemeMode mode}) {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        home: const DashboardScreen(familyId: kTestFamilyId, userId: kTestUserId),
      ),
    );
  }

  group('Theme Rendering', () {
    testWidgets('should render light theme without errors', (tester) async {
      await seedTestFamily(db);
      await tester.pumpWidget(buildThemed(mode: ThemeMode.light));
      await tester.pumpAndSettle();

      // Verify the dashboard renders in light mode
      expect(find.text('Net Worth'), findsOneWidget);

      // Light theme should use a light scaffold background
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      final bg = scaffold.backgroundColor;
      // If null, MaterialApp uses theme default which is fine
      if (bg != null) {
        // Light theme background should have high luminance
        expect(bg.computeLuminance(), greaterThan(0.4));
      }
    });

    testWidgets('should render dark theme without errors', (tester) async {
      await seedTestFamily(db);
      await tester.pumpWidget(buildThemed(mode: ThemeMode.dark));
      await tester.pumpAndSettle();

      // Dashboard should still render in dark mode
      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
    });

    testWidgets('should render Material 3 components correctly', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(buildThemed(mode: ThemeMode.light));
      await tester.pumpAndSettle();

      // Verify Material 3 widgets are present and rendering
      expect(find.byType(Card), findsWidgets);
      expect(find.byType(Chip), findsOneWidget); // Savings rate badge

      // FilledButton.tonal (quick actions) should render
      expect(find.byType(FilledButton), findsWidgets);
    });

    testWidgets('should render SegmentedButton scope toggle', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(buildThemed(mode: ThemeMode.light));
      await tester.pumpAndSettle();

      // Dashboard scope toggle
      expect(find.text('Family'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      expect(find.byType(SegmentedButton<DashboardScope>), findsOneWidget);
    });
  });
}
