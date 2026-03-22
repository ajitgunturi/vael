import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/audit_log.dart';

part 'audit_log_dao.g.dart';

@DriftAccessor(tables: [AuditLog])
class AuditLogDao extends DatabaseAccessor<AppDatabase>
    with _$AuditLogDaoMixin {
  AuditLogDao(super.db);

  /// Appends an immutable audit entry.
  Future<int> insertEntry(AuditLogCompanion entry) {
    return into(auditLog).insert(entry);
  }

  /// Returns all audit entries for a family, newest first.
  Future<List<AuditLogData>> getByFamily(String familyId) {
    return (select(auditLog)
          ..where((a) => a.familyId.equals(familyId))
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
        .get();
  }

  /// Returns audit entries for a specific entity.
  Future<List<AuditLogData>> getByEntity(String entityType, String entityId) {
    return (select(auditLog)
          ..where(
            (a) =>
                a.entityType.equals(entityType) & a.entityId.equals(entityId),
          )
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
        .get();
  }

  /// Returns count of audit entries for a family.
  Future<int> countByFamily(String familyId) async {
    final count = auditLog.id.count();
    final query = selectOnly(auditLog)
      ..addColumns([count])
      ..where(auditLog.familyId.equals(familyId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
