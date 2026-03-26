import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/recurring_rules.dart';

part 'recurring_rule_dao.g.dart';

@DriftAccessor(tables: [RecurringRules])
class RecurringRuleDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringRuleDaoMixin {
  RecurringRuleDao(super.db);

  Future<List<RecurringRule>> getAll(String familyId) {
    return (select(
      recurringRules,
    )..where((r) => r.familyId.equals(familyId))).get();
  }

  Future<List<RecurringRule>> getActive(String familyId) {
    return (select(
          recurringRules,
        )..where((r) => r.familyId.equals(familyId) & r.isPaused.equals(false)))
        .get();
  }

  Future<RecurringRule?> getById(String id) {
    return (select(
      recurringRules,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  Stream<List<RecurringRule>> watchAll(String familyId) {
    return (select(
      recurringRules,
    )..where((r) => r.familyId.equals(familyId))).watch();
  }

  Future<int> insertRule(RecurringRulesCompanion entry) {
    return into(recurringRules).insert(entry);
  }

  Future<void> updateLastExecuted(String id, DateTime date) {
    return (update(recurringRules)..where((r) => r.id.equals(id))).write(
      RecurringRulesCompanion(lastExecutedDate: Value(date)),
    );
  }

  Future<void> pause(String id) {
    return (update(recurringRules)..where((r) => r.id.equals(id))).write(
      RecurringRulesCompanion(
        isPaused: const Value(true),
        pausedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> resume(String id) {
    return (update(recurringRules)..where((r) => r.id.equals(id))).write(
      const RecurringRulesCompanion(
        isPaused: Value(false),
        pausedAt: Value(null),
      ),
    );
  }

  Future<int> deleteRule(String id) {
    return (delete(recurringRules)..where((r) => r.id.equals(id))).go();
  }

  /// Watch secondary income rules for a user within a family.
  Stream<List<RecurringRule>> watchSecondaryIncome(
    String userId,
    String familyId,
  ) {
    return (select(recurringRules)..where(
          (r) =>
              r.userId.equals(userId) &
              r.familyId.equals(familyId) &
              r.isSecondaryIncome.equals(true) &
              r.deletedAt.isNull(),
        ))
        .watch();
  }
}
