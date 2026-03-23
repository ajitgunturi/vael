// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_target_dao.dart';

// ignore_for_file: type=lint
mixin _$AllocationTargetDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $LifeProfilesTable get lifeProfiles => attachedDatabase.lifeProfiles;
  $AllocationTargetsTable get allocationTargets =>
      attachedDatabase.allocationTargets;
  AllocationTargetDaoManager get managers => AllocationTargetDaoManager(this);
}

class AllocationTargetDaoManager {
  final _$AllocationTargetDaoMixin _db;
  AllocationTargetDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$LifeProfilesTableTableManager get lifeProfiles =>
      $$LifeProfilesTableTableManager(_db.attachedDatabase, _db.lifeProfiles);
  $$AllocationTargetsTableTableManager get allocationTargets =>
      $$AllocationTargetsTableTableManager(
        _db.attachedDatabase,
        _db.allocationTargets,
      );
}
