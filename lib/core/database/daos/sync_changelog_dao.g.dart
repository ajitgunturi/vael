// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_changelog_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncChangelogDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncChangelogTable get syncChangelog => attachedDatabase.syncChangelog;
  SyncChangelogDaoManager get managers => SyncChangelogDaoManager(this);
}

class SyncChangelogDaoManager {
  final _$SyncChangelogDaoMixin _db;
  SyncChangelogDaoManager(this._db);
  $$SyncChangelogTableTableManager get syncChangelog =>
      $$SyncChangelogTableTableManager(_db.attachedDatabase, _db.syncChangelog);
}
