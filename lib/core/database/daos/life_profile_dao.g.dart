// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'life_profile_dao.dart';

// ignore_for_file: type=lint
mixin _$LifeProfileDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $LifeProfilesTable get lifeProfiles => attachedDatabase.lifeProfiles;
  LifeProfileDaoManager get managers => LifeProfileDaoManager(this);
}

class LifeProfileDaoManager {
  final _$LifeProfileDaoMixin _db;
  LifeProfileDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$LifeProfilesTableTableManager get lifeProfiles =>
      $$LifeProfilesTableTableManager(_db.attachedDatabase, _db.lifeProfiles);
}
