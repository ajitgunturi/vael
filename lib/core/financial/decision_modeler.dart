import 'dart:math' as math;

import '../models/enums.dart';
import 'fi_calculator.dart';
import 'indian_tax_constants.dart';
import 'milestone_engine.dart';
import 'purchase_planner.dart';

/// Base class for all decision parameter types.
sealed class DecisionParameters {
  const DecisionParameters();
}

/// Parameters for a job change decision.
class JobChangeParams extends DecisionParameters {
  final int newMonthlySalaryPaise;
  final DateTime? startDate;
  final int? annualRsuPaise;
  final int? vestingYears;
  final int? annualBonusBp;

  const JobChangeParams({
    required this.newMonthlySalaryPaise,
    this.startDate,
    this.annualRsuPaise,
    this.vestingYears,
    this.annualBonusBp,
  });
}

/// Parameters for a salary negotiation decision.
class SalaryNegotiationParams extends DecisionParameters {
  final int currentMonthlySalaryPaise;
  final int proposedMonthlySalaryPaise;
  final DateTime? effectiveDate;

  const SalaryNegotiationParams({
    required this.currentMonthlySalaryPaise,
    required this.proposedMonthlySalaryPaise,
    this.effectiveDate,
  });
}

/// Parameters for a major purchase decision.
class MajorPurchaseParams extends DecisionParameters {
  final int purchaseAmountPaise;
  final int downPaymentBp;
  final int? loanTenureMonths;
  final double? loanInterestRate;
  final int? educationEscalationRateBp;

  const MajorPurchaseParams({
    required this.purchaseAmountPaise,
    required this.downPaymentBp,
    this.loanTenureMonths,
    this.loanInterestRate,
    this.educationEscalationRateBp,
  });
}

/// Parameters for an investment withdrawal decision.
class InvestmentWithdrawalParams extends DecisionParameters {
  final int amountPaise;
  final String bucketType;
  final int holdingMonths;

  const InvestmentWithdrawalParams({
    required this.amountPaise,
    required this.bucketType,
    required this.holdingMonths,
  });
}

/// Parameters for a rental change decision.
class RentalChangeParams extends DecisionParameters {
  final int currentRentPaise;
  final int newRentPaise;
  final DateTime? moveInDate;
  final int? securityDepositPaise;

  const RentalChangeParams({
    required this.currentRentPaise,
    required this.newRentPaise,
    this.moveInDate,
    this.securityDepositPaise,
  });
}

/// Parameters for a custom decision.
class CustomParams extends DecisionParameters {
  final int monthlyIncomeChangePaise;
  final int monthlyExpenseChangePaise;
  final int oneTimeCostPaise;
  final String? description;

  const CustomParams({
    this.monthlyIncomeChangePaise = 0,
    this.monthlyExpenseChangePaise = 0,
    this.oneTimeCostPaise = 0,
    this.description,
  });
}

/// Net worth delta at a milestone age: before and after the decision.
class NwDelta {
  final int beforePaise;
  final int afterPaise;

  const NwDelta({required this.beforePaise, required this.afterPaise});
}

/// Impact of a financial decision on the FI timeline and net worth.
class DecisionImpact {
  /// Years to FI before the decision.
  final int fiYearsBefore;

  /// Years to FI after the decision (-1 if unreachable).
  final int fiYearsAfter;

  /// Delay in years caused by the decision (negative = improvement).
  final int fiDelayYears;

  /// Monthly cash flow change in paise (positive = improvement).
  final int monthlyCashFlowChangePaise;

  /// NW impact at milestone ages: age -> {before, after} in paise.
  final Map<int, NwDelta> nwImpactAtMilestoneAges;

  /// Tax implication in paise (only for withdrawals).
  final int? taxImplicationPaise;

  /// Human-readable tax description.
  final String? taxDescription;

