// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_dao.dart';

// ignore_for_file: type=lint
mixin _$DecisionDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $DecisionsTable get decisions => attachedDatabase.decisions;
  DecisionDaoManager get managers => DecisionDaoManager(this);
}

class DecisionDaoManager {
  final _$DecisionDaoMixin _db;
  DecisionDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$DecisionsTableTableManager get decisions =>
      $$DecisionsTableTableManager(_db.attachedDatabase, _db.decisions);
}
