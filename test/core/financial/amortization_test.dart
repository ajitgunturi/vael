import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/amortization.dart';
import 'package:vael/core/financial/amortization_row.dart';
import 'package:vael/core/financial/financial_math.dart';

void main() {
  group('AmortizationCalculator — basic 10L/10%/12mo schedule', () {
    late List<AmortizationRow> schedule;
    late int emi;

    setUp(() {
      // 10,00,000 paise = ₹10,000 principal, 10% annual, 12 months
      // Using TVM convention: PV is negative (cash outflow for a loan)
      emi = FinancialMath.pmt(rate: 0.10 / 12, nper: 12, pv: -1000000);
      schedule = AmortizationCalculator.generateSchedule(
        principal: 1000000,
        annualRate: 0.10,
        tenureMonths: 12,
      );
    });

    test('EMI should match FinancialMath.pmt result', () {
      // Every row's EMI should equal the computed PMT value
      // (last row may differ slightly due to rounding adjustment)
      for (var i = 0; i < schedule.length - 1; i++) {
        expect(
          schedule[i].emi,
          equals(emi),
          reason: 'EMI mismatch at month ${schedule[i].month}',
        );
      }
    });

    test('schedule should have exactly 12 rows', () {
      expect(schedule.length, equals(12));
    });

    test('sum of all principal components should equal original loan', () {
      final totalPrincipal = schedule.fold<int>(
        0,
        (sum, row) => sum + row.principal,
      );
      // Allow 1 paisa tolerance for rounding
      expect((totalPrincipal - 1000000).abs(), lessThanOrEqualTo(1));
    });

    test('each row has correct fields populated', () {
      for (final row in schedule) {
        expect(row.month, greaterThan(0));
        expect(row.emi, greaterThan(0));
        expect(row.principal, greaterThan(0));
        expect(row.interest, greaterThanOrEqualTo(0));
        expect(row.prepayment, equals(0));
        expect(row.outstanding, greaterThanOrEqualTo(0));
      }
    });

    test('last row outstanding should be 0 (within 1 paisa tolerance)', () {
      expect(schedule.last.outstanding, lessThanOrEqualTo(1));
    });

    test('outstanding decreases monotonically', () {
      for (var i = 1; i < schedule.length; i++) {
        expect(
          schedule[i].outstanding,
          lessThan(schedule[i - 1].outstanding + schedule[i - 1].prepayment),
          reason: 'Outstanding did not decrease at month ${schedule[i].month}',
        );
      }
    });

    test('interest component decreases over time', () {
      for (var i = 1; i < schedule.length; i++) {
        expect(
          schedule[i].interest,
          lessThanOrEqualTo(schedule[i - 1].interest),
          reason: 'Interest did not decrease at month ${schedule[i].month}',
        );
      }
    });
  });

  group('AmortizationCalculator — prepayment at month 6', () {
    late List<AmortizationRow> baseSchedule;
    late List<AmortizationRow> prepaySchedule;

    setUp(() {
      baseSchedule = AmortizationCalculator.generateSchedule(
        principal: 1000000,
        annualRate: 0.10,
        tenureMonths: 12,
      );
      prepaySchedule = AmortizationCalculator.generateSchedule(
        principal: 1000000,
        annualRate: 0.10,
        tenureMonths: 12,
        prepayments: {6: 200000},
      );
    });

    test('schedule should terminate early (fewer than 12 months)', () {
      expect(prepaySchedule.length, lessThan(12));
    });

    test('total interest paid should be less than base schedule', () {
      final baseInterest = baseSchedule.fold<int>(
        0,
        (sum, row) => sum + row.interest,
      );
      final prepayInterest = prepaySchedule.fold<int>(
        0,
        (sum, row) => sum + row.interest,
      );
      expect(prepayInterest, lessThan(baseInterest));
    });

    test('prepayment appears in month 6 row', () {
      final month6 = prepaySchedule.firstWhere((r) => r.month == 6);
      expect(month6.prepayment, equals(200000));
    });

    test(
      'sum of principal + prepayments equals original loan (within 1 paisa)',
      () {
        final totalPrincipal = prepaySchedule.fold<int>(
          0,
          (sum, r) => sum + r.principal,
        );
        final totalPrepay = prepaySchedule.fold<int>(
          0,
          (sum, r) => sum + r.prepayment,
        );
        expect(
          (totalPrincipal + totalPrepay - 1000000).abs(),
          lessThanOrEqualTo(1),
        );
      },
    );
  });

  group('AmortizationCalculator — multiple prepayments', () {
    late List<AmortizationRow> singlePrepay;
    late List<AmortizationRow> multiPrepay;

    setUp(() {
      singlePrepay = AmortizationCalculator.generateSchedule(
        principal: 1000000,
        annualRate: 0.10,
        tenureMonths: 12,
        prepayments: {6: 200000},
      );
      multiPrepay = AmortizationCalculator.generateSchedule(
        principal: 1000000,
        annualRate: 0.10,
        tenureMonths: 12,
        prepayments: {3: 200000, 6: 200000},
      );
    });

    test('schedule with two prepayments terminates earlier than one', () {
      expect(multiPrepay.length, lessThan(singlePrepay.length));
    });

    test('total interest with two prepayments is less than one', () {
      final singleInterest = singlePrepay.fold<int>(
        0,
        (sum, r) => sum + r.interest,
      );
      final multiInterest = multiPrepay.fold<int>(
        0,
        (sum, r) => sum + r.interest,
      );
      expect(multiInterest, lessThan(singleInterest));
    });
  });

  group('AmortizationCalculator — 0% rate edge case', () {
    late List<AmortizationRow> schedule;

    setUp(() {
      // 1,00,000 paise at 0% for 10 months = 10,000 per month
      schedule = AmortizationCalculator.generateSchedule(
        principal: 100000,
        annualRate: 0.0,
        tenureMonths: 10,
      );
    });

    test('EMI should be 10,000 paise', () {
      for (final row in schedule) {
        expect(row.emi, equals(10000));
      }
    });

    test('all interest components should be 0', () {
      for (final row in schedule) {
        expect(row.interest, equals(0));
      }
    });

    test('all principal components equal EMI', () {
      for (final row in schedule) {
        expect(row.principal, equals(row.emi));
      }
    });

    test('schedule should have 10 rows', () {
      expect(schedule.length, equals(10));
    });

    test('last row outstanding is 0', () {
      expect(schedule.last.outstanding, equals(0));
    });
  });

  group('AmortizationCalculator — enrichment', () {
    late List<AmortizationRow> baseSchedule;
    late List<AmortizationRow> prepaySchedule;
    late AmortizationEnrichment baseEnrichment;
    late AmortizationEnrichment prepayEnrichment;

    setUp(() {
      baseSchedule = AmortizationCalculator.generateSchedule(
        principal: 1000000,
        annualRate: 0.10,
        tenureMonths: 12,
      );
      prepaySchedule = AmortizationCalculator.generateSchedule(
        principal: 1000000,
        annualRate: 0.10,
        tenureMonths: 12,
        prepayments: {6: 200000},
      );
      baseEnrichment = AmortizationCalculator.enrich(baseSchedule);
      prepayEnrichment = AmortizationCalculator.enrich(prepaySchedule);
    });

    test('remainingTenure from month 0 equals full schedule length', () {
      final enrichment = AmortizationCalculator.enrich(
        baseSchedule,
        fromMonth: 0,
      );
      expect(enrichment.remainingTenure, equals(12));
    });

    test('remainingTenure from month 6 equals remaining rows', () {
      final enrichment = AmortizationCalculator.enrich(
        baseSchedule,
        fromMonth: 6,
      );
      expect(enrichment.remainingTenure, equals(6));
    });

    test('totalInterestRemaining sums future interest', () {
      final totalInterest = baseSchedule.fold<int>(
        0,
        (sum, r) => sum + r.interest,
      );
      final enrichFrom0 = AmortizationCalculator.enrich(
        baseSchedule,
        fromMonth: 0,
      );
      expect(enrichFrom0.totalInterestRemaining, equals(totalInterest));
    });

    test('totalPrepaidPrincipal is 0 for base schedule', () {
      expect(baseEnrichment.totalPrepaidPrincipal, equals(0));
    });

    test('totalPrepaidPrincipal equals 200000 for prepay schedule', () {
      expect(prepayEnrichment.totalPrepaidPrincipal, equals(200000));
    });

    test('totalInterestSaved is positive when comparing prepay to base', () {
      final saved = AmortizationCalculator.interestSaved(
        baseSchedule: baseSchedule,
        prepaySchedule: prepaySchedule,
      );
      expect(saved, greaterThan(0));
    });

    test('totalInterestSaved equals difference in total interest', () {
      final baseInterest = baseSchedule.fold<int>(
        0,
        (sum, r) => sum + r.interest,
      );
      final prepayInterest = prepaySchedule.fold<int>(
        0,
        (sum, r) => sum + r.interest,
      );
      final saved = AmortizationCalculator.interestSaved(
        baseSchedule: baseSchedule,
        prepaySchedule: prepaySchedule,
      );
      expect(saved, equals(baseInterest - prepayInterest));
    });

    test('nextPaymentBreakdown returns first future row', () {
      final enrichFrom3 = AmortizationCalculator.enrich(
        baseSchedule,
        fromMonth: 3,
      );
      // Month 4 is the next payment after month 3
      final month4 = baseSchedule.firstWhere((r) => r.month == 4);
      expect(enrichFrom3.nextPrincipal, equals(month4.principal));
      expect(enrichFrom3.nextInterest, equals(month4.interest));
    });
  });
}
