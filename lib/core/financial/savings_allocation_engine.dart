import 'dart:math' as math;

/// A rule defining how surplus should be allocated to a target.
///
/// All amounts are in **paise** (integer minor units).
/// Percentages are in **basis points** (1 bp = 0.01%).
class AllocationRule {
  final int priority; // 1 = highest
  final String
  targetType; // 'emergencyFund', 'sinkingFund', 'investmentGoal', 'opportunityFund'
  final String? targetId; // goalId for sinking/investment, null for EF/OPP
  final String allocationType; // 'fixed', 'percentage'
  final int? amountPaise; // for fixed
  final int? percentageBp; // for percentage (basis points of surplus)

  const AllocationRule({
    required this.priority,
    required this.targetType,
    this.targetId,
    required this.allocationType,
    this.amountPaise,
    this.percentageBp,
  });
}

/// Current state of an allocation target.
class AllocationTarget {
  final String targetType;
  final String? targetId;
  final String targetName;
  final int currentPaise;
  final int targetPaise; // 0 means unlimited (opportunity fund)

  const AllocationTarget({
    required this.targetType,
    this.targetId,
    required this.targetName,
    required this.currentPaise,
    required this.targetPaise,
  });
}

/// Advice for a single allocation: how much was allocated and what remains.
class AllocationAdvice {
  final String targetType;
  final String? targetId;
  final String targetName;
  final int allocatedPaise;
  final int
  remainingToTarget; // targetPaise - currentPaise - allocatedPaise (0 if unlimited)

  const AllocationAdvice({
    required this.targetType,
    this.targetId,
    required this.targetName,
    required this.allocatedPaise,
    required this.remainingToTarget,
  });
}

/// Pure static engine for priority-ordered surplus distribution.
///
/// Distributes surplus across allocation rules in priority order,
/// supporting both fixed-amount and percentage-of-surplus allocation types.
/// Skips targets that are already met. No DB imports, no mutable state, no async.
class SavingsAllocationEngine {
  SavingsAllocationEngine._();

  /// Distributes [surplusPaise] across [rules] in priority order.
  ///
  /// [rules] MUST be sorted by priority ascending (1 = highest).
  /// [targets] is keyed by '$targetType:$targetId' (e.g. 'emergencyFund:null').
  ///
  /// Returns [AllocationAdvice] for each rule that received an allocation.
  /// Rules whose targets are already met or not found are skipped.
  static List<AllocationAdvice> distribute({
    required int surplusPaise,
    required List<AllocationRule> rules,
    required Map<String, AllocationTarget> targets,
  }) {
    if (rules.isEmpty) return [];

    var remaining = surplusPaise;
    final advice = <AllocationAdvice>[];

    for (final rule in rules) {
      if (remaining <= 0) break;

      // Find target by key
      final key = '${rule.targetType}:${rule.targetId}';
      final target = targets[key];
      if (target == null) continue;

      // Compute gap: 0 targetPaise means unlimited (opportunity fund)
      final gap = target.targetPaise == 0
          ? remaining
          : math.max(0, target.targetPaise - target.currentPaise);
      if (gap <= 0) continue; // target met

      // Compute rule amount
      final int ruleAmount;
      if (rule.allocationType == 'fixed') {
        ruleAmount = rule.amountPaise ?? 0;
      } else {
        // percentage: surplusPaise * percentageBp / 10000
        ruleAmount = surplusPaise * (rule.percentageBp ?? 0) ~/ 10000;
      }

      final allocated = math.min(ruleAmount, math.min(remaining, gap));
      remaining -= allocated;

      final remainingToTarget = target.targetPaise == 0 ? 0 : gap - allocated;

      advice.add(
        AllocationAdvice(
          targetType: rule.targetType,
          targetId: rule.targetId,
          targetName: target.targetName,
          allocatedPaise: allocated,
          remainingToTarget: remainingToTarget,
        ),
      );
    }

    return advice;
  }
}
