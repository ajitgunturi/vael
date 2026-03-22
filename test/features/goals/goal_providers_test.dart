import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/goals/providers/goal_providers.dart';

const _familyId = 'fam_goals';

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
            name: 'Goal Family',
            createdAt: DateTime(2025),
          ),
        );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('GoalProviders', () {
    test('goalDaoProvider derives from databaseProvider', () {
      final dao = container.read(goalDaoProvider);
      expect(dao, isNotNull);
    });

    test('goalListProvider emits empty list when no goals', () async {
      final goals = await container.read(goalDaoProvider).getAll(_familyId);
      expect(goals, isEmpty);
    });

    test('goalListProvider streams goals after insertion', () async {
      final dao = container.read(goalDaoProvider);
      await dao.insertGoal(
        GoalsCompanion.insert(
          id: 'g1',
          name: 'Emergency Fund',
          targetAmount: 50000000,
          targetDate: DateTime(2027, 1, 1),
          familyId: _familyId,
          createdAt: DateTime.now(),
        ),
      );

      final goals = await dao.getAll(_familyId);
      expect(goals, hasLength(1));
      expect(goals.first.name, 'Emergency Fund');
    });
  });
}
