import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/income_growth_engine.dart';

void main() {
  group('stageForAge', () {
    test('age 25 returns early', () {
      expect(IncomeGrowthEngine.stageForAge(25), CareerStage.early);
    });

    test('age 29 returns early (boundary)', () {
      expect(IncomeGrowthEngine.stageForAge(29), CareerStage.early);
    });

    test('age 30 returns mid (inclusive lower bound)', () {
      expect(IncomeGrowthEngine.stageForAge(30), CareerStage.mid);
    });

    test('age 44 returns mid', () {
      expect(IncomeGrowthEngine.stageForAge(44), CareerStage.mid);
    });

    test('age 45 returns late_', () {
      expect(IncomeGrowthEngine.stageForAge(45), CareerStage.late_);
    });
  });

  group('adjustedGrowthRate', () {
    test('early stage multiplies by 1.2', () {
      final rate = IncomeGrowthEngine.adjustedGrowthRate(
        baseRate: 0.08,
        stage: CareerStage.early,
      );
      expect(rate, closeTo(0.096, 1e-10));
    });

    test('mid stage multiplies by 1.0', () {
      final rate = IncomeGrowthEngine.adjustedGrowthRate(
        baseRate: 0.08,
        stage: CareerStage.mid,
      );
      expect(rate, closeTo(0.08, 1e-10));
    });

    test('late_ stage multiplies by 0.6', () {
      final rate = IncomeGrowthEngine.adjustedGrowthRate(
        baseRate: 0.08,
        stage: CareerStage.late_,
      );
      expect(rate, closeTo(0.048, 1e-10));
    });
  });

  group('buildSalaryTrajectory', () {
    test('produces correct number of flows for age 25 to 60', () {
      final flows = IncomeGrowthEngine.buildSalaryTrajectory(
        currentMonthlySalary: 10000000, // 1 lakh paise
        currentAge: 25,
        retirementAge: 60,
        baseAnnualGrowthRate: 0.08,
      );

      // Age 25-30 (early), 30-45 (mid), 45-60 (late_) = 3 segments
      expect(flows, hasLength(3));
      expect(flows[0].name, 'Salary (early)');
      expect(flows[1].name, 'Salary (mid)');
      expect(flows[2].name, 'Salary (late_)');
    });

    test('age 50 to 60 produces only late_ stage flow', () {
      final flows = IncomeGrowthEngine.buildSalaryTrajectory(
        currentMonthlySalary: 30000000,
        currentAge: 50,
        retirementAge: 60,
        baseAnnualGrowthRate: 0.08,
      );

      expect(flows, hasLength(1));
      expect(flows[0].name, 'Salary (late_)');
      expect(flows[0].durationMonths, 10 * 12); // 10 years
    });

    test('monthly amounts are in paise (integer)', () {
      final flows = IncomeGrowthEngine.buildSalaryTrajectory(
        currentMonthlySalary: 10000000,
        currentAge: 25,
        retirementAge: 60,
        baseAnnualGrowthRate: 0.08,
      );

      for (final flow in flows) {
        expect(flow.monthlyAmount, isA<int>());
        expect(flow.monthlyAmount, greaterThan(0));
      }
    });

    test('flows have annualEscalation matching career-stage-adjusted rate', () {
      final flows = IncomeGrowthEngine.buildSalaryTrajectory(
        currentMonthlySalary: 10000000,
        currentAge: 25,
        retirementAge: 60,
        baseAnnualGrowthRate: 0.08,
      );

      // early: 0.08 * 1.2 = 0.096
      expect(flows[0].annualEscalation, closeTo(0.096, 1e-10));
      // mid: 0.08 * 1.0 = 0.08
      expect(flows[1].annualEscalation, closeTo(0.08, 1e-10));
      // late_: 0.08 * 0.6 = 0.048
      expect(flows[2].annualEscalation, closeTo(0.048, 1e-10));
    });

    test('all flows are marked as income', () {
      final flows = IncomeGrowthEngine.buildSalaryTrajectory(
        currentMonthlySalary: 10000000,
        currentAge: 25,
        retirementAge: 60,
        baseAnnualGrowthRate: 0.08,
      );

      for (final flow in flows) {
        expect(flow.isIncome, isTrue);
      }
    });

    test('total duration months equals years to retirement * 12', () {
      final flows = IncomeGrowthEngine.buildSalaryTrajectory(
        currentMonthlySalary: 10000000,
        currentAge: 25,
        retirementAge: 60,
        baseAnnualGrowthRate: 0.08,
      );

      final totalMonths = flows.fold<int>(
        0,
        (sum, f) => sum + (f.durationMonths ?? 0),
      );
      expect(totalMonths, (60 - 25) * 12);
    });

    test('hikeMonth parameter is accepted (default 4)', () {
      // Verify it doesn't throw and produces valid flows
      final flows = IncomeGrowthEngine.buildSalaryTrajectory(
        currentMonthlySalary: 10000000,
        currentAge: 25,
        retirementAge: 60,
        baseAnnualGrowthRate: 0.08,
        hikeMonth: 7,
      );

      expect(flows, hasLength(3));
    });

    test('salary compounds forward between stages', () {
      final flows = IncomeGrowthEngine.buildSalaryTrajectory(
        currentMonthlySalary: 10000000,
        currentAge: 25,
        retirementAge: 60,
        baseAnnualGrowthRate: 0.08,
      );

      // Second stage salary should be greater than first
      expect(flows[1].monthlyAmount, greaterThan(flows[0].monthlyAmount));
      // Third stage salary should be greater than second
      expect(flows[2].monthlyAmount, greaterThan(flows[1].monthlyAmount));
    });
  });

  group('basis-point helpers', () {
    test('bpToRate(800) returns 0.08', () {
      expect(bpToRate(800), closeTo(0.08, 1e-10));
    });

    test('bpToPercent(800) returns 8.0', () {
      expect(bpToPercent(800), closeTo(8.0, 1e-10));
    });

    test('percentToBp(8.0) returns 800', () {
      expect(percentToBp(8.0), 800);
    });

    test('bpToRate(750) returns 0.075 (non-round rate)', () {
      expect(bpToRate(750), closeTo(0.075, 1e-10));
    });

    test('round-trip: percentToBp(bpToPercent(x)) == x', () {
      expect(percentToBp(bpToPercent(800)), 800);
      expect(percentToBp(bpToPercent(750)), 750);
      expect(percentToBp(bpToPercent(1050)), 1050);
    });
  });
}