  const DecisionImpact({
    required this.fiYearsBefore,
    required this.fiYearsAfter,
    required this.fiDelayYears,
    required this.monthlyCashFlowChangePaise,
    required this.nwImpactAtMilestoneAges,
    this.taxImplicationPaise,
    this.taxDescription,
  });
}

/// Composition engine that computes the impact of any life decision
/// by delegating to existing engines (FiCalculator, PurchasePlannerEngine,
/// MilestoneEngine, IndianTaxConstants).
///
/// All amounts are in **paise** (integer minor units).
/// No DB imports, no mutable state, no async.
class DecisionModelerEngine {
  DecisionModelerEngine._();

  static const _milestoneAges = [30, 40, 50, 60, 70];

  /// Computes the impact of a financial decision on FI timeline, cash flow,
  /// and net worth at milestone ages.
  ///
  /// Delegates to [FiCalculator], [PurchasePlannerEngine], [MilestoneEngine],
  /// and [IndianTaxConstants] -- no new math.
  static DecisionImpact computeImpact({
    required DecisionType type,
    required DecisionParameters params,
    required int currentAge,
    required int retirementAge,
    required int currentPortfolioPaise,
    required int monthlySavingsPaise,
    required int annualExpensesPaise,
    required int currentMonthlySalaryPaise,
    required double swr,
    required double inflationRate,
    required double annualReturnRate,
  }) {
    final yearsToRetirement = retirementAge - currentAge;

    // Baseline FI number (shared across all decision types).
    final fiNumber = FiCalculator.computeFiNumber(
      annualExpensesPaise: annualExpensesPaise,
      swr: swr,
      inflationRate: inflationRate,
      yearsToRetirement: yearsToRetirement,
    );

    final baselineYears = FiCalculator.yearsToFi(
      currentPortfolioPaise: currentPortfolioPaise,
      monthlySavingsPaise: monthlySavingsPaise,
      annualReturnRate: annualReturnRate,
      fiNumberPaise: fiNumber,
    );

    return switch (params) {
      JobChangeParams p => _jobChange(
        p,
        currentMonthlySalaryPaise: currentMonthlySalaryPaise,
        baselineYears: baselineYears,
        fiNumber: fiNumber,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualReturnRate: annualReturnRate,
        currentAge: currentAge,
      ),
      SalaryNegotiationParams p => _salaryNegotiation(
        p,
        currentMonthlySalaryPaise: currentMonthlySalaryPaise,
        baselineYears: baselineYears,
        fiNumber: fiNumber,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualReturnRate: annualReturnRate,
        currentAge: currentAge,
      ),
      MajorPurchaseParams p => _majorPurchase(
        p,
        baselineYears: baselineYears,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualExpensesPaise: annualExpensesPaise,
        annualReturnRate: annualReturnRate,
        swr: swr,
        inflationRate: inflationRate,
        yearsToRetirement: yearsToRetirement,
        currentAge: currentAge,
      ),
      InvestmentWithdrawalParams p => _investmentWithdrawal(
        p,
        baselineYears: baselineYears,
        fiNumber: fiNumber,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualReturnRate: annualReturnRate,
        currentAge: currentAge,
      ),
      RentalChangeParams p => _rentalChange(
        p,
        baselineYears: baselineYears,
        fiNumber: fiNumber,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualReturnRate: annualReturnRate,
        currentAge: currentAge,
      ),
      CustomParams p => _custom(
        p,
        baselineYears: baselineYears,
        fiNumber: fiNumber,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualReturnRate: annualReturnRate,
        currentAge: currentAge,
      ),
    };
  }

  // ── Job Change ────────────────────────────────────────────────────

