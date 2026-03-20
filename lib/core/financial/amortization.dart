import 'amortization_row.dart';
import 'financial_math.dart';

/// Enrichment data computed from a generated amortization schedule.
class AmortizationEnrichment {
  /// Number of remaining monthly payments from the given reference month.
  final int remainingTenure;

  /// Sum of future interest components from the reference month (paise).
  final int totalInterestRemaining;

  /// Sum of all prepayments in the schedule (paise).
  final int totalPrepaidPrincipal;

  /// Principal component of the next payment (paise), or 0 if none.
  final int nextPrincipal;

  /// Interest component of the next payment (paise), or 0 if none.
  final int nextInterest;

  const AmortizationEnrichment({
    required this.remainingTenure,
    required this.totalInterestRemaining,
    required this.totalPrepaidPrincipal,
    required this.nextPrincipal,
    required this.nextInterest,
  });
}

/// Generates and enriches loan amortization schedules.
///
/// All monetary values are in **paise** (integer minor units).
/// Rates are doubles used only for intermediate math; results are rounded.
class AmortizationCalculator {
  AmortizationCalculator._();

  /// Tolerance for considering the loan fully repaid: 1 paisa.
  static const int _tolerance = 1;

  /// Generates a month-by-month amortization schedule.
  ///
  /// [principal]    loan amount in paise
  /// [annualRate]   annual interest rate as a decimal (e.g. 0.10 for 10%)
  /// [tenureMonths] original loan tenure in months
  /// [prepayments]  optional map of {month: amount in paise} for lump-sum
  ///                prepayments applied at the end of that month
  static List<AmortizationRow> generateSchedule({
    required int principal,
    required double annualRate,
    required int tenureMonths,
    Map<int, int> prepayments = const {},
  }) {
    final monthlyRate = annualRate / 12;

    // EMI from TVM: pv is negative (cash outflow for the borrower)
    final emi = FinancialMath.pmt(
      rate: monthlyRate,
      nper: tenureMonths,
      pv: -principal,
    );

    final rows = <AmortizationRow>[];
    var outstanding = principal.toDouble();

    for (var month = 1; month <= tenureMonths; month++) {
      if (outstanding <= _tolerance) break;

      final interestComponent = (outstanding * monthlyRate).round();
      var principalComponent = emi - interestComponent;

      // On the last effective payment, cap principal to whatever is left
      if (principalComponent > outstanding.round()) {
        principalComponent = outstanding.round();
      }

      final prepayment = prepayments[month] ?? 0;
      var newOutstanding =
          outstanding - principalComponent.toDouble() - prepayment.toDouble();

      // Clamp to zero to avoid negative dust
      if (newOutstanding < 0) newOutstanding = 0;

      // If after prepayment the outstanding is tiny, absorb into principal
      if (newOutstanding <= _tolerance && newOutstanding > 0) {
        principalComponent += newOutstanding.round();
        newOutstanding = 0;
      }

      rows.add(AmortizationRow(
        month: month,
        emi: interestComponent + principalComponent,
        principal: principalComponent,
        interest: interestComponent,
        prepayment: prepayment,
        outstanding: newOutstanding.round(),
      ));

      outstanding = newOutstanding;
    }

    return rows;
  }

  /// Computes enrichment data for a schedule from a given reference month.
  ///
  /// [fromMonth] is 0-based: 0 means "from the start" (all months are future),
  /// 6 means "months 7+ are future."
  static AmortizationEnrichment enrich(
    List<AmortizationRow> schedule, {
    int fromMonth = 0,
  }) {
    final futureRows =
        schedule.where((r) => r.month > fromMonth).toList();

    final remainingTenure = futureRows.length;

    final totalInterestRemaining =
        futureRows.fold<int>(0, (sum, r) => sum + r.interest);

    final totalPrepaidPrincipal =
        schedule.fold<int>(0, (sum, r) => sum + r.prepayment);

    final nextPrincipal =
        futureRows.isNotEmpty ? futureRows.first.principal : 0;
    final nextInterest =
        futureRows.isNotEmpty ? futureRows.first.interest : 0;

    return AmortizationEnrichment(
      remainingTenure: remainingTenure,
      totalInterestRemaining: totalInterestRemaining,
      totalPrepaidPrincipal: totalPrepaidPrincipal,
      nextPrincipal: nextPrincipal,
      nextInterest: nextInterest,
    );
  }

  /// Calculates total interest saved by comparing two schedules (paise).
  ///
  /// Typically [baseSchedule] is without prepayments and [prepaySchedule]
  /// includes prepayments, so the result is the interest difference.
  static int interestSaved({
    required List<AmortizationRow> baseSchedule,
    required List<AmortizationRow> prepaySchedule,
  }) {
    final baseInterest =
        baseSchedule.fold<int>(0, (sum, r) => sum + r.interest);
    final prepayInterest =
        prepaySchedule.fold<int>(0, (sum, r) => sum + r.interest);
    return baseInterest - prepayInterest;
  }
}
