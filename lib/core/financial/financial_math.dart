import 'dart:math' as math;

/// Pure financial math functions operating on paise (integer minor units).
///
/// All rate parameters are **periodic** (monthly) rates — the caller is
/// responsible for dividing annual rates by 12 before passing them in.
///
/// Amount parameters and return values are in **paise** (int).
/// Intermediate calculations use double; final results are `.round()`-ed.
///
/// Sign convention follows Excel/TVM: cash outflows are negative,
/// inflows are positive.
class FinancialMath {
  FinancialMath._(); // prevent instantiation

  /// Excel PMT equivalent — periodic payment for a loan or annuity.
  ///
  /// [rate]  periodic interest rate (e.g. annual / 12)
  /// [nper]  total number of periods
  /// [pv]    present value (negative = cash outflow, i.e. loan principal)
  /// [fv]    future value (defaults to 0)
  static int pmt({
    required double rate,
    required int nper,
    required int pv,
    int fv = 0,
  }) {
    if (rate == 0) {
      return (-(pv + fv) / nper).round();
    }
    final r1n = math.pow(1 + rate, nper);
    return (-(pv * r1n + fv) * rate / (r1n - 1)).round();
  }

  /// Excel FV equivalent — future value of a series of payments.
  ///
  /// [rate]  periodic interest rate
  /// [nper]  total number of periods
  /// [pmt]   payment per period (negative = cash outflow)
  /// [pv]    present value (defaults to 0)
  static int fv({
    required double rate,
    required int nper,
    required int pmt,
    int pv = 0,
  }) {
    if (rate == 0) {
      return -(pv + pmt * nper);
    }
    final r1n = math.pow(1 + rate, nper);
    return (-(pv * r1n + pmt * (r1n - 1) / rate)).round();
  }

  /// Excel PV equivalent — present value of a series of future payments.
  ///
  /// [rate]  periodic interest rate
  /// [nper]  total number of periods
  /// [pmt]   payment per period (negative = cash outflow)
  /// [fv]    future value (defaults to 0)
  static int pv({
    required double rate,
    required int nper,
    required int pmt,
    int fv = 0,
  }) {
    if (rate == 0) {
      return -(fv + pmt * nper);
    }
    final r1n = math.pow(1 + rate, nper);
    return (-(fv + pmt * (r1n - 1) / rate) / r1n).round();
  }

  /// Inflation-adjusts an amount using compound growth.
  ///
  /// Returns `amount * (1 + rate) ^ years`, rounded to nearest paise.
  ///
  /// [amount]  base amount in paise
  /// [rate]    annual inflation rate (e.g. 0.06 for 6%)
  /// [years]   number of years
  static int inflationAdjust({
    required int amount,
    required double rate,
    required int years,
  }) {
    if (years == 0 || rate == 0) return amount;
    return (amount * math.pow(1 + rate, years)).round();
  }

  /// Exponentiation with double precision.
  ///
  /// Wrapper around `dart:math pow` for API completeness per BUSINESS_LOGIC.md.
  /// [base] the base value
  /// [exp]  the exponent
  static double power(double base, double exp) =>
      math.pow(base, exp).toDouble();

  /// Monthly SIP amount required to reach a target corpus.
  ///
  /// Derived from the future-value-of-annuity formula:
  /// `SIP = target * r / ((1 + r)^n - 1)`
  ///
  /// [target]  desired corpus in paise
  /// [rate]    periodic (monthly) interest rate
  /// [months]  number of months
  static int requiredSip({
    required int target,
    required double rate,
    required int months,
  }) {
    if (rate == 0) {
      return (target / months).round();
    }
    final r1n = math.pow(1 + rate, months);
    return (target * rate / (r1n - 1)).round();
  }
}
