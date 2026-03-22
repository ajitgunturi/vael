import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/recurring_rule_dao.dart';
import '../../../core/providers/database_providers.dart';

final recurringRuleDaoProvider = Provider<RecurringRuleDao>((ref) {
  return RecurringRuleDao(ref.watch(databaseProvider));
});

final recurringRulesProvider =
    StreamProvider.family<List<RecurringRule>, String>((ref, familyId) {
      final dao = ref.watch(recurringRuleDaoProvider);
      return dao.watchAll(familyId);
    });
