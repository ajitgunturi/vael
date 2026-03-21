import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/features/loans/providers/loan_providers.dart';

void main() {
  LoanDetail _makeLoan({
    int principal = 5000000000,
    double annualRate = 0.085,
    int tenureMonths = 240,
  }) {
    return LoanDetail(
      id: 'ld1',
      accountId: 'acc_loan',
      principal: principal,
      annualRate: annualRate,
      tenureMonths: tenureMonths,
      outstandingPrincipal: principal,
      emiAmount: 0,
      startDate: DateTime(2023, 1, 1),
      disbursementDate: null,
      familyId: 'fam_a',
    );
  }

  group('PrepaymentSimulation', () {
    test('prepayment reduces total tenure', () {
      final loan = _makeLoan();
      final sim = simulatePrepayment(
        loan: loan,
        prepaymentAmount: 500000000, // ₹50,00,000 prepayment
        atMonth: 12,
      );

      // With a large prepayment at month 12, tenure should reduce
      expect(sim.newTenureMonths, lessThan(240));
    });

    test('prepayment saves interest', () {
      final loan = _makeLoan();
      final sim = simulatePrepayment(
        loan: loan,
        prepaymentAmount: 500000000,
        atMonth: 12,
      );

      expect(sim.interestSaved, greaterThan(0));
    });

    test('zero prepayment produces no savings', () {
      final loan = _makeLoan();
      final sim = simulatePrepayment(
        loan: loan,
        prepaymentAmount: 0,
        atMonth: 12,
      );

      expect(sim.interestSaved, 0);
      expect(sim.newTenureMonths, loan.tenureMonths);
    });

    test('early prepayment saves more than late prepayment', () {
      final loan = _makeLoan();
      final earlyPrepay = simulatePrepayment(
        loan: loan,
        prepaymentAmount: 200000000,
        atMonth: 6,
      );
      final latePrepay = simulatePrepayment(
        loan: loan,
        prepaymentAmount: 200000000,
        atMonth: 120,
      );

      expect(earlyPrepay.interestSaved, greaterThan(latePrepay.interestSaved));
    });
  });
}
