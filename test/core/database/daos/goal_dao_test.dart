import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/goal_dao.dart';

void main() {
  late AppDatabase db;
  late GoalDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = GoalDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> _seedFamily(String familyId) async {
    await db.into(db.families).insert(FamiliesCompanion.insert(
          id: familyId,
          name: 'Family $familyId',
          createdAt: DateTime(2025),
        ));
    await db.into(db.users).insert(UsersCompanion.insert(
          id: 'user_$familyId',
          email: '$familyId@test.com',
          displayName: 'User $familyId',
          role: 'admin',
          familyId: familyId,
        ));
  }

  Future<void> _insertGoal({
    required String id,
    required String familyId,
    int targetAmount = 10000000,
    String status = 'active',
    int currentSavings = 0,
  }) async {
    await dao.insertGoal(GoalsCompanion(
      id: Value(id),
      name: Value('Goal $id'),
      targetAmount: Value(targetAmount),
      targetDate: Value(DateTime(2030, 1, 1)),
      currentSavings: Value(currentSavings),
      status: Value(status),
      familyId: Value(familyId),
      createdAt: Value(DateTime(2025)),
    ));
  }

  group('GoalDao', () {
    test('getAll returns goals for the given family', () async {
      await _seedFamily('fam_a');
      await _seedFamily('fam_b');

      await _insertGoal(id: 'g1', familyId: 'fam_a');
      await _insertGoal(id: 'g2', familyId: 'fam_a');
      await _insertGoal(id: 'g3', familyId: 'fam_b');

      final results = await dao.getAll('fam_a');

      expect(results, hasLength(2));
      expect(results.map((g) => g.id), containsAll(['g1', 'g2']));
    });

    test('getById returns goal within family', () async {
      await _seedFamily('fam_a');
      await _insertGoal(id: 'g1', familyId: 'fam_a');

      final found = await dao.getById('g1', 'fam_a');
      expect(found, isNotNull);
      expect(found!.id, 'g1');
    });

    test('getById returns null for wrong family', () async {
      await _seedFamily('fam_a');
      await _seedFamily('fam_b');
      await _insertGoal(id: 'g1', familyId: 'fam_a');

      final result = await dao.getById('g1', 'fam_b');
      expect(result, isNull);
    });

    test('getByStatus filters by goal status', () async {
      await _seedFamily('fam_a');

      await _insertGoal(id: 'g1', familyId: 'fam_a', status: 'active');
      await _insertGoal(id: 'g2', familyId: 'fam_a', status: 'onTrack');
      await _insertGoal(id: 'g3', familyId: 'fam_a', status: 'active');

      final active = await dao.getByStatus('fam_a', 'active');
      expect(active, hasLength(2));

      final onTrack = await dao.getByStatus('fam_a', 'onTrack');
      expect(onTrack, hasLength(1));
    });

    test('updateProgress updates savings and status', () async {
      await _seedFamily('fam_a');
      await _insertGoal(
          id: 'g1', familyId: 'fam_a', currentSavings: 0, status: 'active');

      final updated = await dao.updateProgress(
        'g1',
        currentSavings: 5000000,
        status: 'onTrack',
      );
      expect(updated, isTrue);

      final goal = await dao.getById('g1', 'fam_a');
      expect(goal!.currentSavings, 5000000);
      expect(goal.status, 'onTrack');
    });

    test('watchAll emits when a goal is added', () async {
      await _seedFamily('fam_a');

      final emissions = <List<Goal>>[];
      dao.watchAll('fam_a').listen((goals) {
        emissions.add(goals);
      });

      await Future<void>.delayed(Duration.zero);
      expect(emissions.last, isEmpty);

      await _insertGoal(id: 'g1', familyId: 'fam_a');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emissions.length, greaterThanOrEqualTo(2));
      expect(emissions.last, hasLength(1));
    });
  });
}
