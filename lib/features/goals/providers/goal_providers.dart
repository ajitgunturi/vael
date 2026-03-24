import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/goal_dao.dart';
import '../../../core/models/enums.dart';
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

/// Streams sinking fund goals for [familyId].
final sinkingFundGoalsProvider = StreamProvider.family<List<Goal>, String>((
  ref,
  familyId,
) {
  final dao = ref.watch(goalDaoProvider);
  return dao.watchByCategory(familyId, GoalCategory.sinkingFund.name);
});

/// Streams investment and retirement goals for [familyId].
final investmentGoalsProvider = StreamProvider.family<List<Goal>, String>((
  ref,
  familyId,
) {
  final dao = ref.watch(goalDaoProvider);
  return dao.watchByCategories(familyId, [
    GoalCategory.investmentGoal.name,
    GoalCategory.retirement.name,
  ]);
});

/// Streams purchase goals for [familyId].
final purchaseGoalsProvider = StreamProvider.family<List<Goal>, String>((
  ref,
  familyId,
) {
  final dao = ref.watch(goalDaoProvider);
  return dao.watchByCategory(familyId, GoalCategory.purchase.name);
});
