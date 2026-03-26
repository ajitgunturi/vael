import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/goals.dart';

part 'goal_dao.g.dart';

@DriftAccessor(tables: [Goals])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  GoalDao(super.db);

  /// Returns all goals belonging to [familyId].
  Future<List<Goal>> getAll(String familyId) {
    return (select(goals)..where((g) => g.familyId.equals(familyId))).get();
  }

  /// Watches all goals belonging to [familyId].
  Stream<List<Goal>> watchAll(String familyId) {
    return (select(goals)..where((g) => g.familyId.equals(familyId))).watch();
  }

  /// Returns a single goal by [id] within [familyId].
  Future<Goal?> getById(String id, String familyId) {
    return (select(goals)
          ..where((g) => g.id.equals(id) & g.familyId.equals(familyId)))
        .getSingleOrNull();
  }

  /// Returns goals filtered by [status] within [familyId].
  Future<List<Goal>> getByStatus(String familyId, String status) {
    return (select(goals)
          ..where((g) => g.familyId.equals(familyId) & g.status.equals(status)))
        .get();
  }

  /// Watches goals filtered by [category] within [familyId], ordered by priority.
  Stream<List<Goal>> watchByCategory(String familyId, String category) =>
      (select(goals)
            ..where(
              (g) =>
                  g.familyId.equals(familyId) & g.goalCategory.equals(category),
            )
            ..orderBy([(g) => OrderingTerm.asc(g.priority)]))
          .watch();

  /// Watches goals filtered by multiple [categories] within [familyId], ordered by priority.
  Stream<List<Goal>> watchByCategories(
    String familyId,
    List<String> categories,
  ) =>
      (select(goals)
            ..where(
              (g) =>
                  g.familyId.equals(familyId) & g.goalCategory.isIn(categories),
            )
            ..orderBy([(g) => OrderingTerm.asc(g.priority)]))
          .watch();

  /// Inserts a new goal.
  Future<int> insertGoal(GoalsCompanion entry) {
    return into(goals).insert(entry);
  }

  /// Updates the current savings and status of a goal.
  Future<bool> updateProgress(
    String id, {
    required int currentSavings,
    required String status,
  }) async {
    final rows = await (update(goals)..where((g) => g.id.equals(id))).write(
      GoalsCompanion(
        currentSavings: Value(currentSavings),
        status: Value(status),
      ),
    );
    return rows > 0;
  }
}
