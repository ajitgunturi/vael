import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/life_profile_dao.dart';
import '../../../core/providers/database_providers.dart';

/// Watches the life profile for a specific user within a family.
/// Returns null when no profile exists yet (new user / not set up).
final lifeProfileProvider =
    StreamProvider.family<LifeProfile?, ({String userId, String familyId})>((
      ref,
      params,
    ) {
      final db = ref.watch(databaseProvider);
      final dao = LifeProfileDao(db);
      return dao.watchForUser(params.userId, params.familyId);
    });

/// Watches all active life profiles for a family (combined family view).
final familyProfilesProvider = StreamProvider.family<List<LifeProfile>, String>(
  (ref, familyId) {
    final db = ref.watch(databaseProvider);
    final dao = LifeProfileDao(db);
    return dao.watchAll(familyId);
  },
);

/// Derives a [LifeProfileDao] from the database provider.
final lifeProfileDaoProvider = Provider<LifeProfileDao>((ref) {
  return LifeProfileDao(ref.watch(databaseProvider));
});
