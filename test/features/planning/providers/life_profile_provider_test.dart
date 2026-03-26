import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/planning/providers/life_profile_provider.dart';

const _familyId = 'fam_planning';
const _userId = 'user_planning';

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
            name: 'Planning Family',
            createdAt: DateTime(2025),
          ),
        );
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: _userId,
            email: 'test@family.local',
            displayName: 'Test User',
            role: 'admin',
            familyId: _familyId,
          ),
        );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('lifeProfileProvider', () {
    test('emits null when no profile exists', () async {
      final sub = container.listen(
        lifeProfileProvider((userId: _userId, familyId: _familyId)),
        (_, __) {},
      );
      // Let the stream settle
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final state = sub.read();
      expect(state.value, isNull);
    });

    test('emits profile data after upsert (reactive update)', () async {
      final dao = container.read(lifeProfileDaoProvider);

      // Listen before insert to verify reactivity
      final sub = container.listen(
        lifeProfileProvider((userId: _userId, familyId: _familyId)),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(sub.read().value, isNull);

      // Insert profile
      final now = DateTime.now();
      await dao.upsertProfile(
        LifeProfilesCompanion(
          id: const Value('lp1'),
          userId: const Value(_userId),
          familyId: const Value(_familyId),
          dateOfBirth: Value(DateTime(1990, 5, 15)),
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

      // Wait for stream to emit
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final profile = sub.read().value;
      expect(profile, isNotNull);
      expect(profile!.riskProfile, 'MODERATE');
      expect(profile.plannedRetirementAge, 60);
      expect(profile.annualIncomeGrowthBp, 800);
    });
  });

  group('familyProfilesProvider', () {
    test('emits list of all family member profiles', () async {
      final dao = container.read(lifeProfileDaoProvider);
      final now = DateTime.now();

      // Insert two profiles for the family
      await dao.upsertProfile(
        LifeProfilesCompanion(
          id: const Value('lp_a'),
          userId: const Value(_userId),
          familyId: const Value(_familyId),
          dateOfBirth: Value(DateTime(1990, 1, 1)),
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

      // Add second user
      await db
          .into(db.users)
          .insert(
            UsersCompanion.insert(
              id: 'user2',
              email: 'user2@family.local',
              displayName: 'Second User',
              role: 'member',
              familyId: _familyId,
            ),
          );
      await dao.upsertProfile(
        LifeProfilesCompanion(
          id: const Value('lp_b'),
          userId: const Value('user2'),
          familyId: const Value(_familyId),
          dateOfBirth: Value(DateTime(1992, 6, 20)),
          plannedRetirementAge: const Value(55),
          riskProfile: const Value('AGGRESSIVE'),
          annualIncomeGrowthBp: const Value(1000),
          expectedInflationBp: const Value(600),
          safeWithdrawalRateBp: const Value(400),
          hikeMonth: const Value(4),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final sub = container.listen(
        familyProfilesProvider(_familyId),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final profiles = sub.read().value;
      expect(profiles, isNotNull);
      expect(profiles, hasLength(2));
    });
  });
}