  static DecisionImpact _jobChange(
    JobChangeParams p, {
    required int currentMonthlySalaryPaise,
    required int baselineYears,
    required int fiNumber,
    required int currentPortfolioPaise,
    required int monthlySavingsPaise,
    required double annualReturnRate,
    required int currentAge,
  }) {
    final salaryDelta = p.newMonthlySalaryPaise - currentMonthlySalaryPaise;
    final afterSavings = math.max(0, monthlySavingsPaise + salaryDelta);

    final afterYears = FiCalculator.yearsToFi(
      currentPortfolioPaise: currentPortfolioPaise,
      monthlySavingsPaise: afterSavings,
      annualReturnRate: annualReturnRate,
      fiNumberPaise: fiNumber,
    );

    return _buildImpact(
      baselineYears: baselineYears,
      afterYears: afterYears,
      cashFlowChange: salaryDelta,
      currentAge: currentAge,
      currentPortfolioPaise: currentPortfolioPaise,
      monthlySavingsBefore: monthlySavingsPaise,
      monthlySavingsAfter: afterSavings,
      annualReturnRate: annualReturnRate,
    );
  }

  // ── Salary Negotiation ────────────────────────────────────────────

  static DecisionImpact _salaryNegotiation(
    SalaryNegotiationParams p, {
    required int currentMonthlySalaryPaise,
    required int baselineYears,
    required int fiNumber,
    required int currentPortfolioPaise,
    required int monthlySavingsPaise,
    required double annualReturnRate,
    required int currentAge,
  }) {
    // Same logic as job change, using current vs proposed salary.
    final salaryDelta =
        p.proposedMonthlySalaryPaise - p.currentMonthlySalaryPaise;
    final afterSavings = math.max(0, monthlySavingsPaise + salaryDelta);

    final afterYears = FiCalculator.yearsToFi(
      currentPortfolioPaise: currentPortfolioPaise,
      monthlySavingsPaise: afterSavings,
      annualReturnRate: annualReturnRate,
      fiNumberPaise: fiNumber,
    );

    return _buildImpact(
      baselineYears: baselineYears,
      afterYears: afterYears,
      cashFlowChange: salaryDelta,
      currentAge: currentAge,
      currentPortfolioPaise: currentPortfolioPaise,
      monthlySavingsBefore: monthlySavingsPaise,
      monthlySavingsAfter: afterSavings,
      annualReturnRate: annualReturnRate,
    );
  }

  // ── Major Purchase ────────────────────────────────────────────────

  static DecisionImpact _majorPurchase(
    MajorPurchaseParams p, {
    required int baselineYears,
    required int currentPortfolioPaise,
    required int monthlySavingsPaise,
    required int annualExpensesPaise,
    required double annualReturnRate,
    required double swr,
    required double inflationRate,
    required int yearsToRetirement,
    required int currentAge,
  }) {
    // Delegate entirely to PurchasePlannerEngine.
    final purchaseImpact = PurchasePlannerEngine.computeImpact(
      purchaseAmountPaise: p.purchaseAmountPaise,
      downPaymentBp: p.downPaymentBp,
      currentPortfolioPaise: currentPortfolioPaise,
      monthlySavingsPaise: monthlySavingsPaise,
      annualExpensesPaise: annualExpensesPaise,
      annualReturnRate: annualReturnRate,
      swr: swr,
      inflationRate: inflationRate,
      yearsToRetirement: yearsToRetirement,
      loanTenureMonths: p.loanTenureMonths,
      loanInterestRate: p.loanInterestRate,
    );

    final afterPortfolio = math.max(
      0,
      currentPortfolioPaise - purchaseImpact.downPaymentPaise,
    );
    final afterSavings = math.max(
      0,
      monthlySavingsPaise - purchaseImpact.monthlyEmiPaise,
    );
    final cashFlowChange = -purchaseImpact.monthlyEmiPaise;

    return _buildImpact(
      baselineYears: purchaseImpact.fiYearsBefore,
      afterYears: purchaseImpact.fiYearsAfter,
      cashFlowChange: cashFlowChange,
      currentAge: currentAge,
      currentPortfolioPaise: currentPortfolioPaise,
      portfolioAfter: afterPortfolio,
      monthlySavingsBefore: monthlySavingsPaise,
      monthlySavingsAfter: afterSavings,
      annualReturnRate: annualReturnRate,
    );
  }

