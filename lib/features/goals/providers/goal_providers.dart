import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/goal_dao.dart';
import '../../../core/providers/database_providers.dart';

/// Provides GoalDao from the database.
final goalDaoProvider = Provider<GoalDao>((ref) {
  return GoalDao(ref.watch(databaseProvider));
});

/// Streams all goals for [familyId].
final goalListProvider = StreamProvider.family<List<Goal>, String>((
  ref,
  familyId,
) {
  final dao = ref.watch(goalDaoProvider);
  return dao.watchAll(familyId);
});
