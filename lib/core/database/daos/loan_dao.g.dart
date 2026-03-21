// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_dao.dart';

// ignore_for_file: type=lint
mixin _$LoanDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $UsersTable get users => attachedDatabase.users;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $LoanDetailsTable get loanDetails => attachedDatabase.loanDetails;
  LoanDaoManager get managers => LoanDaoManager(this);
}

class LoanDaoManager {
  final _$LoanDaoMixin _db;
  LoanDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$LoanDetailsTableTableManager get loanDetails =>
      $$LoanDetailsTableTableManager(_db.attachedDatabase, _db.loanDetails);
}