  // ── Investment Withdrawal ─────────────────────────────────────────

  static DecisionImpact _investmentWithdrawal(
    InvestmentWithdrawalParams p, {
    required int baselineYears,
    required int fiNumber,
    required int currentPortfolioPaise,
    required int monthlySavingsPaise,
    required double annualReturnRate,
    required int currentAge,
  }) {
    // Determine tax based on holding period and asset type.
    final isEquity = p.bucketType == 'mutualFunds' || p.bucketType == 'stocks';

    int taxPaise = 0;
    String taxDesc;

    if (isEquity) {
      if (p.holdingMonths < IndianTaxConstants.equityLtcgThresholdMonths) {
        // STCG
        taxPaise = (p.amountPaise * IndianTaxConstants.equityStcgRateBp / 10000)
            .round();
        taxDesc =
            'STCG @${IndianTaxConstants.equityStcgRateBp / 100}% on ${_formatPaise(p.amountPaise)}';
      } else {
        // LTCG with exemption
        final taxableGain = math.max(
          0,
          p.amountPaise - IndianTaxConstants.equityLtcgExemptionPaise,
        );
        taxPaise = (taxableGain * IndianTaxConstants.equityLtcgRateBp / 10000)
            .round();
        taxDesc =
            'LTCG @${IndianTaxConstants.equityLtcgRateBp / 100}% on ${_formatPaise(taxableGain)} (after ${_formatPaise(IndianTaxConstants.equityLtcgExemptionPaise)} exemption)';
      }
    } else {
      // Debt -- taxed as income (simplified: use a flat 30% slab assumption)
      taxPaise = (p.amountPaise * 3000 / 10000).round();
      taxDesc = 'Debt gains taxed as income (slab rate assumed 30%)';
    }

    // Portfolio reduces by withdrawal + tax
    final afterPortfolio = math.max(
      0,
      currentPortfolioPaise - p.amountPaise - taxPaise,
    );

    final afterYears = FiCalculator.yearsToFi(
      currentPortfolioPaise: afterPortfolio,
      monthlySavingsPaise: monthlySavingsPaise,
      annualReturnRate: annualReturnRate,
      fiNumberPaise: fiNumber,
    );

    return _buildImpact(
      baselineYears: baselineYears,
      afterYears: afterYears,
      cashFlowChange: 0,
      currentAge: currentAge,
      currentPortfolioPaise: currentPortfolioPaise,
      portfolioAfter: afterPortfolio,
      monthlySavingsBefore: monthlySavingsPaise,
      monthlySavingsAfter: monthlySavingsPaise,
      annualReturnRate: annualReturnRate,
      taxPaise: taxPaise,
      taxDesc: taxDesc,
    );
  }

  // ── Rental Change ─────────────────────────────────────────────────

  static DecisionImpact _rentalChange(
    RentalChangeParams p, {
    required int baselineYears,
    required int fiNumber,
    required int currentPortfolioPaise,
    required int monthlySavingsPaise,
    required double annualReturnRate,
    required int currentAge,
  }) {
    final rentDelta = p.newRentPaise - p.currentRentPaise;
    final securityDeposit = p.securityDepositPaise ?? 0;

    final afterPortfolio = math.max(0, currentPortfolioPaise - securityDeposit);
    final afterSavings = math.max(0, monthlySavingsPaise - rentDelta);

    final afterYears = FiCalculator.yearsToFi(
      currentPortfolioPaise: afterPortfolio,
      monthlySavingsPaise: afterSavings,
      annualReturnRate: annualReturnRate,
      fiNumberPaise: fiNumber,
    );

    return _buildImpact(
      baselineYears: baselineYears,
      afterYears: afterYears,
      cashFlowChange: -rentDelta,
      currentAge: currentAge,
      currentPortfolioPaise: currentPortfolioPaise,
      portfolioAfter: afterPortfolio,
      monthlySavingsBefore: monthlySavingsPaise,
      monthlySavingsAfter: afterSavings,
      annualReturnRate: annualReturnRate,
    );
  }

