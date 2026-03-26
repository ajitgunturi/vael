import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/net_worth_milestones.dart';

part 'net_worth_milestone_dao.g.dart';

@DriftAccessor(tables: [NetWorthMilestones])
class NetWorthMilestoneDao extends DatabaseAccessor<AppDatabase>
    with _$NetWorthMilestoneDaoMixin {
  NetWorthMilestoneDao(super.db);

  /// Watches milestones for a user within a family, ordered by target age.
  Stream<List<NetWorthMilestone>> watchForUser(
    String userId,
    String familyId,
  ) =>
      (select(netWorthMilestones)
            ..where(
              (m) =>
                  m.userId.equals(userId) &
                  m.familyId.equals(familyId) &
                  m.deletedAt.isNull(),
            )
            ..orderBy([(m) => OrderingTerm.asc(m.targetAge)]))
          .watch();

  /// Gets all milestones for a user within a family.
  Future<List<NetWorthMilestone>> getForUser(String userId, String familyId) =>
      (select(netWorthMilestones)
            ..where(
              (m) =>
                  m.userId.equals(userId) &
                  m.familyId.equals(familyId) &
                  m.deletedAt.isNull(),
            )
            ..orderBy([(m) => OrderingTerm.asc(m.targetAge)]))
          .get();

  /// Gets a single milestone by user, family, and target age (or null).
  Future<NetWorthMilestone?> getByAge(
    String userId,
    String familyId,
    int targetAge,
  ) =>
      (select(netWorthMilestones)..where(
            (m) =>
                m.userId.equals(userId) &
                m.familyId.equals(familyId) &
                m.targetAge.equals(targetAge) &
                m.deletedAt.isNull(),
          ))
          .getSingleOrNull();

  /// Inserts or updates a milestone (upsert on primary key).
  Future<int> upsertMilestone(NetWorthMilestonesCompanion entry) =>
      into(netWorthMilestones).insertOnConflictUpdate(entry);

  /// Soft-deletes a milestone by setting deletedAt.
  Future<int> softDelete(String id) =>
      (update(netWorthMilestones)..where((m) => m.id.equals(id))).write(
        NetWorthMilestonesCompanion(deletedAt: Value(DateTime.now())),
      );
}
