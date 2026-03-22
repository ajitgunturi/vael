import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../database/daos/account_dao.dart';
import '../database/daos/balance_snapshot_dao.dart';

/// Creates daily balance snapshots for all accounts in a family.
///
/// Should be called once per app foreground session. Checks if a snapshot
/// already exists for today before creating duplicates.
class BalanceSnapshotScheduler {
  final AccountDao _accountDao;
  final BalanceSnapshotDao _snapshotDao;

  BalanceSnapshotScheduler({
    required AccountDao accountDao,
    required BalanceSnapshotDao snapshotDao,
  }) : _accountDao = accountDao,
       _snapshotDao = snapshotDao;

  /// Creates snapshots for all accounts in [familyId] if none exist for today.
  Future<int> createDailySnapshots(String familyId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Check if snapshots already exist for today
    final existing = await _snapshotDao.getByFamilyDateRange(
      familyId,
      startOfDay,
      endOfDay,
    );
    if (existing.isNotEmpty) return 0;

    // Get all active accounts
    final accounts = await _accountDao.getAll(familyId);
    const uuid = Uuid();
    var count = 0;

    for (final account in accounts) {
      if (account.deletedAt != null) continue;

      await _snapshotDao.insertSnapshot(
        BalanceSnapshotsCompanion.insert(
          id: uuid.v4(),
          accountId: account.id,
          snapshotDate: startOfDay,
          balance: account.balance,
          familyId: familyId,
        ),
      );
      count++;
    }

    return count;
  }
}
