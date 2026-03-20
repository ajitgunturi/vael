/// A single row in a loan amortization schedule.
///
/// All monetary values are in **paise** (integer minor units).
class AmortizationRow {
  /// 1-based month number within the schedule.
  final int month;

  /// EMI paid this month (paise).
  final int emi;

  /// Principal component of this month's payment (paise).
  final int principal;

  /// Interest component of this month's payment (paise).
  final int interest;

  /// Any extra prepayment applied this month (paise).
  final int prepayment;

  /// Outstanding balance after this month's payment and prepayment (paise).
  final int outstanding;

  const AmortizationRow({
    required this.month,
    required this.emi,
    required this.principal,
    required this.interest,
    required this.prepayment,
    required this.outstanding,
  });

  @override
  String toString() =>
      'AmortizationRow(month=$month, emi=$emi, principal=$principal, '
      'interest=$interest, prepayment=$prepayment, outstanding=$outstanding)';
}
