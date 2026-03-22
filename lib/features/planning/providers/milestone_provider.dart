import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/net_worth_milestone_dao.dart';
import '../../../core/financial/milestone_engine.dart';
import '../../../core/providers/database_providers.dart';
import 'life_profile_provider.dart';

/// Display-ready milestone item for the dashboard.
class MilestoneDisplayItem {
  final int age;
  final int targetAmountPaise;
  final int projectedAmountPaise;
  final MilestoneStatus status;
  final bool isCustomTarget;
  final bool isPast;
  final String? milestoneId;

  const MilestoneDisplayItem({
    required this.age,
    required this.targetAmountPaise,
    required this.projectedAmountPaise,
    required this.status,
    required this.isCustomTarget,
    required this.isPast,
    this.milestoneId,
  });
}

/// Returns the blended annual return rate based on risk profile string.
///
// TODO Phase 8 ALLOC-03: replace risk-profile lookup with holdings-weighted blended rate
double _returnRateForRiskProfile(String? riskProfile) {
  switch (riskProfile?.toUpperCase()) {
    case 'CONSERVATIVE':
      return 0.08; // 800bp
    case 'AGGRESSIVE':
      return 0.12; // 1200bp
    case 'MODERATE':
    default:
      return 0.10; // 1000bp
  }
}

/// Computes current age from date of birth.
int _ageFromDob(DateTime dob) {
  final now = DateTime.now();
  int age = now.year - dob.year;
  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
    age--;
  }
  return age;
}

const _decadeAges = [30, 40, 50, 60, 70];

/// Provider for the milestone DAO, derived from the database.
final netWorthMilestoneDaoProvider = Provider<NetWorthMilestoneDao>((ref) {
  return NetWorthMilestoneDao(ref.watch(databaseProvider));
});

/// Watches computed milestone display items for a user.
///
/// Returns empty list when no life profile exists (screen shows EmptyState).
/// Combines life profile data with custom targets from the DAO.
final milestoneListProvider =
    StreamProvider.family<
      List<MilestoneDisplayItem>,
      ({String userId, String familyId})
    >((ref, params) {
      final profileAsync = ref.watch(
        lifeProfileProvider((userId: params.userId, familyId: params.familyId)),
      );

      final LifeProfile? profile = profileAsync.value;

      if (profile == null) {
        return Stream.value(<MilestoneDisplayItem>[]);
      }

      final db = ref.watch(databaseProvider);
      final dao = NetWorthMilestoneDao(db);

      final currentAge = _ageFromDob(profile.dateOfBirth);
      final annualReturnRate = _returnRateForRiskProfile(profile.riskProfile);

      // Default current NW and monthly savings (no account data wired yet).
      const currentNwPaise = 0;
      const monthlySavingsPaise = 0;

      return dao.watchForUser(params.userId, params.familyId).map((
        customTargets,
      ) {
        final customByAge = <int, NetWorthMilestone>{};
        for (final m in customTargets) {
          customByAge[m.targetAge] = m;
        }

        return _decadeAges.map((age) {
          final projected = MilestoneEngine.projectNetWorthAtAge(
            currentNwPaise: currentNwPaise,
            currentAge: currentAge,
            targetAge: age,
            monthlySavingsPaise: monthlySavingsPaise,
            annualReturnRate: annualReturnRate,
          );

          final custom = customByAge[age];
          final targetAmount = custom != null && custom.isCustomTarget
              ? custom.targetAmountPaise
              : projected;

          final status = MilestoneEngine.determineStatus(
            currentAge: currentAge,
            milestoneAge: age,
            targetAmountPaise: targetAmount,
            actualOrProjectedPaise: projected,
          );

          return MilestoneDisplayItem(
            age: age,
            targetAmountPaise: targetAmount,
            projectedAmountPaise: projected,
            status: status,
            isCustomTarget: custom?.isCustomTarget ?? false,
            isPast: currentAge >= age,
            milestoneId: custom?.id,
          );
        }).toList();
      });
    });
