import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/transactions.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  /// Returns all transactions for [familyId], ordered by date descending.
  Future<List<Transaction>> getAll(String familyId) {
    return (select(transactions)
          ..where((t) => t.familyId.equals(familyId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Returns transactions within the inclusive date range [start]..[end].
  Future<List<Transaction>> getByDateRange(
    String familyId,
    DateTime start,
    DateTime end,
  ) {
    return (select(transactions)
          ..where((t) =>
              t.familyId.equals(familyId) &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Returns transactions of a specific [kind] within [familyId].
  Future<List<Transaction>> getByKind(String familyId, String kind) {
    return (select(transactions)
          ..where(
              (t) => t.familyId.equals(familyId) & t.kind.equals(kind))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Returns transactions for a specific [accountId] within [familyId].
  Future<List<Transaction>> getByAccount(String familyId, String accountId) {
    return (select(transactions)
          ..where((t) =>
              t.familyId.equals(familyId) &
              t.accountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Inserts a new transaction row.
  Future<int> insertTransaction(TransactionsCompanion entry) {
    return into(transactions).insert(entry);
  }
}
