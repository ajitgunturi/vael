import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/financial_math.dart';

void main() {
  // ---------------------------------------------------------------------------
  // PMT — Excel-equivalent monthly payment calculation
  // ---------------------------------------------------------------------------
  group('FinancialMath.pmt', () {
    test('should_return_emi_for_10L_loan_at_10pct_for_12_months', () {
      // Excel: PMT(0.10/12, 12, -1000000) ≈ 87916 paise (₹879.16)
      final result = FinancialMath.pmt(rate: 0.10 / 12, nper: 12, pv: -1000000);
      expect(result, 87916);
    });

    test('should_return_emi_for_50L_loan_at_8_5pct_for_240_months', () {
      // Excel: PMT(0.085/12, 240, -5000000)
      final result = FinancialMath.pmt(
        rate: 0.085 / 12,
        nper: 240,
        pv: -5000000,
      );
      expect(result, 43391);
    });

    test('should_handle_zero_rate_by_dividing_evenly', () {
      // 0% interest: simple division = 100000 / 12 = 8333 paise
      final result = FinancialMath.pmt(rate: 0, nper: 12, pv: -100000);
      expect(result, 8333);
    });

    test('should_default_fv_to_zero', () {
      // Same as first test — fv defaults to 0
      final result = FinancialMath.pmt(rate: 0.10 / 12, nper: 12, pv: -1000000);
      expect(result, 87916);
    });
  });

  // ---------------------------------------------------------------------------
  // FV — Future Value
  // ---------------------------------------------------------------------------
  group('FinancialMath.fv', () {
    test('should_return_fv_of_5000_per_month_at_12pct_for_60_months', () {
      // Excel: FV(0.01, 60, -5000) — monthly rate = 12%/12 = 1%
      final result = FinancialMath.fv(rate: 0.01, nper: 60, pmt: -5000);
      // FV = 5000 * ((1.01^60 - 1) / 0.01)
      expect(result, 408348);
    });

    test('should_handle_zero_rate', () {
      // 0% rate: FV = -(pmt * nper) = -((-1000) * 12) = 12000
      final result = FinancialMath.fv(rate: 0, nper: 12, pmt: -1000);
      expect(result, 12000);
    });
  });

  // ---------------------------------------------------------------------------
  // PV — Present Value
  // ---------------------------------------------------------------------------
  group('FinancialMath.pv', () {
    test('should_return_pv_of_10000_per_month_for_24_months_at_10pct', () {
      // Excel: PV(0.10/12, 24, -10000)
      final result = FinancialMath.pv(rate: 0.10 / 12, nper: 24, pmt: -10000);
      expect(result, 216709);
    });

    test('should_handle_zero_rate', () {
      // 0% rate: PV = -(pmt * nper) = -((-10000) * 24) = 240000
      final result = FinancialMath.pv(rate: 0, nper: 24, pmt: -10000);
      expect(result, 240000);
    });
  });

  // ---------------------------------------------------------------------------
  // inflationAdjust — compound growth
  // ---------------------------------------------------------------------------
  group('FinancialMath.inflationAdjust', () {
    test('should_compound_100000_at_6pct_for_10_years', () {
      // 100000 * (1.06)^10 = 179084.769... → 179085 rounded
      final result = FinancialMath.inflationAdjust(
        amount: 100000,
        rate: 0.06,
        years: 10,
      );
      expect(result, 179085);
    });

    test('should_return_original_amount_for_zero_years', () {
      final result = FinancialMath.inflationAdjust(
        amount: 100000,
        rate: 0.06,
        years: 0,
      );
      expect(result, 100000);
    });

    test('should_return_original_amount_for_zero_rate', () {
      final result = FinancialMath.inflationAdjust(
        amount: 100000,
        rate: 0,
        years: 10,
      );
      expect(result, 100000);
    });
  });

  // ---------------------------------------------------------------------------
  // requiredSip — monthly SIP to reach a target corpus
  // ---------------------------------------------------------------------------
  group('FinancialMath.requiredSip', () {
    test('should_return_sip_for_10L_target_at_12pct_in_36_months', () {
      // SIP = target * r / ((1+r)^n - 1), r = 0.12/12 = 0.01
      // = 1000000 * 0.01 / (1.01^36 - 1) = 10000 / 0.43077 ≈ 23214
      final result = FinancialMath.requiredSip(
        target: 1000000,
        rate: 0.12 / 12,
        months: 36,
      );
      expect(result, 23214);
    });

    test('should_handle_zero_rate', () {
      // 0% rate: SIP = target / months = 1000000 / 36 = 27778 rounded
      final result = FinancialMath.requiredSip(
        target: 1000000,
        rate: 0,
        months: 36,
      );
      expect(result, 27778);
    });
  });
}
