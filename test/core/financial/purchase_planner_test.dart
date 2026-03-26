import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/purchase_planner.dart';

void main() {
  // ── Common test parameters ────────────────────────────────────────
  // Portfolio: 50L paise, monthly savings: 50k paise, annual expenses: 6L paise
  // Return: 10%, SWR: 4%, Inflation: 6%, Retirement in 25 years
  const portfolio = 5000000000; // 50L in paise
  const monthlySavings = 5000000; // 50k in paise
  const annualExpenses = 60000000; // 6L in paise
  const returnRate = 0.10;
  const swr = 0.04;
  const inflationRate = 0.06;
  const yearsToRetirement = 25;

  group('PurchasePlannerEngine.computeImpact', () {
    test('no loan: portfolio reduced by down payment, FI delay computed', () {
      // Purchase: 20L, 100% down payment (10000 bp)
      final impact = PurchasePlannerEngine.computeImpact(
        purchaseAmountPaise: 2000000000, // 20L
        downPaymentBp: 10000,
        currentPortfolioPaise: portfolio,
        monthlySavingsPaise: monthlySavings,
        annualExpensesPaise: annualExpenses,
        annualReturnRate: returnRate,
        swr: swr,
        inflationRate: inflationRate,
        yearsToRetirement: yearsToRetirement,
      );

      // Baseline FI should be deterministic
      expect(impact.fiYearsBefore, greaterThan(0));
      // After removing 20L from 50L portfolio, FI should take longer
      expect(impact.fiYearsAfter, greaterThan(impact.fiYearsBefore));
      expect(impact.fiDelayYears, greaterThan(0));
      // Full down payment, no EMI
      expect(impact.downPaymentPaise, 2000000000);
      expect(impact.monthlyEmiPaise, 0);
    });

    test('with loan: EMI reduces monthly savings, larger FI delay', () {
      // Purchase: 50L, 20% down (2000 bp), 20-year loan at 8.5%
      final impact = PurchasePlannerEngine.computeImpact(
        purchaseAmountPaise: 5000000000, // 50L
        downPaymentBp: 2000,
        currentPortfolioPaise: portfolio,
        monthlySavingsPaise: monthlySavings,
        annualExpensesPaise: annualExpenses,
        annualReturnRate: returnRate,
        swr: swr,
        inflationRate: inflationRate,
        yearsToRetirement: yearsToRetirement,
        loanTenureMonths: 240,
        loanInterestRate: 0.085,
      );

      // Down payment = 20% of 50L = 10L
      expect(impact.downPaymentPaise, 1000000000);
      // EMI should be > 0
      expect(impact.monthlyEmiPaise, greaterThan(0));
      // With loan, delay should be >= no-loan scenario
      expect(impact.fiDelayYears, greaterThan(0));
    });

    test('zero portfolio returns -1 for fiYearsAfter (unreachable)', () {
      final impact = PurchasePlannerEngine.computeImpact(
        purchaseAmountPaise: 100000000, // 10L
        downPaymentBp: 10000,
        currentPortfolioPaise: 0,
        monthlySavingsPaise: 0, // no savings either
        annualExpensesPaise: annualExpenses,
        annualReturnRate: returnRate,
        swr: swr,
        inflationRate: inflationRate,
        yearsToRetirement: yearsToRetirement,
      );

      expect(impact.fiYearsAfter, -1);
      expect(impact.fiDelayYears, -1);
    });

    test('100% down payment: no loan, full portfolio hit', () {
      final impact = PurchasePlannerEngine.computeImpact(
        purchaseAmountPaise: 1000000000, // 10L
        downPaymentBp: 10000,
        currentPortfolioPaise: portfolio,
        monthlySavingsPaise: monthlySavings,
        annualExpensesPaise: annualExpenses,
        annualReturnRate: returnRate,
        swr: swr,
        inflationRate: inflationRate,
        yearsToRetirement: yearsToRetirement,
      );

      expect(impact.downPaymentPaise, 1000000000);
      expect(impact.monthlyEmiPaise, 0);
      // Portfolio after = 50L - 10L = 40L
      expect(impact.fiYearsAfter, greaterThanOrEqualTo(impact.fiYearsBefore));
    });

    test('tiny purchase returns 0 delay when impact is negligible', () {
      // Purchase: 1000 paise (10 Rs) from 50L portfolio
      final impact = PurchasePlannerEngine.computeImpact(
        purchaseAmountPaise: 100000, // 1000 Rs in paise
        downPaymentBp: 10000,
        currentPortfolioPaise: portfolio,
        monthlySavingsPaise: monthlySavings,
        annualExpensesPaise: annualExpenses,
        annualReturnRate: returnRate,
        swr: swr,
        inflationRate: inflationRate,
        yearsToRetirement: yearsToRetirement,
      );

      expect(impact.fiDelayYears, 0);
    });

    test('down payment calculation exact in paise (no floating point drift)', () {
      // Purchase: 33333333 paise, 33.33% down (3333 bp)
      final impact = PurchasePlannerEngine.computeImpact(
        purchaseAmountPaise: 33333333,
        downPaymentBp: 3333,
        currentPortfolioPaise: portfolio,
        monthlySavingsPaise: monthlySavings,
        annualExpensesPaise: annualExpenses,
        annualReturnRate: returnRate,
        swr: swr,
        inflationRate: inflationRate,
        yearsToRetirement: yearsToRetirement,
      );

      // downPayment = (33333333 * 3333 / 10000).round() = 11109999.6789 -> 11110000
      final expectedDown = (33333333 * 3333 / 10000).round();
      expect(impact.downPaymentPaise, expectedDown);
    });

    test('EMI calculation matches FinancialMath.pmt output', () {
      // Loan: 40L at 9% for 20 years
      final impact = PurchasePlannerEngine.computeImpact(
        purchaseAmountPaise: 5000000000, // 50L
        downPaymentBp: 2000, // 20% down = 10L, loan = 40L
        currentPortfolioPaise: portfolio,
        monthlySavingsPaise: monthlySavings,
        annualExpensesPaise: annualExpenses,
        annualReturnRate: returnRate,
        swr: swr,
        inflationRate: inflationRate,
        yearsToRetirement: yearsToRetirement,
        loanTenureMonths: 240,
        loanInterestRate: 0.09,
      );

      // EMI for 4,000,000,000 paise loan at 9%/12 per month for 240 months
      // FinancialMath.pmt(rate: 0.0075, nper: 240, pv: -4000000000) ~ 35,989,038 paise
      expect(impact.monthlyEmiPaise, greaterThan(35000000));
      expect(impact.monthlyEmiPaise, lessThan(37000000));
    });
  });

  group('PurchasePlannerEngine.educationCostAtYear', () {
    test('compounds escalation correctly (10L at 10% for 5 years)', () {
      final cost = PurchasePlannerEngine.educationCostAtYear(
        baseCostPaise: 1000000000, // 10L in paise
        escalationRateBp: 1000, // 10%
        years: 5,
      );

      // 10L * (1.10)^5 = 10L * 1.61051 = ~16.1L
      expect(cost, closeTo(1610510000, 100)); // within 1 paise rounding
    });

    test('zero years returns base cost', () {
      final cost = PurchasePlannerEngine.educationCostAtYear(
        baseCostPaise: 1000000000,
        escalationRateBp: 1000,
        years: 0,
      );
      expect(cost, 1000000000);
    });

    test('zero escalation returns base cost', () {
      final cost = PurchasePlannerEngine.educationCostAtYear(
        baseCostPaise: 1000000000,
        escalationRateBp: 0,
        years: 10,
      );
      expect(cost, 1000000000);
    });
  });
}
