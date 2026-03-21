import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/accounts.dart';

part 'account_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  AccountDao(super.db);

  /// Returns all non-deleted accounts belonging to [familyId].
  Future<List<Account>> getAll(String familyId) {
    return (select(accounts)
          ..where((a) =>
              a.familyId.equals(familyId) & a.deletedAt.isNull()))
        .get();
  }

  /// Returns a single account by [id] if it belongs to [familyId] and is not
  /// soft-deleted. Returns `null` otherwise.
  Future<Account?> getById(String id, String familyId) {
    return (select(accounts)
          ..where((a) =>
              a.id.equals(id) &
              a.familyId.equals(familyId) &
              a.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Returns all non-deleted accounts of the given [type] within [familyId].
  Future<List<Account>> getByType(String familyId, String type) {
    return (select(accounts)
          ..where((a) =>
              a.familyId.equals(familyId) &
              a.type.equals(type) &
              a.deletedAt.isNull()))
        .get();
  }

  /// Watches all non-deleted accounts belonging to [familyId].
  /// Re-emits whenever the accounts table changes.
  Stream<List<Account>> watchAll(String familyId) {
    return (select(accounts)
          ..where((a) =>
              a.familyId.equals(familyId) & a.deletedAt.isNull()))
        .watch();
  }

  /// Inserts a new account row.
  Future<int> insertAccount(AccountsCompanion entry) {
    return into(accounts).insert(entry);
  }

  /// Marks an account as deleted by setting [deletedAt] to now.
  Future<void> softDelete(String id) {
    return (update(accounts)..where((a) => a.id.equals(id)))
        .write(AccountsCompanion(deletedAt: Value(DateTime.now())));
  }
}
