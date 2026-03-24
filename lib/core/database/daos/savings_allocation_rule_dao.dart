import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/savings_allocation_rules.dart';

part 'savings_allocation_rule_dao.g.dart';

@DriftAccessor(tables: [SavingsAllocationRules])
class SavingsAllocationRuleDao extends DatabaseAccessor<AppDatabase>
    with _$SavingsAllocationRuleDaoMixin {
  SavingsAllocationRuleDao(super.db);

  /// Watch all active rules for family, sorted by priority ascending.
  Stream<List<SavingsAllocationRule>> watchByFamily(String familyId) =>
      (select(savingsAllocationRules)
            ..where(
              (r) =>
                  r.familyId.equals(familyId) &
                  r.isActive.equals(true) &
                  r.deletedAt.isNull(),
            )
            ..orderBy([(r) => OrderingTerm.asc(r.priority)]))
          .watch();

  /// Get all active rules for family, sorted by priority ascending.
  Future<List<SavingsAllocationRule>> getByFamily(String familyId) =>
      (select(savingsAllocationRules)
            ..where(
              (r) =>
                  r.familyId.equals(familyId) &
                  r.isActive.equals(true) &
                  r.deletedAt.isNull(),
            )
            ..orderBy([(r) => OrderingTerm.asc(r.priority)]))
          .get();

  /// Insert a new rule.
  Future<void> insertRule(SavingsAllocationRulesCompanion rule) =>
      into(savingsAllocationRules).insert(rule);

  /// Update a rule.
  Future<void> updateRule(SavingsAllocationRulesCompanion rule) => (update(
    savingsAllocationRules,
  )..where((r) => r.id.equals(rule.id.value))).write(rule);

  /// Soft-delete a rule.
  Future<void> softDelete(String id) =>
      (update(savingsAllocationRules)..where((r) => r.id.equals(id))).write(
        SavingsAllocationRulesCompanion(deletedAt: Value(DateTime.now())),
      );

  /// Reorder all rules atomically: updates priority = index + 1 for each id.
  Future<void> reorderPriorities(
    String familyId,
    List<String> orderedIds,
  ) async {
    await transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (update(savingsAllocationRules)
              ..where((r) => r.id.equals(orderedIds[i])))
            .write(SavingsAllocationRulesCompanion(priority: Value(i + 1)));
      }
    });
  }
}
