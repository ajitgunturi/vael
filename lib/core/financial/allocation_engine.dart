import '../models/enums.dart';

/// Target allocation in basis points (100 bp = 1%).
class AllocationTarget {
  final int equityBp;
  final int debtBp;
  final int goldBp;
  final int cashBp;

  const AllocationTarget({
    required this.equityBp,
    required this.debtBp,
    required this.goldBp,
    required this.cashBp,
  });
}

/// Custom override for a specific age band.
class AllocationTargetOverride {
  final int ageBandStart;
  final int ageBandEnd;
  final int equityBp;
  final int debtBp;
  final int goldBp;
  final int cashBp;

  const AllocationTargetOverride({
    required this.ageBandStart,
    required this.ageBandEnd,
    required this.equityBp,
    required this.debtBp,
    required this.goldBp,
    required this.cashBp,
  });
}

/// Lightweight holding input for allocation calculation (no DB dependency).
class HoldingInput {
  final String bucketType;
  final int currentValuePaise;

  const HoldingInput({
    required this.bucketType,
    required this.currentValuePaise,
  });
}

/// Result of rebalancing comparison: actual vs target for one asset class.
class RebalancingDelta {
  final AssetClass assetClass;

  /// Actual allocation in basis points (of total portfolio).
  final int actualBp;

  /// Target allocation in basis points.
  final int targetBp;

  /// Delta in paise: positive = overweight, negative = underweight.
  final int deltaPaise;

  /// Human-readable: 'overweight', 'underweight', or 'balanced'.
  final String deltaDescription;

  const RebalancingDelta({
    required this.assetClass,
    required this.actualBp,
    required this.targetBp,
    required this.deltaPaise,
    required this.deltaDescription,
  });
}

/// Pure static asset allocation engine.
///
/// All amounts are in **paise** (integer minor units).
/// Allocation percentages are in **basis points** (7500 bp = 75%).
/// No DB imports, no mutable state, no async.
class AllocationEngine {
  AllocationEngine._();

  // ── Default glide path tables ───────────────────────────────────────
  // Values from EXTENSION_PLAN_FINANCIAL_PLANNING.md section 6.4.
  // Key format: (ageBandStart, ageBandEnd).
  // Order: equity / debt / gold / cash.

  static const _conservative = <(int, int), AllocationTarget>{
    (20, 30): AllocationTarget(
      equityBp: 6000,
      debtBp: 3000,
      goldBp: 500,
      cashBp: 500,
    ),
    (30, 40): AllocationTarget(
      equityBp: 5000,
      debtBp: 3500,
      goldBp: 1000,
      cashBp: 500,
    ),
    (40, 50): AllocationTarget(
      equityBp: 4000,
      debtBp: 4000,
      goldBp: 1000,
      cashBp: 1000,
    ),
    (50, 60): AllocationTarget(
      equityBp: 3000,
      debtBp: 4500,
      goldBp: 1000,
      cashBp: 1500,
    ),
    (60, 70): AllocationTarget(
      equityBp: 2000,
      debtBp: 5000,
      goldBp: 1000,
      cashBp: 2000,
    ),
    (70, 200): AllocationTarget(
      equityBp: 1500,
      debtBp: 5000,
      goldBp: 1000,
      cashBp: 2500,
    ),
  };

  static const _moderate = <(int, int), AllocationTarget>{
    (20, 30): AllocationTarget(
      equityBp: 7500,
      debtBp: 1500,
      goldBp: 500,
      cashBp: 500,
    ),
    (30, 40): AllocationTarget(
      equityBp: 6500,
      debtBp: 2000,
      goldBp: 1000,
      cashBp: 500,
    ),
    (40, 50): AllocationTarget(
      equityBp: 5500,
      debtBp: 2500,
      goldBp: 1000,
      cashBp: 1000,
    ),
    (50, 60): AllocationTarget(
      equityBp: 4500,
      debtBp: 3000,
      goldBp: 1000,
      cashBp: 1500,
    ),
    (60, 70): AllocationTarget(
      equityBp: 3500,
      debtBp: 3500,
      goldBp: 1000,
      cashBp: 2000,
    ),
    (70, 200): AllocationTarget(
      equityBp: 2500,
      debtBp: 4000,
      goldBp: 1000,
      cashBp: 2500,
    ),
  };

  static const _aggressive = <(int, int), AllocationTarget>{
    (20, 30): AllocationTarget(
      equityBp: 8500,
      debtBp: 1000,
      goldBp: 0,
      cashBp: 500,
    ),
    (30, 40): AllocationTarget(
      equityBp: 7500,
      debtBp: 1500,
      goldBp: 500,
      cashBp: 500,
    ),
    (40, 50): AllocationTarget(
      equityBp: 6500,
      debtBp: 2000,
      goldBp: 1000,
      cashBp: 500,
    ),
    (50, 60): AllocationTarget(
      equityBp: 5500,
      debtBp: 2500,
      goldBp: 1000,
      cashBp: 1000,
    ),
    (60, 70): AllocationTarget(
      equityBp: 4500,
      debtBp: 3000,
      goldBp: 1000,
      cashBp: 1500,
    ),
    (70, 200): AllocationTarget(
      equityBp: 3500,
      debtBp: 3500,
      goldBp: 1000,
      cashBp: 2000,
    ),
  };