  // ── Custom ────────────────────────────────────────────────────────

  static DecisionImpact _custom(
    CustomParams p, {
    required int baselineYears,
    required int fiNumber,
    required int currentPortfolioPaise,
    required int monthlySavingsPaise,
    required double annualReturnRate,
    required int currentAge,
  }) {
    final netMonthlyCashFlow =
        p.monthlyIncomeChangePaise - p.monthlyExpenseChangePaise;
    final afterPortfolio = math.max(
      0,
      currentPortfolioPaise - p.oneTimeCostPaise,
    );
    final afterSavings = math.max(0, monthlySavingsPaise + netMonthlyCashFlow);

    final afterYears = FiCalculator.yearsToFi(
      currentPortfolioPaise: afterPortfolio,
      monthlySavingsPaise: afterSavings,
      annualReturnRate: annualReturnRate,
      fiNumberPaise: fiNumber,
    );

    return _buildImpact(
      baselineYears: baselineYears,
      afterYears: afterYears,
      cashFlowChange: netMonthlyCashFlow,
      currentAge: currentAge,
      currentPortfolioPaise: currentPortfolioPaise,
      portfolioAfter: afterPortfolio,
      monthlySavingsBefore: monthlySavingsPaise,
      monthlySavingsAfter: afterSavings,
      annualReturnRate: annualReturnRate,
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────

  static DecisionImpact _buildImpact({
    required int baselineYears,
    required int afterYears,
    required int cashFlowChange,
    required int currentAge,
    required int currentPortfolioPaise,
    int? portfolioAfter,
    required int monthlySavingsBefore,
    required int monthlySavingsAfter,
    required double annualReturnRate,
    int? taxPaise,
    String? taxDesc,
  }) {
    final delay = (afterYears == -1 || baselineYears == -1)
        ? (afterYears == -1 ? (baselineYears == -1 ? 0 : -1) : 0)
        : afterYears - baselineYears;

    final nwMap = <int, NwDelta>{};
    final effectivePortfolioAfter = portfolioAfter ?? currentPortfolioPaise;

    for (final age in _milestoneAges) {
      if (age <= currentAge) continue;

      final before = MilestoneEngine.projectNetWorthAtAge(
        currentNwPaise: currentPortfolioPaise,
        currentAge: currentAge,
        targetAge: age,
        monthlySavingsPaise: monthlySavingsBefore,
        annualReturnRate: annualReturnRate,
      );

      final after = MilestoneEngine.projectNetWorthAtAge(
        currentNwPaise: effectivePortfolioAfter,
        currentAge: currentAge,
        targetAge: age,
        monthlySavingsPaise: monthlySavingsAfter,
        annualReturnRate: annualReturnRate,
      );

      nwMap[age] = NwDelta(beforePaise: before, afterPaise: after);
    }

    return DecisionImpact(
      fiYearsBefore: baselineYears,
      fiYearsAfter: afterYears,
      fiDelayYears: delay,
      monthlyCashFlowChangePaise: cashFlowChange,
      nwImpactAtMilestoneAges: nwMap,
      taxImplicationPaise: taxPaise,
      taxDescription: taxDesc,
    );
  }

  static String _formatPaise(int paise) {
    final rupees = paise / 100;
    if (rupees >= 10000000)
      return '${(rupees / 10000000).toStringAsFixed(2)} Cr';
    if (rupees >= 100000) return '${(rupees / 100000).toStringAsFixed(2)} L';
    return '${rupees.toStringAsFixed(0)}';
  }
}
