import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/onboarding/screens/onboarding_flow.dart';
import 'package:vael/shared/theme/app_theme.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(theme: AppTheme.light(), home: const OnboardingFlow()),
    );
  }

  group('OnboardingFlow', () {
    testWidgets('shows welcome screen on step 0', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Vael'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('advances to sign-in step on Get Started tap', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      // Debug mode shows skip button
      expect(find.text('Skip (Dev Mode)'), findsOneWidget);
    });

    testWidgets('skip dev mode advances to create family step', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip (Dev Mode)'));
      await tester.pumpAndSettle();

      expect(find.text('Create Your Family'), findsOneWidget);
      expect(find.text('Family Name'), findsOneWidget);
      expect(find.textContaining('Signed in as'), findsOneWidget);
    });

    testWidgets('validates family name required', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skip (Dev Mode)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Family'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a family name'), findsOneWidget);
    });

    testWidgets('creates family and sets session on valid submission', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skip (Dev Mode)'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Family Name'),
        'The Smiths',
      );
      await tester.tap(find.text('Create Family'));
      await tester.pumpAndSettle();

      // Verify DB was seeded
      final families = await db.select(db.families).get();
      expect(families, hasLength(1));
      expect(families.first.name, 'The Smiths');

      final users = await db.select(db.users).get();
      expect(users, hasLength(1));
    });
  });
}
