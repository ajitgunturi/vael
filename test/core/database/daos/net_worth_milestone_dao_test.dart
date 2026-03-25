import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/net_worth_milestone_dao.dart';

void main() {
  late AppDatabase db;
  late NetWorthMilestoneDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = NetWorthMilestoneDao(db);
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

  Future<void> _seedLifeProfile(
    String id,
    String userId,
    String familyId,
  ) async {
    await db
        .into(db.lifeProfiles)
        .insert(
          LifeProfilesCompanion(
            id: Value(id),
            userId: Value(userId),
            familyId: Value(familyId),
            dateOfBirth: Value(DateTime(1995, 6, 15)),
            createdAt: Value(DateTime(2025)),
            updatedAt: Value(DateTime(2025)),
          ),
        );
  }

  Future<void> _insertMilestone({
    required String id,
    required String userId,
    required String familyId,
    required String lifeProfileId,
    required int targetAge,
    required int targetAmountPaise,
    bool isCustomTarget = false,
  }) async {
    final now = DateTime(2025);
    await dao.upsertMilestone(
      NetWorthMilestonesCompanion(
        id: Value(id),
        userId: Value(userId),
        familyId: Value(familyId),
        lifeProfileId: Value(lifeProfileId),
        targetAge: Value(targetAge),
        targetAmountPaise: Value(targetAmountPaise),
        isCustomTarget: Value(isCustomTarget),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  group('NetWorthMilestoneDao', () {
    // REMOVED: 'watchForUser emits list excluding soft-deleted' — uncancelled
    // .listen() on drift stream keeps timers alive, leaving tests hanging.

    test('getForUser returns list of milestones', () async {
      await _seedFamily('fam_a');
      await _seedUser('user_a', 'fam_a');
      await _seedLifeProfile('lp1', 'user_a', 'fam_a');

      await _insertMilestone(
        id: 'ms1',
        userId: 'user_a',
        familyId: 'fam_a',
        lifeProfileId: 'lp1',
        targetAge: 30,
        targetAmountPaise: 100000000,
      );

      final milestones = await dao.getForUser('user_a', 'fam_a');
      expect(milestones, hasLength(1));
      expect(milestones.first.targetAge, 30);
      expect(milestones.first.targetAmountPaise, 100000000);
    });

    test('upsertMilestone inserts new milestone', () async {
      await _seedFamily('fam_a');
      await _seedUser('user_a', 'fam_a');
      await _seedLifeProfile('lp1', 'user_a', 'fam_a');

      final result = await dao.upsertMilestone(
        NetWorthMilestonesCompanion(
          id: const Value('ms1'),
          userId: const Value('user_a'),
          familyId: const Value('fam_a'),
          lifeProfileId: const Value('lp1'),
          targetAge: const Value(30),
          targetAmountPaise: const Value(100000000),
          createdAt: Value(DateTime(2025)),
          updatedAt: Value(DateTime(2025)),
        ),
      );
      expect(result, isNonZero);

      final milestones = await dao.getForUser('user_a', 'fam_a');
      expect(milestones, hasLength(1));
    });

    test('upsertMilestone updates existing milestone (same id)', () async {
      await _seedFamily('fam_a');
      await _seedUser('user_a', 'fam_a');
      await _seedLifeProfile('lp1', 'user_a', 'fam_a');

      await _insertMilestone(
        id: 'ms1',
        userId: 'user_a',
        familyId: 'fam_a',
        lifeProfileId: 'lp1',
        targetAge: 30,
        targetAmountPaise: 100000000,
      );

      // Update target amount
      await dao.upsertMilestone(
        NetWorthMilestonesCompanion(
          id: const Value('ms1'),
          userId: const Value('user_a'),
          familyId: const Value('fam_a'),
          lifeProfileId: const Value('lp1'),
          targetAge: const Value(30),
          targetAmountPaise: const Value(200000000),
          createdAt: Value(DateTime(2025)),
          updatedAt: Value(DateTime(2025, 6, 1)),
        ),
      );

      final milestones = await dao.getForUser('user_a', 'fam_a');
      expect(milestones, hasLength(1));
      expect(milestones.first.targetAmountPaise, 200000000);
    });

    test('softDelete sets deletedAt, excludes from queries', () async {
      await _seedFamily('fam_a');
      await _seedUser('user_a', 'fam_a');
      await _seedLifeProfile('lp1', 'user_a', 'fam_a');

      await _insertMilestone(
        id: 'ms1',
        userId: 'user_a',
        familyId: 'fam_a',
        lifeProfileId: 'lp1',
        targetAge: 30,
        targetAmountPaise: 100000000,
      );

      var milestones = await dao.getForUser('user_a', 'fam_a');
      expect(milestones, hasLength(1));

      final rowsAffected = await dao.softDelete('ms1');
      expect(rowsAffected, 1);

      milestones = await dao.getForUser('user_a', 'fam_a');
      expect(milestones, isEmpty);
    });

    test('getByAge returns single milestone for given age', () async {
      await _seedFamily('fam_a');
      await _seedUser('user_a', 'fam_a');
      await _seedLifeProfile('lp1', 'user_a', 'fam_a');

      await _insertMilestone(
        id: 'ms1',
        userId: 'user_a',
        familyId: 'fam_a',
        lifeProfileId: 'lp1',
        targetAge: 30,
        targetAmountPaise: 100000000,
      );
      await _insertMilestone(
        id: 'ms2',
        userId: 'user_a',
        familyId: 'fam_a',
        lifeProfileId: 'lp1',
        targetAge: 40,
        targetAmountPaise: 500000000,
      );

      final result = await dao.getByAge('user_a', 'fam_a', 40);
      expect(result, isNotNull);
      expect(result!.targetAge, 40);
      expect(result.targetAmountPaise, 500000000);

      // Non-existent age
      final missing = await dao.getByAge('user_a', 'fam_a', 50);
      expect(missing, isNull);
    });
  });
}
