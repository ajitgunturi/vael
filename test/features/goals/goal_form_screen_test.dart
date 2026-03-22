import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/goals/screens/goal_form_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'fam_goals';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.families)
        .insert(
          FamiliesCompanion.insert(
            id: _familyId,
            name: 'Test Family',
            createdAt: DateTime(2025),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const GoalFormScreen(familyId: _familyId),
      ),
    );
  }

  group('GoalFormScreen', () {
    testWidgets('renders name, amount, and date fields', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Goal Name'), findsOneWidget);
      expect(find.text('Target Amount'), findsOneWidget);
      expect(find.text('Target Date'), findsOneWidget);
    });

    testWidgets('validates name required', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Tap save without filling name
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a goal name'), findsOneWidget);
    });

    testWidgets('validates target amount positive', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Fill name but leave amount empty
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Goal Name'),
        'Test Goal',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a target amount'), findsOneWidget);
    });

    testWidgets('inserts goal on valid submission', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Goal Name'),
        'Emergency Fund',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Target Amount'),
        '500000',
      );

      // Select a date (tap the date field to open picker)
      await tester.tap(find.text('Target Date'));
      await tester.pumpAndSettle();

      // Find and tap OK on date picker
      if (find.text('OK').evaluate().isNotEmpty) {
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }

      // Submit
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify goal was inserted
      final goals = await db.select(db.goals).get();
      expect(goals, hasLength(1));
      expect(goals.first.name, 'Emergency Fund');
    });
  });
}
