// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_group_dao.dart';

// ignore_for_file: type=lint
mixin _$CategoryGroupDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $CategoryGroupsTable get categoryGroups => attachedDatabase.categoryGroups;
  CategoryGroupDaoManager get managers => CategoryGroupDaoManager(this);
}

class CategoryGroupDaoManager {
  final _$CategoryGroupDaoMixin _db;
  CategoryGroupDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$CategoryGroupsTableTableManager get categoryGroups =>
      $$CategoryGroupsTableTableManager(
        _db.attachedDatabase,
        _db.categoryGroups,
      );
}
