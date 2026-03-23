import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/decision_dao.dart';
import '../../../core/financial/decision_modeler.dart';
import '../../../core/models/enums.dart';
import '../../../core/providers/database_providers.dart';

/// Derives a [DecisionDao] from the database.
final decisionDaoProvider = Provider<DecisionDao>((ref) {
  return DecisionDao(ref.watch(databaseProvider));
});

/// Watches all non-deleted decisions for a user within a family.
///
/// Ordered by most recent first.
final decisionsProvider =
    StreamProvider.family<List<Decision>, ({String userId, String familyId})>((
      ref,
      params,
    ) {
      final dao = ref.watch(decisionDaoProvider);
      return dao.watchForUser(params.userId, params.familyId);
    });

/// Computes the impact of a financial decision synchronously.
///
/// Delegates to [DecisionModelerEngine.computeImpact].
final decisionImpactProvider =
    Provider.family<
      DecisionImpact,
      ({
        DecisionType type,
        DecisionParameters params,
        int currentAge,
        int retirementAge,
        int currentPortfolioPaise,
        int monthlySavingsPaise,
        int annualExpensesPaise,
        int currentMonthlySalaryPaise,
        double swr,
        double inflationRate,
        double annualReturnRate,
      })
    >((ref, p) {
      return DecisionModelerEngine.computeImpact(
        type: p.type,
        params: p.params,
        currentAge: p.currentAge,
        retirementAge: p.retirementAge,
        currentPortfolioPaise: p.currentPortfolioPaise,
        monthlySavingsPaise: p.monthlySavingsPaise,
        annualExpensesPaise: p.annualExpensesPaise,
        currentMonthlySalaryPaise: p.currentMonthlySalaryPaise,
        swr: p.swr,
        inflationRate: p.inflationRate,
        annualReturnRate: p.annualReturnRate,
      );
    });
