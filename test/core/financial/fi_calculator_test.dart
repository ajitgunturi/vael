import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/fi_calculator.dart';
import 'package:vael/core/financial/financial_math.dart';

void main() {
  group('FiCalculator', () {
    group('computeFiNumber', () {
      test('returns inflation-adjusted expenses divided by SWR', () {
        // Rs 6L annual expenses, 6% inflation, 3% SWR, 25 years
        final adjusted = FinancialMath.inflationAdjust(
          amount: 60000000,
          rate: 0.06,
          years: 25,
        );
        final expected = (adjusted / 0.03).round();

        final result = FiCalculator.computeFiNumber(
          annualExpensesPaise: 60000000,
          swr: 0.03,
          inflationRate: 0.06,
          yearsToRetirement: 25,
        );
        expect(result, expected);
      });

      test('returns 0 when SWR is zero', () {
        final result = FiCalculator.computeFiNumber(
          annualExpensesPaise: 60000000,
          swr: 0,
          inflationRate: 0.06,
          yearsToRetirement: 25,
        );
        expect(result, 0);
      });

      test('no inflation adjustment when yearsToRetirement is 0', () {
        final result = FiCalculator.computeFiNumber(
          annualExpensesPaise: 60000000,
          swr: 0.03,
          inflationRate: 0.06,
          yearsToRetirement: 0,
        );
        // No inflation: 60000000 / 0.03
        expect(result, (60000000 / 0.03).round());
      });
    });

    group('yearsToFi', () {
      test('returns 0 when portfolio already exceeds FI number', () {
        final result = FiCalculator.yearsToFi(
          currentPortfolioPaise: 5000000000,
          monthlySavingsPaise: 5000000,
          annualReturnRate: 0.10,
          fiNumberPaise: 3200000000,
        );
        expect(result, 0);
      });

      test('returns -1 when savings=0 and rate=0', () {
        final result = FiCalculator.yearsToFi(
          currentPortfolioPaise: 0,
          monthlySavingsPaise: 0,
          annualReturnRate: 0,
          fiNumberPaise: 3200000000,
        );
        expect(result, -1);
      });

      test('returns reasonable years for typical inputs', () {
        // Rs 50K monthly savings, 10% returns, target Rs 3.2Cr
        final result = FiCalculator.yearsToFi(
          currentPortfolioPaise: 0,
          monthlySavingsPaise: 5000000,
          annualReturnRate: 0.10,
          fiNumberPaise: 3200000000,
        );
        expect(result, inInclusiveRange(15, 25));
      });

      test('returns -1 for unreachable target within 100 years', () {
        // Very small savings, huge target
        final result = FiCalculator.yearsToFi(
          currentPortfolioPaise: 0,
          monthlySavingsPaise: 100, // 1 paisa
          annualReturnRate: 0.01,
          fiNumberPaise: 999999999999,
        );
        expect(result, -1);
      });
    });

    group('coastFi', () {
      test('returns PV of FI number at given rate and years', () {
        // FI=3.2Cr, 10% return, 25 years
        final denominator = FinancialMath.power(1.10, 25.0);
        final expected = (3200000000 / denominator).round();

        final result = FiCalculator.coastFi(
          fiNumberPaise: 3200000000,
          annualReturnRate: 0.10,
          yearsToRetirement: 25,
        );
        expect(result, expected);
      });

      test('returns fiNumber when yearsToRetirement is 0', () {
        final result = FiCalculator.coastFi(
          fiNumberPaise: 3200000000,
          annualReturnRate: 0.10,
          yearsToRetirement: 0,
        );
        expect(result, 3200000000);
      });

      test('returns fiNumber when returnRate is 0', () {
        final result = FiCalculator.coastFi(
          fiNumberPaise: 3200000000,
          annualReturnRate: 0,
          yearsToRetirement: 25,
        );
        expect(result, 3200000000);
      });
    });
  });
}
