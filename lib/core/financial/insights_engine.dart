import 'allocation_engine.dart';

/// Severity level for planning insights.
enum InsightSeverity { critical, warning, info }

/// Type of planning insight.
enum InsightType {
  efBelowTarget,
  allocationOffTarget,
  fiDateSlipping,
  sinkingFundUnderfunded,
}

/// A single planning insight/alert produced by [InsightsEngine].
class PlanningInsight {
  final InsightType type;
  final InsightSeverity severity;
  final String title;
  final String description;

  const PlanningInsight({
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
  });
}

/// Pure static deterministic alert engine for financial planning insights.
///
/// All methods are pure static, no DB imports, no async, no mutable state.
class InsightsEngine {
  InsightsEngine._();

  /// Emergency fund below target alert.
  ///
  /// Returns null if [coverageMonths] >= [targetMonths].
  /// severity=critical if coverage < 50% of target, warning otherwise.
  static PlanningInsight? efBelowTarget({
    required double coverageMonths,
    required int targetMonths,
  }) {
    if (coverageMonths >= targetMonths) return null;

    final monthsShort = targetMonths - coverageMonths;
    final severity = coverageMonths < targetMonths * 0.5
        ? InsightSeverity.critical
        : InsightSeverity.warning;

    return PlanningInsight(
      type: InsightType.efBelowTarget,
      severity: severity,
      title: 'Emergency fund below target',
      description:
          '${monthsShort.toStringAsFixed(1)} months short of $targetMonths-month target',
    );
  }

  /// Asset allocation off-target alert.
  ///
  /// Returns null if all asset classes are within 500bp (5%) of target.
  /// severity=critical if any class deviates > 1500bp (15%), warning otherwise.
  static PlanningInsight? allocationOffTarget({
    required List<RebalancingDelta> deltas,
  }) {
    if (deltas.isEmpty) return null;

    int maxDeviation = 0;
    RebalancingDelta? worstDelta;

    for (final d in deltas) {
      final deviation = (d.actualBp - d.targetBp).abs();
      if (deviation > maxDeviation) {
        maxDeviation = deviation;
        worstDelta = d;
      }
    }

    if (maxDeviation <= 500) return null;

    final severity = maxDeviation > 1500
        ? InsightSeverity.critical
        : InsightSeverity.warning;

    final deviationPct = maxDeviation / 100;

    return PlanningInsight(
      type: InsightType.allocationOffTarget,
      severity: severity,
      title: 'Asset allocation off-target',
      description:
          '${worstDelta!.assetClass.name} is ${deviationPct.toStringAsFixed(1)}% off target',
    );
  }

  /// FI date slipping alert.
  ///
  /// Returns null if either value is null or current <= previous.
  /// severity=warning always.
  static PlanningInsight? fiDateSlipping({
    required int? currentYearsToFi,
    required int? previousYearsToFi,
  }) {
    if (currentYearsToFi == null || previousYearsToFi == null) return null;
    if (currentYearsToFi <= previousYearsToFi) return null;

    final diff = currentYearsToFi - previousYearsToFi;
    final yearLabel = diff == 1 ? 'year' : 'years';

    return PlanningInsight(
      type: InsightType.fiDateSlipping,
      severity: InsightSeverity.warning,
      title: 'FI date slipping',
      description: 'FI timeline extended by $diff $yearLabel',
    );
  }

  /// Sinking fund underfunded alert.
  ///
  /// Returns null if [paceStatus] == 'onTrack'.
  /// severity=critical if 'atRisk', warning if 'behind'.
  static PlanningInsight? sinkingFundUnderfunded({
    required String paceStatus,
    required String fundName,
    required int monthlyNeededPaise,
    required int monthlyActualPaise,
  }) {
    if (paceStatus == 'onTrack') return null;

    final severity = paceStatus == 'atRisk'
        ? InsightSeverity.critical
        : InsightSeverity.warning;

    final needed = (monthlyNeededPaise / 100).toStringAsFixed(0);
    final actual = (monthlyActualPaise / 100).toStringAsFixed(0);

    return PlanningInsight(
      type: InsightType.sinkingFundUnderfunded,
      severity: severity,
      title: '$fundName underfunded',
      description: 'Need \u20b9$needed/mo, currently saving \u20b9$actual/mo',
    );
  }
}
