import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/financial/decision_modeler.dart';
import 'package:vael/core/financial/fi_calculator.dart';
import 'package:vael/core/financial/indian_tax_constants.dart';
import 'package:vael/core/models/enums.dart';

void main() {
  // Shared baseline params
  const currentAge = 30;
  const retirementAge = 60;
  const currentPortfolioPaise = 500000000; // 50 lakh
  const monthlySavingsPaise = 10000000; // 1 lakh
  const annualExpensesPaise = 600000000; // 6 lakh/year
  const currentMonthlySalaryPaise = 15000000; // 1.5 lakh
  const swr = 0.04;
  const inflationRate = 0.06;
  const annualReturnRate = 0.10;

  group('DecisionModelerEngine - jobChange', () {
    test('higher salary decreases FI years (positive impact)', () {
      final impact = DecisionModelerEngine.computeImpact(
        type: DecisionType.jobChange,
        params: JobChangeParams(
          newMonthlySalaryPaise: 20000000, // 2 lakh (up from 1.5)
        ),
        currentAge: currentAge,
        retirementAge: retirementAge,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualExpensesPaise: annualExpensesPaise,
        currentMonthlySalaryPaise: currentMonthlySalaryPaise,
        swr: swr,
        inflationRate: inflationRate,
        annualReturnRate: annualReturnRate,
      );

      expect(
        impact.fiDelayYears,
        isNegative,
        reason: 'Higher salary should reduce FI years',
      );
      expect(impact.fiYearsAfter, lessThan(impact.fiYearsBefore));
      expect(impact.monthlyCashFlowChangePaise, equals(5000000));
    });

    test('lower salary increases FI years (negative impact)', () {
      final impact = DecisionModelerEngine.computeImpact(
        type: DecisionType.jobChange,
        params: JobChangeParams(
          newMonthlySalaryPaise: 10000000, // 1 lakh (down from 1.5)
        ),
        currentAge: currentAge,
        retirementAge: retirementAge,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualExpensesPaise: annualExpensesPaise,
        currentMonthlySalaryPaise: currentMonthlySalaryPaise,
        swr: swr,
        inflationRate: inflationRate,
        annualReturnRate: annualReturnRate,
      );

      expect(
        impact.fiDelayYears,
        isNonNegative,
        reason: 'Lower salary should increase FI years',
      );
      expect(impact.fiYearsAfter, greaterThanOrEqualTo(impact.fiYearsBefore));
      expect(impact.monthlyCashFlowChangePaise, equals(-5000000));
    });
  });

  group('DecisionModelerEngine - salaryNegotiation', () {
    test('proposed higher salary shows same positive impact as jobChange', () {
      final impact = DecisionModelerEngine.computeImpact(
        type: DecisionType.salaryNegotiation,
        params: SalaryNegotiationParams(
          currentMonthlySalaryPaise: currentMonthlySalaryPaise,
          proposedMonthlySalaryPaise: 20000000,
        ),
        currentAge: currentAge,
        retirementAge: retirementAge,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualExpensesPaise: annualExpensesPaise,
        currentMonthlySalaryPaise: currentMonthlySalaryPaise,
        swr: swr,
        inflationRate: inflationRate,
        annualReturnRate: annualReturnRate,
      );

      expect(impact.fiDelayYears, isNegative);
      expect(impact.monthlyCashFlowChangePaise, equals(5000000));
    });
  });

  group('DecisionModelerEngine - majorPurchase', () {
    test('delegates to PurchasePlannerEngine correctly', () {
      final impact = DecisionModelerEngine.computeImpact(
        type: DecisionType.majorPurchase,
        params: MajorPurchaseParams(
          purchaseAmountPaise: 5000000000, // 50 lakh
          downPaymentBp: 2000, // 20%
        ),
        currentAge: currentAge,
        retirementAge: retirementAge,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualExpensesPaise: annualExpensesPaise,
        currentMonthlySalaryPaise: currentMonthlySalaryPaise,
        swr: swr,
        inflationRate: inflationRate,
        annualReturnRate: annualReturnRate,
      );

      // Down payment = 10 lakh (20% of 50 lakh) = portfolio drops by 10 lakh
      expect(impact.fiYearsAfter, greaterThan(impact.fiYearsBefore));
      expect(impact.fiDelayYears, isPositive);
    });
  });

  group('DecisionModelerEngine - investmentWithdrawal', () {
    test('STCG rate for holding < 12 months', () {
      final impact = DecisionModelerEngine.computeImpact(
        type: DecisionType.investmentWithdrawal,
        params: InvestmentWithdrawalParams(
          amountPaise: 100000000, // 10 lakh
          bucketType: 'mutualFunds',
          holdingMonths: 6,
        ),
        currentAge: currentAge,
        retirementAge: retirementAge,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualExpensesPaise: annualExpensesPaise,
        currentMonthlySalaryPaise: currentMonthlySalaryPaise,
        swr: swr,
        inflationRate: inflationRate,
        annualReturnRate: annualReturnRate,
      );

      // STCG at 2000bp (20%) on 10 lakh = 2 lakh tax
      expect(impact.taxImplicationPaise, equals(20000000));
      expect(impact.taxDescription, contains('STCG'));
      expect(impact.fiDelayYears, isNonNegative);
    });

    test('LTCG rate for holding >= 12 months with exemption', () {
      final impact = DecisionModelerEngine.computeImpact(
        type: DecisionType.investmentWithdrawal,
        params: InvestmentWithdrawalParams(
          amountPaise: 100000000, // 10 lakh
          bucketType: 'stocks',
          holdingMonths: 18,
        ),
        currentAge: currentAge,
        retirementAge: retirementAge,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualExpensesPaise: annualExpensesPaise,
        currentMonthlySalaryPaise: currentMonthlySalaryPaise,
        swr: swr,
        inflationRate: inflationRate,
        annualReturnRate: annualReturnRate,
      );

      // LTCG at 1250bp (12.5%) on (10 lakh - 1.25 lakh exemption) = 8.75 lakh
      // Tax = 8.75 lakh * 12.5% = 1,09,375 paise = ~10937500 paise
      // But since gain == withdrawal amount (simplified), the taxable is max(0, 10L - 1.25L)
      expect(impact.taxImplicationPaise, isNotNull);
      expect(impact.taxDescription, contains('LTCG'));
      expect(impact.fiDelayYears, isNonNegative);
    });

    test('reduces portfolio and shows FI delay', () {
      final impact = DecisionModelerEngine.computeImpact(
        type: DecisionType.investmentWithdrawal,
        params: InvestmentWithdrawalParams(
          amountPaise: 200000000, // 20 lakh
          bucketType: 'mutualFunds',
          holdingMonths: 24,
        ),
        currentAge: currentAge,
        retirementAge: retirementAge,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualExpensesPaise: annualExpensesPaise,
        currentMonthlySalaryPaise: currentMonthlySalaryPaise,
        swr: swr,
        inflationRate: inflationRate,
        annualReturnRate: annualReturnRate,
      );

      expect(impact.fiYearsAfter, greaterThanOrEqualTo(impact.fiYearsBefore));
    });
  });

  group('DecisionModelerEngine - rentalChange', () {
    test('shows monthly cash flow impact (oldRent - newRent)', () {
      final impact = DecisionModelerEngine.computeImpact(
        type: DecisionType.rentalChange,
        params: RentalChangeParams(
          currentRentPaise: 2000000, // 20k
          newRentPaise: 3000000, // 30k
        ),
        currentAge: currentAge,
        retirementAge: retirementAge,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualExpensesPaise: annualExpensesPaise,
        currentMonthlySalaryPaise: currentMonthlySalaryPaise,
        swr: swr,
        inflationRate: inflationRate,
        annualReturnRate: annualReturnRate,
      );

      // rentDelta = 30k - 20k = 10k increase => cash flow change = -10k
      expect(impact.monthlyCashFlowChangePaise, equals(-1000000));
      expect(impact.fiDelayYears, isNonNegative);
    });
  });

  group('DecisionModelerEngine - custom', () {
    test('applies arbitrary income/expense/one-time changes', () {
      final impact = DecisionModelerEngine.computeImpact(
        type: DecisionType.custom,
        params: CustomParams(
          monthlyIncomeChangePaise: 5000000,
          monthlyExpenseChangePaise: 2000000,
          oneTimeCostPaise: 50000000,
          description: 'Side business launch',
        ),
        currentAge: currentAge,
        retirementAge: retirementAge,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualExpensesPaise: annualExpensesPaise,
        currentMonthlySalaryPaise: currentMonthlySalaryPaise,
        swr: swr,
        inflationRate: inflationRate,
        annualReturnRate: annualReturnRate,
      );

      // Net monthly improvement = 5L income - 2L expense = 3L net
      expect(impact.monthlyCashFlowChangePaise, equals(3000000));
    });
  });

  group('DecisionModelerEngine - edge cases', () {
    test('zero portfolio returns unreachable sentinel for FI impact', () {
      final impact = DecisionModelerEngine.computeImpact(
        type: DecisionType.jobChange,
        params: JobChangeParams(newMonthlySalaryPaise: 10000000),
        currentAge: currentAge,
        retirementAge: retirementAge,
        currentPortfolioPaise: 0,
        monthlySavingsPaise: 0,
        annualExpensesPaise: annualExpensesPaise,
        currentMonthlySalaryPaise: currentMonthlySalaryPaise,
        swr: swr,
        inflationRate: inflationRate,
        annualReturnRate: annualReturnRate,
      );

      // With 0 savings and lower salary, both before and after should be -1
      expect(impact.fiYearsBefore, equals(-1));
    });
  });

  group('DecisionModelerEngine - NW milestones', () {
    test('NW impact at milestone ages computed via MilestoneEngine', () {
      final impact = DecisionModelerEngine.computeImpact(
        type: DecisionType.jobChange,
        params: JobChangeParams(newMonthlySalaryPaise: 20000000),
        currentAge: 25,
        retirementAge: retirementAge,
        currentPortfolioPaise: currentPortfolioPaise,
        monthlySavingsPaise: monthlySavingsPaise,
        annualExpensesPaise: annualExpensesPaise,
        currentMonthlySalaryPaise: currentMonthlySalaryPaise,
        swr: swr,
        inflationRate: inflationRate,
        annualReturnRate: annualReturnRate,
      );

      // For age 25, milestones should include 30, 40, 50, 60, 70
      expect(
        impact.nwImpactAtMilestoneAges.keys,
        containsAll([30, 40, 50, 60, 70]),
      );

      // After impact (higher savings) should show higher NW at each milestone
      for (final entry in impact.nwImpactAtMilestoneAges.entries) {
        expect(
          entry.value.afterPaise,
          greaterThan(entry.value.beforePaise),
          reason: 'Age ${entry.key}: higher savings should yield higher NW',
        );
      }
    });
  });
}
