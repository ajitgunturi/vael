/// Utility for closed-period enforcement.
///
/// A closed period prevents edits to transactions before a given date.
/// The enforcement point is in DAO writes — this class provides the
/// pure date-check building block.
class ClosedPeriod {
  ClosedPeriod._();

  /// Returns `true` if [date] falls before [closedBefore].
  ///
  /// If [closedBefore] is null, no period is closed and this returns `false`.
  static bool isInClosedPeriod(DateTime date, DateTime? closedBefore) {
    if (closedBefore == null) return false;
    return date.isBefore(closedBefore);
  }
}
