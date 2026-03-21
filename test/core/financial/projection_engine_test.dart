import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/projection_engine.dart';

void main() {
  group('ProjectionEngine', () {
    group('basic projection', () {
      test('should produce 60 monthly snapshots by default', () {
        final result = ProjectionEngine.project(
          startingNetWorth: 100000000, // ₹10,00,000
          monthlyIncome: 15000000, // ₹1,50,000
          monthlyExpenses: 10000000, // ₹1,00,000
        );

        expect(result.months.length, 60);
        expect(result.months.first.month, 1);
        expect(result.months.last.month, 60);
      });

      test('should allow custom horizon', () {
        final result = ProjectionEngine.project(
          startingNetWorth: 100000000,
          monthlyIncome: 15000000,
          monthlyExpenses: 10000000,
          horizonMonths: 24,
        );

        expect(result.months.length, 24);
      });

      test('should accumulate net savings each month with zero rates', () {
        final result = ProjectionEngine.project(
          startingNetWorth: 0,
          monthlyIncome: 10000000, // ₹1,00,000
          monthlyExpenses: 6000000, // ₹60,000
          investmentReturnRate: 0,
          expenseGrowthRate: 0,
          incomeGrowthRate: 0,
          horizonMonths: 12,
        );

        // Net savings = ₹40,000/month = 40,00,000 paise
        // Month 1: 40,00,000; Month 12: 4,80,00,000
        expect(result.months[0].netWorth, 4000000);
        expect(result.months[11].netWorth, 48000000);
      });

      test('should start from given starting net worth', () {
        final result = ProjectionEngine.project(
          startingNetWorth: 50000000, // ₹5,00,000
          monthlyIncome: 10000000,
          monthlyExpenses: 10000000, // break even
          investmentReturnRate: 0,
          expenseGrowthRate: 0,
          incomeGrowthRate: 0,
          horizonMonths: 6,
        );

        // No change — income equals expenses
        for (final m in result.months) {
          expect(m.netWorth, 50000000);
        }
      });
    });

    group('investment returns', () {
      test('should compound returns on accumulated assets', () {
        final result = ProjectionEngine.project(
          startingNetWorth: 100000000, // ₹10L
          monthlyIncome: 0,
          monthlyExpenses: 0,
          investmentReturnRate: 0.12, // 12% annual
          expenseGrowthRate: 0,
          incomeGrowthRate: 0,
          horizonMonths: 12,
        );

        // Monthly rate = 0.12/12 = 0.01
        // After 12 months: ₹10L = 100000000p * (1.01)^12 ≈ ₹11,26,825
        final finalNW = result.months.last.netWorth;
        // Allow ₹1 tolerance for rounding
        expect(finalNW, closeTo(112682503, 10000));
      });
    });

    group('expense growth', () {
      test('should grow expenses annually', () {
        final result = ProjectionEngine.project(
          startingNetWorth: 0,
          monthlyIncome: 10000000, // ₹1L
          monthlyExpenses: 5000000, // ₹50K
          investmentReturnRate: 0,
          expenseGrowthRate: 0.10, // 10% annual
          incomeGrowthRate: 0,
          horizonMonths: 24,
        );

        // Month 1: expenses = 50K, savings = 50K
        expect(result.months[0].monthlyExpenses, 5000000);
        // Month 13 (year 2): expenses = 55K (50K * 1.10)
        expect(result.months[12].monthlyExpenses, 5500000);
      });
    });

    group('income growth', () {
      test('should grow income annually', () {
        final result = ProjectionEngine.project(
          startingNetWorth: 0,
          monthlyIncome: 10000000, // ₹1L
          monthlyExpenses: 5000000,
          investmentReturnRate: 0,
          expenseGrowthRate: 0,
          incomeGrowthRate: 0.10, // 10% annual hike
          horizonMonths: 24,
        );

        expect(result.months[0].monthlyIncome, 10000000);
        // Year 2: 1L * 1.10 = 1.1L
        expect(result.months[12].monthlyIncome, 11000000);
      });
    });

    group('loan EMI deductions', () {
      test('should deduct EMI from monthly cash flow', () {
        final result = ProjectionEngine.project(
          startingNetWorth: 0,
          monthlyIncome: 10000000, // ₹1L
          monthlyExpenses: 5000000, // ₹50K
          monthlyEmi: 2000000, // ₹20K
          investmentReturnRate: 0,
          expenseGrowthRate: 0,
          incomeGrowthRate: 0,
          horizonMonths: 6,
        );

        // Net savings = 1L - 50K - 20K = 30K = 30,00,000 paise
        expect(result.months[0].netWorth, 3000000);
        expect(result.months[5].netWorth, 18000000);
      });

      test('should stop EMI after remaining tenure exhausted', () {
        final result = ProjectionEngine.project(
          startingNetWorth: 0,
          monthlyIncome: 10000000,
          monthlyExpenses: 5000000,
          monthlyEmi: 2000000,
          emiRemainingMonths: 3,
          investmentReturnRate: 0,
          expenseGrowthRate: 0,
          incomeGrowthRate: 0,
          horizonMonths: 6,
        );

        // Months 1-3: savings = 30K; months 4-6: savings = 50K
        // Month 3 NW: 90L paise = 9000000
        expect(result.months[2].netWorth, 9000000);
        // Month 6 NW: 9000000 + 3*5000000 = 24000000
        expect(result.months[5].netWorth, 24000000);
      });
    });

    group('three scenarios', () {
      test('should produce optimistic/base/pessimistic projections', () {
        final scenarios = ProjectionEngine.threeScenarios(
          startingNetWorth: 100000000,
          monthlyIncome: 15000000,
          monthlyExpenses: 10000000,
          baseReturnRate: 0.12,
          baseExpenseGrowth: 0.06,
          baseIncomeGrowth: 0.08,
        );

        expect(scenarios.optimistic.months.length, 60);
        expect(scenarios.base.months.length, 60);
        expect(scenarios.pessimistic.months.length, 60);

        final optFinal = scenarios.optimistic.months.last.netWorth;
        final baseFinal = scenarios.base.months.last.netWorth;
        final pessFinal = scenarios.pessimistic.months.last.netWorth;

        // Optimistic > base > pessimistic
        expect(optFinal, greaterThan(baseFinal));
        expect(baseFinal, greaterThan(pessFinal));
      });

      test('should use +2%/-2% return rate spread for scenarios', () {
        final scenarios = ProjectionEngine.threeScenarios(
          startingNetWorth: 100000000,
          monthlyIncome: 0,
          monthlyExpenses: 0,
          baseReturnRate: 0.12,
          baseExpenseGrowth: 0,
          baseIncomeGrowth: 0,
        );

        // Verify optimistic uses higher return, pessimistic lower
        // With 10L and no income/expenses, after 60m:
        // Base: 10L * (1 + 0.12/12)^60
        // Optimistic: 10L * (1 + 0.14/12)^60
        // Pessimistic: 10L * (1 + 0.10/12)^60
        final optFinal = scenarios.optimistic.months.last.netWorth;
        final baseFinal = scenarios.base.months.last.netWorth;
        final pessFinal = scenarios.pessimistic.months.last.netWorth;

        expect(optFinal, greaterThan(baseFinal));
        expect(baseFinal, greaterThan(pessFinal));
      });
    });

    group('projection snapshot fields', () {
      test('should track monthly income, expenses, and savings', () {
        final result = ProjectionEngine.project(
          startingNetWorth: 0,
          monthlyIncome: 10000000,
          monthlyExpenses: 6000000,
          investmentReturnRate: 0,
          expenseGrowthRate: 0,
          incomeGrowthRate: 0,
          horizonMonths: 3,
        );

        for (final m in result.months) {
          expect(m.monthlyIncome, 10000000);
          expect(m.monthlyExpenses, 6000000);
          expect(m.monthlySavings, 4000000);
        }
      });
    });

    group('edge cases', () {
      test('should handle zero income (drawdown scenario)', () {
        final result = ProjectionEngine.project(
          startingNetWorth: 50000000, // ₹5L
          monthlyIncome: 0,
          monthlyExpenses: 5000000, // ₹50K
          investmentReturnRate: 0,
          expenseGrowthRate: 0,
          incomeGrowthRate: 0,
          horizonMonths: 12,
        );

        // Draws down 50K/month
        expect(result.months[9].netWorth, 0);
        // Goes negative
        expect(result.months[11].netWorth, -10000000);
      });

      test('should handle negative starting net worth', () {
        final result = ProjectionEngine.project(
          startingNetWorth: -20000000, // -₹2L (net debt)
          monthlyIncome: 10000000,
          monthlyExpenses: 5000000,
          investmentReturnRate: 0,
          expenseGrowthRate: 0,
          incomeGrowthRate: 0,
          horizonMonths: 6,
        );

        // Saving 50K/month from -2L
        expect(result.months[0].netWorth, -15000000);
        expect(result.months[3].netWorth, 0);
      });
    });
  });
}
