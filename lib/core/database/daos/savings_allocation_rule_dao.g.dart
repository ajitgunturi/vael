// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_allocation_rule_dao.dart';

// ignore_for_file: type=lint
mixin _$SavingsAllocationRuleDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $SavingsAllocationRulesTable get savingsAllocationRules =>
      attachedDatabase.savingsAllocationRules;
  SavingsAllocationRuleDaoManager get managers =>
      SavingsAllocationRuleDaoManager(this);
}

class SavingsAllocationRuleDaoManager {
  final _$SavingsAllocationRuleDaoMixin _db;
  SavingsAllocationRuleDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$SavingsAllocationRulesTableTableManager get savingsAllocationRules =>
      $$SavingsAllocationRulesTableTableManager(
        _db.attachedDatabase,
        _db.savingsAllocationRules,
      );
}
