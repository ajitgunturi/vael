import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/allocation_targets.dart';

part 'allocation_target_dao.g.dart';

@DriftAccessor(tables: [AllocationTargets])
class AllocationTargetDao extends DatabaseAccessor<AppDatabase>
    with _$AllocationTargetDaoMixin {
  AllocationTargetDao(super.db);

  /// Watches all allocation targets for a life profile.
  Stream<List<AllocationTarget>> watchForProfile(String lifeProfileId) =>
      (select(
        allocationTargets,
      )..where((t) => t.lifeProfileId.equals(lifeProfileId))).watch();

  /// Gets all allocation targets for a life profile.
  Future<List<AllocationTarget>> getForProfile(String lifeProfileId) => (select(
    allocationTargets,
  )..where((t) => t.lifeProfileId.equals(lifeProfileId))).get();

  /// Inserts or updates an allocation target (upsert on primary key).
  Future<void> upsertTarget(AllocationTargetsCompanion target) =>
      into(allocationTargets).insertOnConflictUpdate(target);

  /// Atomically replaces all targets for a life profile.
  Future<void> replaceAllForProfile(
    String lifeProfileId,
    List<AllocationTargetsCompanion> targets,
  ) async {
    await transaction(() async {
      await (delete(
        allocationTargets,
      )..where((t) => t.lifeProfileId.equals(lifeProfileId))).go();
      for (final t in targets) {
        await into(allocationTargets).insert(t);
      }
    });
  }
}
