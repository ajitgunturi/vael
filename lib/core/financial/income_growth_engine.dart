import 'dart:math' as math;

import 'projection_engine.dart';

/// Basis-point conversion helpers.
/// 800 bp = 8.00% display = 0.08 rate.
double bpToRate(int bp) => bp / 10000.0;
double bpToPercent(int bp) => bp / 100.0;
int percentToBp(double pct) => (pct * 100).round();

enum CareerStage {
  early(1.2),
  mid(1.0),
  late_(0.6);

  final double multiplier;
  const CareerStage(this.multiplier);
}

/// Pure-function engine for career-stage-aware income growth.
///
/// No DB imports. No mutable state. All methods static.
/// Career stages: Early [20,30) 1.2x, Mid [30,45) 1.0x, Late [45,retirement) 0.6x.
class IncomeGrowthEngine {
  IncomeGrowthEngine._();

  /// Determine career stage from age.
  /// Early: [20, 30), Mid: [30, 45), Late: [45, +inf)
  static CareerStage stageForAge(int age) {
    if (age < 30) return CareerStage.early;
    if (age < 45) return CareerStage.mid;
    return CareerStage.late_;
  }

  /// Career-stage-adjusted annual growth rate.
  static double adjustedGrowthRate({
    required double baseRate,
    required CareerStage stage,
  }) => baseRate * stage.multiplier;

  /// Build segmented salary trajectory as ProjectionCashFlow list.
  ///
  /// Each segment covers years within a career stage. The stage
  /// multiplier is applied to [baseAnnualGrowthRate] as the
  /// annualEscalation on each ProjectionCashFlow.
  ///
  /// [currentMonthlySalary] in paise.
  /// [baseAnnualGrowthRate] as decimal (0.08 for 8%).
  /// [hikeMonth] 1-12 (stored for reference; projection engine
  /// uses relative-month escalation at month 13, 25, etc.).
  static List<ProjectionCashFlow> buildSalaryTrajectory({
    required int currentMonthlySalary,
    required int currentAge,
    required int retirementAge,
    required double baseAnnualGrowthRate,
    int hikeMonth = 4,
  }) {
    const stageRanges = [
      (minAge: 20, maxAge: 30, stage: CareerStage.early),
      (minAge: 30, maxAge: 45, stage: CareerStage.mid),
      (minAge: 45, maxAge: 100, stage: CareerStage.late_),
    ];

    final flows = <ProjectionCashFlow>[];
    int projectedSalary = currentMonthlySalary;

    for (final range in stageRanges) {
      final stageStart = range.minAge.clamp(currentAge, retirementAge);
      final stageEnd = range.maxAge.clamp(currentAge, retirementAge);
      if (stageStart >= stageEnd) continue;

      final durationYears = stageEnd - stageStart;
      final adjustedRate = baseAnnualGrowthRate * range.stage.multiplier;

      flows.add(
        ProjectionCashFlow(
          name: 'Salary (${range.stage.name})',
          monthlyAmount: projectedSalary,
          isIncome: true,
          durationMonths: durationYears * 12,
          annualEscalation: adjustedRate,
        ),
      );

      // Compound forward for next stage's starting salary
      projectedSalary =
          (projectedSalary * math.pow(1 + adjustedRate, durationYears)).round();
    }

    return flows;
  }
}
