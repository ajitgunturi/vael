// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_snapshot_dao.dart';

// ignore_for_file: type=lint
mixin _$BalanceSnapshotDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $UsersTable get users => attachedDatabase.users;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $BalanceSnapshotsTable get balanceSnapshots =>
      attachedDatabase.balanceSnapshots;
  BalanceSnapshotDaoManager get managers => BalanceSnapshotDaoManager(this);
}

class BalanceSnapshotDaoManager {
  final _$BalanceSnapshotDaoMixin _db;
  BalanceSnapshotDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$BalanceSnapshotsTableTableManager get balanceSnapshots =>
      $$BalanceSnapshotsTableTableManager(
        _db.attachedDatabase,
        _db.balanceSnapshots,
      );
}
