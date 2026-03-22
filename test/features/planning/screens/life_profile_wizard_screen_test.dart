import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/life_profile_dao.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/planning/screens/life_profile_wizard_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'fam_wizard';
const _userId = 'user_wizard';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.families)
        .insert(
          FamiliesCompanion.insert(
            id: _familyId,
            name: 'Wizard Family',
            createdAt: DateTime(2025),
          ),
        );
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: _userId,
            email: 'wizard@family.local',
            displayName: 'Wizard User',
            role: 'admin',
            familyId: _familyId,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildApp({LifeProfile? existingProfile}) {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: LifeProfileWizardScreen(
          userId: _userId,
          familyId: _familyId,
          existingProfile: existingProfile,
        ),
      ),
    );
  }

  group('LifeProfileWizardScreen', () {
    testWidgets('shows step 1 with DOB picker and retirement age on launch', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Personal Details'), findsOneWidget);
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('Planned Retirement Age'), findsOneWidget);
      expect(find.text('60'), findsOneWidget); // default retirement age
    });

    testWidgets('shows 3 risk profile cards in step 2', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Set DOB first to proceed
      await tester.tap(find.text('Tap to select'));
      await tester.pumpAndSettle();
      // Pick a date in the date picker dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Advance to step 2
      await tester.tap(find.text('Next').first);
      await tester.pumpAndSettle();

      expect(find.text('Risk Profile'), findsOneWidget);
      expect(find.text('Conservative'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.text('Aggressive'), findsOneWidget);
      expect(find.text('35% Equity'), findsOneWidget);
      expect(find.text('60% Equity'), findsOneWidget);
      expect(find.text('85% Equity'), findsOneWidget);
    });

    testWidgets('shows 3 rate sliders in step 3', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Select DOB
      await tester.tap(find.text('Tap to select'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Step 1 -> 2
      await tester.tap(find.text('Next').first);
      await tester.pumpAndSettle();

      // Step 2 -> 3 (tap step title -- controls may be obscured by cards)
      await tester.tap(find.text('Growth Rates'));
      await tester.pumpAndSettle();

      expect(find.text('Growth Rates'), findsOneWidget);
      expect(find.text('Income Growth'), findsOneWidget);
      expect(find.text('Inflation'), findsOneWidget);
      expect(find.text('Safe Withdrawal Rate'), findsOneWidget);
      expect(find.text('Annual Hike Month'), findsOneWidget);
      // Default slider values
      expect(find.text('8.0%'), findsOneWidget); // Income Growth default
      expect(find.text('6.0%'), findsOneWidget); // Inflation default
      expect(find.text('3.0%'), findsOneWidget); // SWR default
    });

    testWidgets('saving calls upsertProfile on the DAO', (tester) async {
      // Use a very tall surface so the Stepper's step 3 Save button is
      // not obscured by Slider overlays.
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Step 1: Select DOB
      await tester.tap(find.text('Tap to select'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Navigate to step 3 directly by tapping step title
      await tester.tap(find.text('Growth Rates'));
      await tester.pumpAndSettle();

      // Find and tap the Save button within the active step controls
      final saveBtn = find.widgetWithText(FilledButton, 'Save').first;
      await tester.ensureVisible(saveBtn);
      await tester.pumpAndSettle();
      await tester.tap(saveBtn, warnIfMissed: false);
      // Pump to allow the async _save() to run (setState + DB write + pop)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify the profile was saved to the database
      final dao = LifeProfileDao(db);
      final profile = await dao.getForUser(_userId, _familyId);
      expect(profile, isNotNull);
      expect(profile!.riskProfile, 'MODERATE');
      expect(profile.plannedRetirementAge, 60);
    });

    testWidgets('edit mode pre-fills existing values', (tester) async {
      final existing = LifeProfile(
        id: 'lp_edit',
        userId: _userId,
        familyId: _familyId,
        dateOfBirth: DateTime(1985, 3, 10),
        plannedRetirementAge: 55,
        riskProfile: 'AGGRESSIVE',
        annualIncomeGrowthBp: 1000,
        expectedInflationBp: 700,
        safeWithdrawalRateBp: 400,
        hikeMonth: 7,
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
        deletedAt: null,
      );

      await tester.pumpWidget(buildApp(existingProfile: existing));
      await tester.pumpAndSettle();

      // Step 1: check pre-filled DOB and retirement age
      expect(find.text('Edit Life Profile'), findsOneWidget);
      expect(find.text('10/3/1985'), findsOneWidget);
      expect(find.text('55'), findsOneWidget);

      // Advance to step 2
      await tester.tap(find.text('Next').first);
      await tester.pumpAndSettle();

      // The Aggressive card should be selected (85% Equity visible)
      expect(find.text('85% Equity'), findsOneWidget);

      // Advance to step 3 by tapping the step title directly
      // (Stepper step titles are tappable to navigate)
      await tester.tap(find.text('Growth Rates'));
      await tester.pumpAndSettle();

      // Verify pre-filled slider values
      expect(find.text('10.0%'), findsOneWidget); // 1000 bp
      expect(find.text('7.0%'), findsOneWidget); // 700 bp
      expect(find.text('4.0%'), findsOneWidget); // 400 bp
      expect(find.text('July'), findsOneWidget); // hikeMonth 7
    });
  });
}
