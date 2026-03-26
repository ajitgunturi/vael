// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_worth_milestone_dao.dart';

// ignore_for_file: type=lint
mixin _$NetWorthMilestoneDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $LifeProfilesTable get lifeProfiles => attachedDatabase.lifeProfiles;
  $NetWorthMilestonesTable get netWorthMilestones =>
      attachedDatabase.netWorthMilestones;
  NetWorthMilestoneDaoManager get managers => NetWorthMilestoneDaoManager(this);
}

class NetWorthMilestoneDaoManager {
  final _$NetWorthMilestoneDaoMixin _db;
  NetWorthMilestoneDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$LifeProfilesTableTableManager get lifeProfiles =>
      $$LifeProfilesTableTableManager(_db.attachedDatabase, _db.lifeProfiles);
  $$NetWorthMilestonesTableTableManager get netWorthMilestones =>
      $$NetWorthMilestonesTableTableManager(
        _db.attachedDatabase,
        _db.netWorthMilestones,
      );
}
