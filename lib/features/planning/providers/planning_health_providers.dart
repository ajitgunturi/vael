import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/financial/fi_calculator.dart';
import '../../../core/financial/milestone_engine.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import 'emergency_fund_provider.dart';
import 'fi_calculator_provider.dart';
import 'milestone_provider.dart';

// ---------------------------------------------------------------------------
// Data class
// ---------------------------------------------------------------------------

/// Aggregated financial health snapshot for the planning dashboard.
///
/// Each metric is nullable: null means the source feature is not yet
/// configured, which the UI renders as a "Set up" CTA.
class PlanningHealthData {
  /// Net worth in paise (always available when dashboard data exists).
  final int? netWorthPaise;

  /// Current month savings rate as a percentage (0-100+).
  final double? savingsRatePercent;

  /// Emergency fund coverage in months.
  final double? efCoverageMonths;

  /// Emergency fund target in months.
  final int? efTargetMonths;

  /// FI progress as a percentage (currentPortfolio / fiNumber * 100).
  final double? fiProgressPercent;

  /// Estimated years to reach financial independence.
  final int? yearsToFi;

  /// Count of milestones with status onTrack, ahead, or reached.
  final int? milestoneOnTrackCount;

  /// Total number of milestones.
  final int? milestoneTotalCount;

  /// Whether the user has a life profile configured.
  final bool hasLifeProfile;

  /// Whether the user has an emergency fund set up.
  final bool hasEmergencyFund;

  const PlanningHealthData({
    this.netWorthPaise,
    this.savingsRatePercent,
    this.efCoverageMonths,
    this.efTargetMonths,
    this.fiProgressPercent,
    this.yearsToFi,
    this.milestoneOnTrackCount,
    this.milestoneTotalCount,
    this.hasLifeProfile = false,
    this.hasEmergencyFund = false,
  });
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Aggregates all 5 financial health metrics into a single reactive model.
///
/// Watches existing providers for dashboard data, FI inputs, milestones,
/// and emergency fund state. Returns [PlanningHealthData] with null metrics
/// for unconfigured features.
final planningHealthProvider =
    FutureProvider.family<
      PlanningHealthData,
      ({String familyId, String userId})
    >((ref, params) async {
      // --- Net Worth & Savings Rate (from dashboard stream) ---
      int? netWorthPaise;
      double? savingsRatePercent;

      final dashAsync = ref.watch(dashboardDataProvider(params.familyId));
      final dashData = dashAsync.value;
      if (dashData != null) {
        netWorthPaise = dashData.netWorth;
        savingsRatePercent = dashData.savingsRate;
      }

      // --- FI Inputs ---
      final fiInputs = ref.watch(
        fiDefaultInputsProvider((
          userId: params.userId,
          familyId: params.familyId,
        )),
      );
      final hasLifeProfile = fiInputs.hasLifeProfile;

      // --- FI Progress & Years to FI ---
      double? fiProgressPercent;
      int? yearsToFiValue;

      if (hasLifeProfile) {
        final annualExpenses = fiInputs.monthlyExpensesPaise * 12;
        final swr = fiInputs.swrBp / 10000;
        final inflation = fiInputs.inflationBp / 10000;
        final yearsToRetirement = fiInputs.retirementAge - fiInputs.currentAge;
        final returnRate = fiInputs.returnsBp / 10000;

        final fiNumber = FiCalculator.computeFiNumber(
          annualExpensesPaise: annualExpenses,
          swr: swr,
          inflationRate: inflation,
          yearsToRetirement: yearsToRetirement,
        );

        if (fiNumber > 0) {
          fiProgressPercent = (fiInputs.currentPortfolioPaise / fiNumber) * 100;
        }

        yearsToFiValue = FiCalculator.yearsToFi(
          currentPortfolioPaise: fiInputs.currentPortfolioPaise,
          monthlySavingsPaise: fiInputs.monthlySavingsPaise,
          annualReturnRate: returnRate,
          fiNumberPaise: fiNumber,
        );

        // -1 means unreachable; represent as null
        if (yearsToFiValue == -1) yearsToFiValue = null;
      }

      // --- Milestones ---
      int? milestoneOnTrackCount;
      int? milestoneTotalCount;

      if (hasLifeProfile) {
        final milestonesAsync = ref.watch(
          milestoneListProvider((
            userId: params.userId,
            familyId: params.familyId,
          )),
        );
        final milestones = milestonesAsync.value;
        if (milestones != null && milestones.isNotEmpty) {
          milestoneTotalCount = milestones.length;
          milestoneOnTrackCount = milestones
              .where(
                (m) =>
                    m.status == MilestoneStatus.onTrack ||
                    m.status == MilestoneStatus.ahead ||
                    m.status == MilestoneStatus.reached,
              )
              .length;
        }
      }

      // --- Emergency Fund ---
      double? efCoverageMonths;
      int? efTargetMonths;
      bool hasEmergencyFund = false;

      final efAsync = ref.watch(
        emergencyFundStateProvider((
          userId: params.userId,
          familyId: params.familyId,
        )),
      );
      final efState = efAsync.value;
      if (efState != null) {
        hasEmergencyFund =
            efState.totalEfBalancePaise > 0 || efState.hasOverride;
        if (hasEmergencyFund) {
          efCoverageMonths = efState.coverageMonths;
          efTargetMonths = efState.targetMonths;
        }
      }

      return PlanningHealthData(
        netWorthPaise: netWorthPaise,
        savingsRatePercent: savingsRatePercent,
        efCoverageMonths: efCoverageMonths,
        efTargetMonths: efTargetMonths,
        fiProgressPercent: fiProgressPercent,
        yearsToFi: yearsToFiValue,
        milestoneOnTrackCount: milestoneOnTrackCount,
        milestoneTotalCount: milestoneTotalCount,
        hasLifeProfile: hasLifeProfile,
        hasEmergencyFund: hasEmergencyFund,
      );
    });
