import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart' as db;
import '../../../core/database/daos/allocation_target_dao.dart';
import '../../../core/database/daos/investment_holding_dao.dart';
import '../../../core/financial/allocation_engine.dart';
import '../../../core/models/enums.dart';
import '../../../core/providers/database_providers.dart';

/// Derives an [InvestmentHoldingDao] from the database.
final investmentHoldingDaoProvider = Provider<InvestmentHoldingDao>((ref) {
  return InvestmentHoldingDao(ref.watch(databaseProvider));
});

/// Derives an [AllocationTargetDao] from the database.
final allocationTargetDaoProvider = Provider<AllocationTargetDao>((ref) {
  return AllocationTargetDao(ref.watch(databaseProvider));
});

/// Watches the current portfolio allocation by asset class.
///
/// Computes allocation from investment holdings using [AllocationEngine].
final currentAllocationProvider =
    StreamProvider.family<
      Map<AssetClass, int>,
      ({String familyId, int userAge})
    >((ref, params) {
      final dao = ref.watch(investmentHoldingDaoProvider);
      return dao.watchAll(params.familyId).map((holdings) {
        final inputs = holdings
            .map(
              (h) => HoldingInput(
                bucketType: h.bucketType,
                currentValuePaise: h.currentValue,
              ),
            )
            .toList();
        return AllocationEngine.currentAllocation(inputs, params.userAge);
      });
    });

/// Computes the target allocation for a given age and risk profile.
///
/// Synchronous provider -- delegates to [AllocationEngine.targetForAge].
final targetAllocationProvider =
    Provider.family<
      AllocationTarget,
      ({
        int age,
        String riskProfile,
        List<AllocationTargetOverride>? customTargets,
      })
    >((ref, params) {
      return AllocationEngine.targetForAge(
        age: params.age,
        riskProfile: params.riskProfile,
        customTargets: params.customTargets,
      );
    });

/// Watches custom allocation target overrides from the DAO for a life profile.
///
/// Returns the raw drift [db.AllocationTarget] rows. Callers convert to
/// engine [AllocationTargetOverride] as needed.
final customAllocationTargetsProvider =
    StreamProvider.family<List<db.AllocationTarget>, String>((
      ref,
      lifeProfileId,
    ) {
      final dao = ref.watch(allocationTargetDaoProvider);
      return dao.watchForProfile(lifeProfileId);
    });

/// Computes rebalancing deltas from current vs target allocation.
///
/// Requires both current allocation (by asset class) and target allocation.
final rebalancingDeltasProvider =
    Provider.family<
      List<RebalancingDelta>,
      ({Map<AssetClass, int> currentValuePaise, AllocationTarget target})
    >((ref, params) {
      return AllocationEngine.rebalancingDeltas(
        currentValuePaise: params.currentValuePaise,
        target: params.target,
      );
    });