  static const _profiles = <String, Map<(int, int), AllocationTarget>>{
    'conservative': _conservative,
    'moderate': _moderate,
    'aggressive': _aggressive,
  };

  /// Returns the target allocation for a given [age] and [riskProfile].
  ///
  /// If [customTargets] are provided and cover the age, those take priority.
  /// Falls back to default glide path for uncovered age bands.
  /// Unknown profiles default to moderate.
  static AllocationTarget targetForAge({
    required int age,
    required String riskProfile,
    List<AllocationTargetOverride>? customTargets,
  }) {
    // Check custom overrides first.
    if (customTargets != null) {
      for (final ct in customTargets) {
        if (age >= ct.ageBandStart && age < ct.ageBandEnd) {
          return AllocationTarget(
            equityBp: ct.equityBp,
            debtBp: ct.debtBp,
            goldBp: ct.goldBp,
            cashBp: ct.cashBp,
          );
        }
      }
    }

    final table = _profiles[riskProfile] ?? _moderate;
    for (final entry in table.entries) {
      final (start, end) = entry.key;
      if (age >= start && age < end) {
        return entry.value;
      }
    }

    // Fallback: last band (70+).
    return table.entries.last.value;
  }

  /// Maps a [BucketType] name string to an [AssetClass].
  ///
  /// mutualFunds/stocks -> equity; ppf/epf/fixedDeposit/bonds/policy -> debt.
  /// NPS is handled separately via [npsAllocation].
  static AssetClass assetClassForBucket(String bucketType) {
    switch (bucketType) {
      case 'mutualFunds':
      case 'stocks':
        return AssetClass.equity;
      case 'ppf':
      case 'epf':
      case 'fixedDeposit':
      case 'bonds':
      case 'policy':
        return AssetClass.debt;
      case 'nps':
        // NPS is a lifecycle fund; caller should use npsAllocation() instead.
        // Default to debt for simple classification.
        return AssetClass.debt;
      default:
        return AssetClass.cash;
    }
  }

  /// Splits an NPS holding into equity/debt by age-based lifecycle rule.
  ///
  /// Age < 35: 75% equity / 25% debt.
  /// Age 35-44: 50% equity / 50% debt.
  /// Age >= 45: 25% equity / 75% debt.
  static Map<AssetClass, int> npsAllocation(
    int holdingValuePaise,
    int userAge,
  ) {
    final double equityPct;
    if (userAge < 35) {
      equityPct = 0.75;
    } else if (userAge < 45) {
      equityPct = 0.50;
    } else {
      equityPct = 0.25;
    }

    final equityPaise = (holdingValuePaise * equityPct).round();
    final debtPaise = holdingValuePaise - equityPaise;

    return {AssetClass.equity: equityPaise, AssetClass.debt: debtPaise};
  }

  /// Computes the current portfolio allocation by asset class.
  ///
  /// NPS holdings are split by age using [npsAllocation].
  /// All other holdings use [assetClassForBucket].
  static Map<AssetClass, int> currentAllocation(
    List<HoldingInput> holdings,
    int userAge,
  ) {
    final result = <AssetClass, int>{};

    for (final h in holdings) {
      if (h.bucketType == 'nps') {
        final split = npsAllocation(h.currentValuePaise, userAge);
        for (final entry in split.entries) {
          result[entry.key] = (result[entry.key] ?? 0) + entry.value;
        }
      } else {
        final ac = assetClassForBucket(h.bucketType);
        result[ac] = (result[ac] ?? 0) + h.currentValuePaise;
      }
    }

    return result;
  }

  /// Computes rebalancing deltas: actual allocation vs target.
  ///
  /// Returns one [RebalancingDelta] per asset class.
  /// deltaPaise is positive for overweight, negative for underweight.
  static List<RebalancingDelta> rebalancingDeltas({
    required Map<AssetClass, int> currentValuePaise,
    required AllocationTarget target,
  }) {
    final total = currentValuePaise.values.fold<int>(0, (a, b) => a + b);

    final targetMap = {
      AssetClass.equity: target.equityBp,
      AssetClass.debt: target.debtBp,
      AssetClass.gold: target.goldBp,
      AssetClass.cash: target.cashBp,
    };

    return AssetClass.values.map((ac) {
      final actual = currentValuePaise[ac] ?? 0;
      final actualBp = total > 0 ? (actual * 10000 / total).round() : 0;
      final tBp = targetMap[ac]!;

      final targetValue = total > 0 ? (total * tBp / 10000).round() : 0;
      final deltaPaise = actual - targetValue;

      final String desc;
      if (deltaPaise > 0) {
        desc = 'overweight';
      } else if (deltaPaise < 0) {
        desc = 'underweight';
      } else {
        desc = 'balanced';
      }

      return RebalancingDelta(
        assetClass: ac,
        actualBp: actualBp,
        targetBp: tBp,
        deltaPaise: deltaPaise,
        deltaDescription: desc,
      );
    }).toList();
  }
}
