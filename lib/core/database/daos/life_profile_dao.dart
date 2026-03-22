import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/life_profiles.dart';

part 'life_profile_dao.g.dart';

@DriftAccessor(tables: [LifeProfiles])
class LifeProfileDao extends DatabaseAccessor<AppDatabase>
    with _$LifeProfileDaoMixin {
  LifeProfileDao(super.db);

  /// Watches the life profile for a specific user within a family.
  Stream<LifeProfile?> watchForUser(String userId, String familyId) =>
      (select(lifeProfiles)..where(
            (p) =>
                p.userId.equals(userId) &
                p.familyId.equals(familyId) &
                p.deletedAt.isNull(),
          ))
          .watchSingleOrNull();

  /// Watches all active profiles for a family.
  Stream<List<LifeProfile>> watchAll(String familyId) => (select(
    lifeProfiles,
  )..where((p) => p.familyId.equals(familyId) & p.deletedAt.isNull())).watch();

  /// Gets the life profile for a specific user within a family.
  Future<LifeProfile?> getForUser(String userId, String familyId) =>
      (select(lifeProfiles)..where(
            (p) =>
                p.userId.equals(userId) &
                p.familyId.equals(familyId) &
                p.deletedAt.isNull(),
          ))
          .getSingleOrNull();

  /// Inserts or updates a life profile (upsert on primary key).
  Future<int> upsertProfile(LifeProfilesCompanion entry) =>
      into(lifeProfiles).insertOnConflictUpdate(entry);

  /// Soft-deletes a life profile by setting deletedAt.
  Future<int> softDelete(String id) =>
      (update(lifeProfiles)..where((p) => p.id.equals(id))).write(
        LifeProfilesCompanion(deletedAt: Value(DateTime.now())),
      );
}
