import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/budgets.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  /// Returns all budgets for [familyId] in the given [year]/[month].
  Future<List<Budget>> getForMonth(String familyId, int year, int month) {
    return (select(budgets)
          ..where((b) =>
              b.familyId.equals(familyId) &
              b.year.equals(year) &
              b.month.equals(month)))
        .get();
  }

  /// Watches budgets for [familyId] in the given [year]/[month].
  Stream<List<Budget>> watchForMonth(String familyId, int year, int month) {
    return (select(budgets)
          ..where((b) =>
              b.familyId.equals(familyId) &
              b.year.equals(year) &
              b.month.equals(month)))
        .watch();
  }

  /// Inserts a new budget row.
  Future<int> insertBudget(BudgetsCompanion entry) {
    return into(budgets).insert(entry);
  }

  /// Updates the limit for an existing budget row.
  Future<int> updateLimit(String id, int newLimit) {
    return (update(budgets)..where((b) => b.id.equals(id)))
        .write(BudgetsCompanion(limitAmount: Value(newLimit)));
  }

  /// Deletes a budget by [id].
  Future<int> deleteBudget(String id) {
    return (delete(budgets)..where((b) => b.id.equals(id))).go();
  }
}
