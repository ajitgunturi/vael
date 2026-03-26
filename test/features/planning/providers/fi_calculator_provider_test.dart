import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/planning/providers/fi_calculator_provider.dart';
import 'package:vael/features/planning/providers/life_profile_provider.dart';

const _familyId = 'fam_fi';
const _userId = 'user_fi';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    await db
        .into(db.families)
        .insert(
          FamiliesCompanion.insert(
            id: _familyId,
            name: 'FI Family',
            createdAt: DateTime(2025),
          ),
        );
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: _userId,
            email: 'fi@family.local',
            displayName: 'FI User',
            role: 'admin',
            familyId: _familyId,
          ),
        );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('FiInputs', () {
    test('default constructor has standalone defaults', () {
      const inputs = FiInputs();
      expect(inputs.swrBp, 300);
      expect(inputs.returnsBp, 1000);
      expect(inputs.inflationBp, 600);
      expect(inputs.monthlyExpensesPaise, 5000000);
      expect(inputs.currentAge, 30);
      expect(inputs.retirementAge, 60);
      expect(inputs.currentPortfolioPaise, 0);
      expect(inputs.monthlySavingsPaise, 0);
      expect(inputs.hasLifeProfile, false);
    });

    test('copyWith creates new instance with changed fields', () {
      const original = FiInputs();
      final modified = original.copyWith(swrBp: 400, hasLifeProfile: true);
      expect(modified.swrBp, 400);
      expect(modified.hasLifeProfile, true);
      expect(modified.returnsBp, 1000); // unchanged
    });

    test('equality works correctly', () {
      const a = FiInputs();
      const b = FiInputs();
      final c = a.copyWith(swrBp: 400);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('fiDefaultInputsProvider', () {
    test('returns standalone defaults when no life profile exists', () async {
      // Let stream settle
      final sub = container.listen(
        lifeProfileProvider((userId: _userId, familyId: _familyId)),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(sub.read().value, isNull);

      final inputs = container.read(
        fiDefaultInputsProvider((userId: _userId, familyId: _familyId)),
      );
      expect(inputs.hasLifeProfile, false);
      expect(inputs.swrBp, 300);
      expect(inputs.inflationBp, 600);
      expect(inputs.currentAge, 30);
      expect(inputs.retirementAge, 60);
      expect(inputs.monthlyExpensesPaise, 5000000);
    });

    test('returns profile values when life profile exists', () async {
      final dao = container.read(lifeProfileDaoProvider);
      final now = DateTime.now();
      final dob = DateTime(1990, 6, 15);

      await dao.upsertProfile(
        LifeProfilesCompanion(
          id: const Value('lp_fi'),
          userId: const Value(_userId),
          familyId: const Value(_familyId),
          dateOfBirth: Value(dob),
          plannedRetirementAge: const Value(55),
          riskProfile: const Value('AGGRESSIVE'),
          annualIncomeGrowthBp: const Value(1000),
          expectedInflationBp: const Value(700),
          safeWithdrawalRateBp: const Value(350),
          hikeMonth: const Value(4),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      // Let stream settle with the new profile
      container.listen(
        lifeProfileProvider((userId: _userId, familyId: _familyId)),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final inputs = container.read(
        fiDefaultInputsProvider((userId: _userId, familyId: _familyId)),
      );
      expect(inputs.hasLifeProfile, true);
      expect(inputs.swrBp, 350);
      expect(inputs.inflationBp, 700);
      expect(inputs.retirementAge, 55);
      // Age should be computed from DOB (1990-06-15)
      final expectedAge =
          now.year -
          1990 -
          ((now.month < 6 || (now.month == 6 && now.day < 15)) ? 1 : 0);
      expect(inputs.currentAge, expectedAge);
    });

    test('hasLifeProfile flag is false without profile, true with', () async {
      // Without profile
      final inputsNoProfile = container.read(
        fiDefaultInputsProvider((userId: _userId, familyId: _familyId)),
      );
      expect(inputsNoProfile.hasLifeProfile, false);

      // Insert profile
      final dao = container.read(lifeProfileDaoProvider);
      final now = DateTime.now();
      await dao.upsertProfile(
        LifeProfilesCompanion(
          id: const Value('lp_fi2'),
          userId: const Value(_userId),
          familyId: const Value(_familyId),
          dateOfBirth: Value(DateTime(1985, 1, 1)),
          plannedRetirementAge: const Value(60),
          riskProfile: const Value('MODERATE'),
          annualIncomeGrowthBp: const Value(800),
          expectedInflationBp: const Value(600),
          safeWithdrawalRateBp: const Value(300),
          hikeMonth: const Value(4),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      container.listen(
        lifeProfileProvider((userId: _userId, familyId: _familyId)),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final inputsWithProfile = container.read(
        fiDefaultInputsProvider((userId: _userId, familyId: _familyId)),
      );
      expect(inputsWithProfile.hasLifeProfile, true);
    });
  });
}
