import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/core/providers/session_providers.dart';
import 'package:vael/features/planning/screens/decision_modeler_screen.dart';
import 'package:vael/features/planning/screens/lifetime_timeline_screen.dart';
import 'package:vael/features/planning/screens/opportunity_fund_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Pumps a standalone screen wrapped in ProviderScope + MaterialApp.
  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sessionUserIdProvider.overrideWith(() {
            final n = SessionUserIdNotifier();
            return n;
          }),
          sessionFamilyIdProvider.overrideWith(() {
            final n = SessionFamilyIdNotifier();
            return n;
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: screen,
        ),
      ),
    );
    // Set session values after the container is created.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    container.read(sessionUserIdProvider.notifier).set(kTestUserId);
    container.read(sessionFamilyIdProvider.notifier).set(kTestFamilyId);
    await settle(tester);
  }

  // ===========================================================================
  // Decision Modeler
  // ===========================================================================

  group('Decision Modeler', () {
    testWidgets('renders decision type selection (step 1)', (tester) async {
      await seedTestFamily(db);

      await pumpScreen(
        tester,
        const DecisionModelerScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      // Title in AppBar
      expect(find.text('Model a Decision'), findsOneWidget);

      // Decision type options visible
      expect(find.text('Job Change'), findsOneWidget);
      expect(find.text('Salary Negotiation'), findsOneWidget);
      expect(find.text('Major Purchase'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('selecting a type advances to step 2', (tester) async {
      await seedTestFamily(db);

      await pumpScreen(
        tester,
        const DecisionModelerScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      // Tap "Job Change" card
      await tester.tap(find.text('Job Change'));
      await settle(tester);

      // Tap "Next" to advance
      await tester.tap(find.text('Next'));
      await settle(tester);

      // Step indicator should now show "Parameters"
      expect(find.text('Parameters'), findsOneWidget);

      // Form field for job change should appear
      expect(find.text('New Monthly Salary'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows wizard step indicator', (tester) async {
      await seedTestFamily(db);

      await pumpScreen(
        tester,
        const DecisionModelerScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      // Step 1 label visible
      expect(find.text('Choose Type'), findsOneWidget);

      // Step indicator dots: 4 small Container circles exist inside the indicator row.
      // The Semantics label encodes the step info.
      expect(
        find.bySemanticsLabel(RegExp(r'Step 1 of 4: Choose Type')),
        findsOneWidget,
      );
    }, timeout: kTestTimeout);
  });

  // ===========================================================================
  // Lifetime Timeline
  // ===========================================================================

  group('Lifetime Timeline', () {
    testWidgets('renders timeline screen', (tester) async {
      await seedTestFamily(db);
      // Seed a life profile so the timeline has data
      await db.into(db.lifeProfiles).insert(LifeProfilesCompanion.insert(
        id: 'lp-1',
        userId: kTestUserId,
        familyId: kTestFamilyId,
        dateOfBirth: DateTime(1995, 6, 15),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await pumpScreen(
        tester,
        const LifetimeTimelineScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      expect(find.text('Life Plan'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows empty state without profile', (tester) async {
      await seedTestFamily(db);

      await pumpScreen(
        tester,
        const LifetimeTimelineScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      // EmptyState title when no life profile exists
      expect(
        find.text('Set up your Life Profile to see your timeline'),
        findsOneWidget,
      );
      expect(find.text('Set Up Profile'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows CustomPaint for timeline', (tester) async {
      await seedTestFamily(db);
      await db.into(db.lifeProfiles).insert(LifeProfilesCompanion.insert(
        id: 'lp-1',
        userId: kTestUserId,
        familyId: kTestFamilyId,
        dateOfBirth: DateTime(1995, 6, 15),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await pumpScreen(
        tester,
        const LifetimeTimelineScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    }, timeout: kTestTimeout);
  });

  // ===========================================================================
  // Opportunity Fund
  // ===========================================================================

  group('Opportunity Fund', () {
    testWidgets('renders opportunity fund screen', (tester) async {
      await seedTestFamily(db);

      await pumpScreen(
        tester,
        const OpportunityFundScreen(familyId: kTestFamilyId),
      );

      expect(find.text('Opportunity Fund'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows empty state when no fund designated', (tester) async {
      await seedTestFamily(db);

      await pumpScreen(
        tester,
        const OpportunityFundScreen(familyId: kTestFamilyId),
      );

      expect(find.text('No opportunity fund designated'), findsOneWidget);
      expect(find.text('Designate Account'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows progress when fund designated', (tester) async {
      await seedTestFamily(db);
      // Seed and designate an opportunity fund account
      await seedAccount(
        db,
        id: 'acc-opp',
        name: 'Opportunity Fund',
        type: 'savings',
        balance: 10000000,
      );
      await (db.update(db.accounts)..where((t) => t.id.equals('acc-opp')))
          .write(AccountsCompanion(
        isOpportunityFund: const Value(true),
        opportunityFundTargetPaise: const Value(50000000),
      ));

      await pumpScreen(
        tester,
        const OpportunityFundScreen(familyId: kTestFamilyId),
      );

      // Account name displayed
      expect(find.text('Opportunity Fund'), findsWidgets);
      // Progress percentage (10M / 50M = 20%)
      expect(find.text('20%'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows designation controls', (tester) async {
      await seedTestFamily(db);
      await seedAccount(
        db,
        id: 'acc-opp',
        name: 'Opportunity Fund',
        type: 'savings',
        balance: 10000000,
      );
      await (db.update(db.accounts)..where((t) => t.id.equals('acc-opp')))
          .write(AccountsCompanion(
        isOpportunityFund: const Value(true),
        opportunityFundTargetPaise: const Value(50000000),
      ));

      await pumpScreen(
        tester,
        const OpportunityFundScreen(familyId: kTestFamilyId),
      );

      expect(find.text('Change Account'), findsOneWidget);
      expect(find.text('Remove Designation'), findsOneWidget);
    }, timeout: kTestTimeout);
  });
}
