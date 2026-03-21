// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_holding_dao.dart';

// ignore_for_file: type=lint
mixin _$InvestmentHoldingDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $UsersTable get users => attachedDatabase.users;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $GoalsTable get goals => attachedDatabase.goals;
  $InvestmentHoldingsTable get investmentHoldings =>
      attachedDatabase.investmentHoldings;
  InvestmentHoldingDaoManager get managers => InvestmentHoldingDaoManager(this);
}

class InvestmentHoldingDaoManager {
  final _$InvestmentHoldingDaoMixin _db;
  InvestmentHoldingDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db.attachedDatabase, _db.goals);
  $$InvestmentHoldingsTableTableManager get investmentHoldings =>
      $$InvestmentHoldingsTableTableManager(
        _db.attachedDatabase,
        _db.investmentHoldings,
      );
}
