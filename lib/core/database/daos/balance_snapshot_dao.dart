import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/balance_snapshots.dart';

part 'balance_snapshot_dao.g.dart';

@DriftAccessor(tables: [BalanceSnapshots])
class BalanceSnapshotDao extends DatabaseAccessor<AppDatabase>
    with _$BalanceSnapshotDaoMixin {
  BalanceSnapshotDao(super.db);

  /// Inserts a new balance snapshot.
  Future<int> insertSnapshot(BalanceSnapshotsCompanion entry) {
    return into(balanceSnapshots).insert(entry);
  }

  /// Returns all snapshots for an account, ordered by date.
  Future<List<BalanceSnapshot>> getByAccount(String accountId) {
    return (select(balanceSnapshots)
          ..where((s) => s.accountId.equals(accountId))
          ..orderBy([(s) => OrderingTerm.asc(s.snapshotDate)]))
        .get();
  }

  /// Returns all snapshots for a family within a date range, ordered by date.
  Future<List<BalanceSnapshot>> getByFamilyDateRange(
    String familyId,
    DateTime start,
    DateTime end,
  ) {
    return (select(balanceSnapshots)
          ..where(
            (s) =>
                s.familyId.equals(familyId) &
                s.snapshotDate.isBiggerOrEqualValue(start) &
                s.snapshotDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.snapshotDate)]))
        .get();
  }

  /// Returns the latest snapshot per account for a given family.
  Future<List<BalanceSnapshot>> getLatestPerAccount(String familyId) {
    return (select(balanceSnapshots)
          ..where((s) => s.familyId.equals(familyId))
          ..orderBy([(s) => OrderingTerm.desc(s.snapshotDate)]))
        .get();
  }
}
