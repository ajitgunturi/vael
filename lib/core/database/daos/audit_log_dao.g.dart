// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_dao.dart';

// ignore_for_file: type=lint
mixin _$AuditLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $AuditLogTable get auditLog => attachedDatabase.auditLog;
  AuditLogDaoManager get managers => AuditLogDaoManager(this);
}

class AuditLogDaoManager {
  final _$AuditLogDaoMixin _db;
  AuditLogDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$AuditLogTableTableManager get auditLog =>
      $$AuditLogTableTableManager(_db.attachedDatabase, _db.auditLog);
}
