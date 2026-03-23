import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/goal_dao.dart';
import '../../../core/financial/purchase_planner.dart';
import '../../../core/providers/database_providers.dart';

/// Derives a [GoalDao] from the database.
final goalDaoProvider = Provider<GoalDao>((ref) {
  return GoalDao(ref.watch(databaseProvider));
});

/// Watches purchase goals (goalCategory == 'purchase') for a family.
///
/// Returns goals ordered by priority ascending.
final purchaseGoalsProvider = StreamProvider.family<List<Goal>, String>((
  ref,
  familyId,
) {
  final dao = ref.watch(goalDaoProvider);
  return dao.watchByCategory(familyId, 'purchase');
});

/// Computes purchase impact for a given set of parameters.
///
/// Synchronous provider -- delegates to [PurchasePlannerEngine.computeImpact].
final purchaseImpactProvider =
    Provider.family<
      PurchaseImpact,
      ({
        int purchaseAmountPaise,
        int downPaymentBp,
        int currentPortfolioPaise,
        int monthlySavingsPaise,
        int annualExpensesPaise,
        double annualReturnRate,
        double swr,
        double inflationRate,
        int yearsToRetirement,
        int? loanTenureMonths,
        double? loanInterestRate,
      })
    >((ref, params) {
      return PurchasePlannerEngine.computeImpact(
        purchaseAmountPaise: params.purchaseAmountPaise,
        downPaymentBp: params.downPaymentBp,
        currentPortfolioPaise: params.currentPortfolioPaise,
        monthlySavingsPaise: params.monthlySavingsPaise,
        annualExpensesPaise: params.annualExpensesPaise,
        annualReturnRate: params.annualReturnRate,
        swr: params.swr,
        inflationRate: params.inflationRate,
        yearsToRetirement: params.yearsToRetirement,
        loanTenureMonths: params.loanTenureMonths,
        loanInterestRate: params.loanInterestRate,
      );
    });
