import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/planning/screens/fi_calculator_screen.dart';
import 'package:vael/features/planning/screens/milestone_dashboard_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';
import 'package:vael/shared/widgets/empty_state.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Pumps the given [screen] inside a fully-wired ProviderScope + MaterialApp.
  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: screen,
        ),
      ),
    );
    await settle(tester);
  }

  /// Seeds a life profile for the test user (DOB 1995-06-15).
  Future<void> seedLifeProfile() async {
    await db.into(db.lifeProfiles).insert(LifeProfilesCompanion.insert(
          id: 'lp-1',
          userId: kTestUserId,
          familyId: kTestFamilyId,
          dateOfBirth: DateTime(1995, 6, 15),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
  }

  /// Seeds milestone rows for the decade ages used by the dashboard.
  Future<void> seedMilestones() async {
    final now = DateTime.now();
    final milestones = <(String, int, int)>[
      ('ms-30', 30, 5000000000), // ₹50L
      ('ms-40', 40, 20000000000), // ₹2Cr
      ('ms-50', 50, 50000000000), // ₹5Cr
      ('ms-60', 60, 100000000000), // ₹10Cr
      ('ms-70', 70, 200000000000), // ₹20Cr
    ];

    for (final (id, age, amount) in milestones) {
      await db.into(db.netWorthMilestones).insert(
            NetWorthMilestonesCompanion.insert(
              id: id,
              userId: kTestUserId,
              familyId: kTestFamilyId,
              lifeProfileId: 'lp-1',
              targetAge: age,
              targetAmountPaise: amount,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  // ---------------------------------------------------------------------------
  // FI Calculator
  // ---------------------------------------------------------------------------
  group('FI Calculator', () {
    testWidgets('renders FI calculator with hero card', (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile();

      await pumpScreen(
        tester,
        const FiCalculatorScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      expect(find.text('FI Calculator'), findsOneWidget);
      expect(find.text('Monthly Expenses'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows sliders for rates', (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile();

      await pumpScreen(
        tester,
        const FiCalculatorScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      expect(find.text('Safe Withdrawal Rate'), findsOneWidget);
      expect(find.text('Expected Returns'), findsOneWidget);
      expect(find.text('Inflation'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows profile setup banner when no profile', (tester) async {
      await seedTestFamily(db);
      // Deliberately do NOT seed a life profile.

      await pumpScreen(
        tester,
        const FiCalculatorScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      expect(
        find.text('Set up your life profile for personalized results'),
        findsOneWidget,
      );
      expect(find.text('Set Up'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('secondary cards show Years to FI and Coast FI',
        (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile();

      await pumpScreen(
        tester,
        const FiCalculatorScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      expect(find.text('Years to FI'), findsOneWidget);
      expect(find.text('Coast FI'), findsOneWidget);
    }, timeout: kTestTimeout);
  });

  // ---------------------------------------------------------------------------
  // Milestone Dashboard
  // ---------------------------------------------------------------------------
  group('Milestone Dashboard', () {
    testWidgets('renders milestone dashboard with decade cards',
        (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile();
      await seedMilestones();

      await pumpScreen(
        tester,
        const MilestoneDashboardScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      expect(find.text('Net Worth Milestones'), findsOneWidget);
      // Should show 5 decade cards (ages 30-70)
      expect(find.byType(Card), findsNWidgets(5));
    }, timeout: kTestTimeout);

    testWidgets('shows empty state without life profile', (tester) async {
      await seedTestFamily(db);
      // No life profile seeded.

      await pumpScreen(
        tester,
        const MilestoneDashboardScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No life profile yet'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('decade cards display target amounts', (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile();
      await seedMilestones();

      await pumpScreen(
        tester,
        const MilestoneDashboardScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      // Milestone card shows "Target: Rs X L/Cr" for each seeded amount.
      // ₹50L = Rs 50.0 L
      expect(find.textContaining('50'), findsWidgets);
      // At least one "Target:" label should be present.
      expect(find.textContaining('Target:'), findsWidgets);
    }, timeout: kTestTimeout);

    testWidgets('tapping a milestone card opens edit sheet', (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile();
      await seedMilestones();

      await pumpScreen(
        tester,
        const MilestoneDashboardScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      // Find the edit icon on a future milestone card and tap it.
      final editIcons = find.byIcon(Icons.edit_outlined);
      expect(editIcons, findsWidgets);

      await tester.tap(editIcons.first);
      await settle(tester);

      // The bottom sheet should contain target-editing UI.
      expect(find.textContaining('Target'), findsWidgets);
    }, timeout: kTestTimeout);
  });
}
