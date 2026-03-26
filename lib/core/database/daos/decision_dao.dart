import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/decisions.dart';

part 'decision_dao.g.dart';

@DriftAccessor(tables: [Decisions])
class DecisionDao extends DatabaseAccessor<AppDatabase>
    with _$DecisionDaoMixin {
  DecisionDao(super.db);

  /// Watches all non-deleted decisions for a user within a family,
  /// ordered by most recent first.
  Stream<List<Decision>> watchForUser(String userId, String familyId) =>
      (select(decisions)
            ..where(
              (d) =>
                  d.userId.equals(userId) &
                  d.familyId.equals(familyId) &
                  d.deletedAt.isNull(),
            )
            ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
          .watch();

  /// Gets a single decision by id (or null).
  Future<Decision?> getById(String id) =>
      (select(decisions)..where((d) => d.id.equals(id))).getSingleOrNull();

  /// Inserts a new decision.
  Future<void> insertDecision(DecisionsCompanion decision) =>
      into(decisions).insert(decision);

  /// Marks a decision as implemented with current timestamp.
  Future<void> markImplemented(String id) =>
      (update(decisions)..where((d) => d.id.equals(id))).write(
        DecisionsCompanion(
          status: const Value('implemented'),
          implementedAt: Value(DateTime.now()),
        ),
      );

  /// Soft-deletes a decision by setting deletedAt.
  Future<void> softDelete(String id) =>
      (update(decisions)..where((d) => d.id.equals(id))).write(
        DecisionsCompanion(deletedAt: Value(DateTime.now())),
      );
}
