import '../../shared/utils/formatters.dart';

/// Immutable monetary value stored as integer minor units (paise).
///
/// 1 rupee = 100 paise. All arithmetic is exact integer math — no floats.
class Money implements Comparable<Money> {
  final int paise;

  const Money(this.paise);

  /// Creates Money from major (rupees) and optional minor (paise) units.
  const Money.fromMajor(int rupees, [int paise = 0])
      : paise = rupees * 100 + paise;

  static const Money zero = Money(0);

  // -- Arithmetic (returns new instance, immutable) --

  Money operator +(Money other) => Money(paise + other.paise);
  Money operator -(Money other) => Money(paise - other.paise);
  Money operator -() => Money(-paise);

  // -- Comparisons --

  @override
  int compareTo(Money other) => paise.compareTo(other.paise);

  bool operator >(Money other) => paise > other.paise;
  bool operator <(Money other) => paise < other.paise;
  bool operator >=(Money other) => paise >= other.paise;
  bool operator <=(Money other) => paise <= other.paise;

  // -- Predicates --

  bool get isZero => paise == 0;
  bool get isPositive => paise > 0;
  bool get isNegative => paise < 0;

  // -- Formatting (Indian lakh/crore system) --

  /// Returns the formatted string with ₹ symbol and Indian grouping.
  /// Examples: "₹1,00,000.00", "₹0.50", "-₹1,500.75"
  String get formatted {
    final negative = paise < 0;
    final absPaise = paise.abs();
    final rupees = absPaise ~/ 100;
    final minor = absPaise % 100;
    final rupeePart = formatIndianNumber(rupees);
    final paisePart = minor.toString().padLeft(2, '0');
    return '${negative ? '-' : ''}₹$rupeePart.$paisePart';
  }

  // -- Equality --

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Money && other.paise == paise);

  @override
  int get hashCode => paise.hashCode;

  @override
  String toString() => 'Money($paise)';
}
