import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/life_profile_dao.dart';

void main() {
  late AppDatabase db;
  late LifeProfileDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = LifeProfileDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> _seedFamily(String familyId) async {
    await db
        .into(db.families)
        .insert(
          FamiliesCompanion.insert(
            id: familyId,
            name: 'Family $familyId',
            createdAt: DateTime(2025),
          ),
        );
  }

  Future<void> _seedUser(String userId, String familyId) async {
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: userId,
            email: '$userId@test.com',
            displayName: 'User $userId',
            role: 'admin',
            familyId: familyId,
          ),
        );
  }

  Future<void> _insertProfile({
    required String id,
    required String userId,
    required String familyId,
    DateTime? dateOfBirth,
    int? plannedRetirementAge,
    String? riskProfile,
    int? annualIncomeGrowthBp,
    int? expectedInflationBp,
    int? safeWithdrawalRateBp,
    int? hikeMonth,
  }) async {
    final now = DateTime(2025);
    final companion = LifeProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      familyId: Value(familyId),
      dateOfBirth: Value(dateOfBirth ?? DateTime(1995, 6, 15)),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
    // Add optional overrides
    final overrides = LifeProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      familyId: Value(familyId),
      dateOfBirth: Value(dateOfBirth ?? DateTime(1995, 6, 15)),
      plannedRetirementAge: plannedRetirementAge != null
          ? Value(plannedRetirementAge)
          : const Value.absent(),
      riskProfile: riskProfile != null
          ? Value(riskProfile)
          : const Value.absent(),
      annualIncomeGrowthBp: annualIncomeGrowthBp != null
          ? Value(annualIncomeGrowthBp)
          : const Value.absent(),
      expectedInflationBp: expectedInflationBp != null
          ? Value(expectedInflationBp)
          : const Value.absent(),
      safeWithdrawalRateBp: safeWithdrawalRateBp != null
          ? Value(safeWithdrawalRateBp)
          : const Value.absent(),
      hikeMonth: hikeMonth != null ? Value(hikeMonth) : const Value.absent(),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
    await dao.upsertProfile(overrides);
  }

  group('LifeProfileDao', () {
    test('upsert a profile and read it back with all fields', () async {
      await _seedFamily('fam_a');
      await _seedUser('user_a', 'fam_a');

      final now = DateTime(2025, 1, 1);
      final dob = DateTime(1990, 3, 20);

      await dao.upsertProfile(
        LifeProfilesCompanion(
          id: const Value('lp1'),
          userId: const Value('user_a'),
          familyId: const Value('fam_a'),
          dateOfBirth: Value(dob),
          plannedRetirementAge: const Value(58),
          riskProfile: const Value('AGGRESSIVE'),
          annualIncomeGrowthBp: const Value(1000),
          expectedInflationBp: const Value(700),
          safeWithdrawalRateBp: const Value(350),
          hikeMonth: const Value(7),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final profile = await dao.getForUser('user_a', 'fam_a');
      expect(profile, isNotNull);
      expect(profile!.id, 'lp1');
      expect(profile.userId, 'user_a');
      expect(profile.familyId, 'fam_a');
      expect(profile.dateOfBirth, dob);
      expect(profile.plannedRetirementAge, 58);
      expect(profile.riskProfile, 'AGGRESSIVE');
      expect(profile.annualIncomeGrowthBp, 1000);
      expect(profile.expectedInflationBp, 700);
      expect(profile.safeWithdrawalRateBp, 350);
      expect(profile.hikeMonth, 7);
      expect(profile.createdAt, now);
      expect(profile.updatedAt, now);
      expect(profile.deletedAt, isNull);
    });

    test('watchForUser returns stream, emits null when no profile', () async {
      await _seedFamily('fam_a');
      await _seedUser('user_a', 'fam_a');

      final emissions = <LifeProfile?>[];
      dao.watchForUser('user_a', 'fam_a').listen(emissions.add);

      await Future<void>.delayed(Duration.zero);
      expect(emissions.last, isNull);

      await _insertProfile(id: 'lp1', userId: 'user_a', familyId: 'fam_a');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emissions.length, greaterThanOrEqualTo(2));
      expect(emissions.last, isNotNull);
      expect(emissions.last!.userId, 'user_a');
    });

    test('watchAll returns all profiles for a family', () async {
      await _seedFamily('fam_a');
      await _seedUser('user_a', 'fam_a');
      await _seedUser('user_b', 'fam_a');

      await _insertProfile(id: 'lp1', userId: 'user_a', familyId: 'fam_a');
      await _insertProfile(id: 'lp2', userId: 'user_b', familyId: 'fam_a');

      final emissions = <List<LifeProfile>>[];
      dao.watchAll('fam_a').listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emissions.last, hasLength(2));
    });

    test('two users in same family have independent profiles', () async {
      await _seedFamily('fam_a');
      await _seedUser('user_a', 'fam_a');
      await _seedUser('user_b', 'fam_a');

      await _insertProfile(
        id: 'lp1',
        userId: 'user_a',
        familyId: 'fam_a',
        plannedRetirementAge: 55,
      );
      await _insertProfile(
        id: 'lp2',
        userId: 'user_b',
        familyId: 'fam_a',
        plannedRetirementAge: 65,
      );

      final profileA = await dao.getForUser('user_a', 'fam_a');
      final profileB = await dao.getForUser('user_b', 'fam_a');

      expect(profileA!.plannedRetirementAge, 55);
      expect(profileB!.plannedRetirementAge, 65);
      expect(profileA.id, isNot(profileB.id));
    });

    test('default values apply when not specified', () async {
      await _seedFamily('fam_a');
      await _seedUser('user_a', 'fam_a');

      await _insertProfile(id: 'lp1', userId: 'user_a', familyId: 'fam_a');

      final profile = await dao.getForUser('user_a', 'fam_a');
      expect(profile, isNotNull);
      expect(profile!.plannedRetirementAge, 60);
      expect(profile.riskProfile, 'MODERATE');
      expect(profile.annualIncomeGrowthBp, 800);
      expect(profile.expectedInflationBp, 600);
      expect(profile.safeWithdrawalRateBp, 300);
      expect(profile.hikeMonth, 4);
    });

    test('upsert with same id updates existing record', () async {
      await _seedFamily('fam_a');
      await _seedUser('user_a', 'fam_a');

      await _insertProfile(
        id: 'lp1',
        userId: 'user_a',
        familyId: 'fam_a',
        plannedRetirementAge: 60,
      );

      // Update the same profile
      final updated = DateTime(2025, 6, 1);
      await dao.upsertProfile(
        LifeProfilesCompanion(
          id: const Value('lp1'),
          userId: const Value('user_a'),
          familyId: const Value('fam_a'),
          dateOfBirth: Value(DateTime(1995, 6, 15)),
          plannedRetirementAge: const Value(55),
          riskProfile: const Value('CONSERVATIVE'),
          annualIncomeGrowthBp: const Value(600),
          expectedInflationBp: const Value(500),
          safeWithdrawalRateBp: const Value(250),
          hikeMonth: const Value(1),
          createdAt: Value(DateTime(2025)),
          updatedAt: Value(updated),
        ),
      );

      final profile = await dao.getForUser('user_a', 'fam_a');
      expect(profile!.plannedRetirementAge, 55);
      expect(profile.riskProfile, 'CONSERVATIVE');
      expect(profile.annualIncomeGrowthBp, 600);
      expect(profile.updatedAt, updated);
    });

    test('soft delete via deletedAt column', () async {
      await _seedFamily('fam_a');
      await _seedUser('user_a', 'fam_a');

      await _insertProfile(id: 'lp1', userId: 'user_a', familyId: 'fam_a');

      // Verify it exists
      var profile = await dao.getForUser('user_a', 'fam_a');
      expect(profile, isNotNull);

      // Soft delete
      final rowsAffected = await dao.softDelete('lp1');
      expect(rowsAffected, 1);

      // Should not appear in normal queries (filters deletedAt.isNull)
      profile = await dao.getForUser('user_a', 'fam_a');
      expect(profile, isNull);
    });
  });
}
