// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_dao.dart';

// ignore_for_file: type=lint
mixin _$BudgetDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $BudgetsTable get budgets => attachedDatabase.budgets;
  BudgetDaoManager get managers => BudgetDaoManager(this);
}

class BudgetDaoManager {
  final _$BudgetDaoMixin _db;
  BudgetDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db.attachedDatabase, _db.budgets);
}
