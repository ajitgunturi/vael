import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/milestone_engine.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/planning/providers/life_profile_provider.dart';
import 'package:vael/features/planning/providers/milestone_provider.dart';

const _familyId = 'fam_ms';
const _userId = 'user_ms';
const _profileId = 'lp_ms';

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
            name: 'Milestone Family',
            createdAt: DateTime(2025),
          ),
        );
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: _userId,
            email: 'ms@family.local',
            displayName: 'MS User',
            role: 'admin',
            familyId: _familyId,
          ),
        );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> _insertProfile({
    DateTime? dob,
    String riskProfile = 'MODERATE',
  }) async {
    final now = DateTime.now();
    final dao = container.read(lifeProfileDaoProvider);
    await dao.upsertProfile(
      LifeProfilesCompanion(
        id: const Value(_profileId),
        userId: const Value(_userId),
        familyId: const Value(_familyId),
        dateOfBirth: Value(dob ?? DateTime(1990, 6, 15)),
        plannedRetirementAge: const Value(60),
        riskProfile: Value(riskProfile),
        annualIncomeGrowthBp: const Value(800),
        expectedInflationBp: const Value(600),
        safeWithdrawalRateBp: const Value(300),
        hikeMonth: const Value(4),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  group('milestoneListProvider', () {
    test('emits empty list when no life profile exists', () async {
      // Ensure profile stream is resolved.
      container.listen(
        lifeProfileProvider((userId: _userId, familyId: _familyId)),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final sub = container.listen(
        milestoneListProvider((userId: _userId, familyId: _familyId)),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final result = sub.read();
      expect(result.value, isEmpty);
    });

    test('emits 5 milestone items when life profile exists', () async {
      await _insertProfile();

      container.listen(
        lifeProfileProvider((userId: _userId, familyId: _familyId)),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final sub = container.listen(
        milestoneListProvider((userId: _userId, familyId: _familyId)),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = sub.read();
      expect(result.value, isNotNull);
      expect(result.value!.length, 5);

      // Ages should be sorted ascending: 30, 40, 50, 60, 70.
      final ages = result.value!.map((m) => m.age).toList();
      expect(ages, [30, 40, 50, 60, 70]);
    });

    test('custom targets override computed defaults', () async {
      await _insertProfile(dob: DateTime(2000, 1, 1)); // age ~26

      final now = DateTime.now();
      // Insert a custom target for age 30.
      await db
          .into(db.netWorthMilestones)
          .insert(
            NetWorthMilestonesCompanion.insert(
              id: 'custom_30',
              userId: _userId,
              familyId: _familyId,
              lifeProfileId: _profileId,
              targetAge: 30,
              targetAmountPaise: 500000000, // Rs 50 L
              isCustomTarget: const Value(true),
              createdAt: now,
              updatedAt: now,
            ),
          );

      container.listen(
        lifeProfileProvider((userId: _userId, familyId: _familyId)),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final sub = container.listen(
        milestoneListProvider((userId: _userId, familyId: _familyId)),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = sub.read();
      expect(result.value, isNotNull);

      final age30 = result.value!.firstWhere((m) => m.age == 30);
      expect(age30.isCustomTarget, true);
      expect(age30.targetAmountPaise, 500000000);
      expect(age30.milestoneId, 'custom_30');
    });

    test(
      'past milestones have isPast=true and reached/missed status',
      () async {
        // Born 1980 => age ~46 in 2026. Ages 30, 40 are past.
        await _insertProfile(dob: DateTime(1980, 1, 1));

        container.listen(
          lifeProfileProvider((userId: _userId, familyId: _familyId)),
          (_, __) {},
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final sub = container.listen(
          milestoneListProvider((userId: _userId, familyId: _familyId)),
          (_, __) {},
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final result = sub.read();
        expect(result.value, isNotNull);

        final age30 = result.value!.firstWhere((m) => m.age == 30);
        final age40 = result.value!.firstWhere((m) => m.age == 40);
        final age50 = result.value!.firstWhere((m) => m.age == 50);

        expect(age30.isPast, true);
        expect(age40.isPast, true);
        expect(age50.isPast, false);
        expect(
          age30.status,
          anyOf(MilestoneStatus.reached, MilestoneStatus.missed),
        );
      },
    );
  });
}
