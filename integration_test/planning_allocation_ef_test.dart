import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/planning/screens/allocation_screen.dart';
import 'package:vael/features/planning/screens/glide_path_editor_screen.dart';
import 'package:vael/features/planning/screens/emergency_fund_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<void> pumpAllocation(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AllocationScreen(
            familyId: kTestFamilyId,
            userId: kTestUserId,
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> pumpGlidePath(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const GlidePathEditorScreen(
            lifeProfileId: 'lp-1',
            riskProfile: 'moderate',
            userAge: 30,
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> pumpEmergencyFund(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const EmergencyFundScreen(
            familyId: kTestFamilyId,
            userId: kTestUserId,
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> seedLifeProfile(AppDatabase db) async {
    await db.into(db.lifeProfiles).insert(LifeProfilesCompanion.insert(
      id: 'lp-1',
      userId: kTestUserId,
      familyId: kTestFamilyId,
      dateOfBirth: DateTime(1995, 6, 15),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> seedHolding(AppDatabase db) async {
    await db.into(db.investmentHoldings).insert(
      InvestmentHoldingsCompanion.insert(
        id: 'ih-1',
        name: 'Index Fund',
        bucketType: 'mutualFunds',
        investedAmount: 30000000,
        currentValue: 35000000,
        familyId: kTestFamilyId,
        userId: kTestUserId,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> seedEfAccount(AppDatabase db) async {
    await seedAccount(
      db,
      id: 'acc-ef',
      name: 'Emergency FD',
      type: 'fixed_deposit',
      balance: 30000000,
    );
    await (db.update(db.accounts)..where((t) => t.id.equals('acc-ef')))
        .write(const AccountsCompanion(isEmergencyFund: Value(true)));
  }

  // ---------------------------------------------------------------------------
  // Allocation Screen
  // ---------------------------------------------------------------------------

  group('AllocationScreen', () {
    testWidgets('renders allocation screen with donut charts', (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile(db);
      await seedHolding(db);
      await pumpAllocation(tester);

      expect(find.text('Asset Allocation'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    }, timeout: kTestTimeout);

    testWidgets('shows empty state when no investments', (tester) async {
      await seedTestFamily(db);
      await pumpAllocation(tester);

      expect(find.text('No investments yet'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows Customize Targets button', (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile(db);
      await seedHolding(db);
      await pumpAllocation(tester);

      expect(find.text('Customize Targets'), findsOneWidget);
    }, timeout: kTestTimeout);
  });

  // ---------------------------------------------------------------------------
  // Glide Path Editor Screen
  // ---------------------------------------------------------------------------

  group('GlidePathEditorScreen', () {
    testWidgets('renders editor with age band rows', (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile(db);
      await pumpGlidePath(tester);

      expect(find.text('Allocation Targets'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows Reset to Defaults button', (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile(db);
      await pumpGlidePath(tester);

      expect(find.text('Reset to Defaults'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows Save Targets button', (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile(db);
      await pumpGlidePath(tester);

      expect(find.text('Save Targets'), findsOneWidget);
    }, timeout: kTestTimeout);
  });

  // ---------------------------------------------------------------------------
  // Emergency Fund Screen
  // ---------------------------------------------------------------------------

  group('EmergencyFundScreen', () {
    testWidgets('renders EF screen with progress ring', (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile(db);
      await seedEfAccount(db);
      await pumpEmergencyFund(tester);

      expect(find.text('Emergency Fund'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows linked EF accounts', (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile(db);
      await seedEfAccount(db);
      await pumpEmergencyFund(tester);

      expect(find.text('Emergency FD'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows empty state when no EF accounts', (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile(db);
      await pumpEmergencyFund(tester);

      expect(find.text('No accounts linked yet'), findsOneWidget);
    }, timeout: kTestTimeout);

    testWidgets('shows target configuration', (tester) async {
      await seedTestFamily(db);
      await seedLifeProfile(db);
      await seedEfAccount(db);
      await pumpEmergencyFund(tester);

      expect(find.text('Target Months'), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    }, timeout: kTestTimeout);
  });
}
