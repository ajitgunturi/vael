/// Formats an integer using the Indian numbering system (lakh/crore grouping).
///
/// Examples:
///   1000      → "1,000"
///   100000    → "1,00,000"
///   1000000000 → "1,00,00,00,000"
String formatIndianNumber(int value) {
  if (value < 0) return '-${formatIndianNumber(-value)}';

  final str = value.toString();
  final len = str.length;

  if (len <= 3) return str;

  // Last 3 digits get the first comma
  final lastThree = str.substring(len - 3);
  final remaining = str.substring(0, len - 3);

  // Remaining digits grouped in pairs from the right
  final buffer = StringBuffer();
  for (var i = 0; i < remaining.length; i++) {
    final posFromEnd = remaining.length - 1 - i;
    if (i > 0 && posFromEnd.isOdd) {
      buffer.write(',');
    }
    buffer.write(remaining[i]);
  }
  buffer.write(',');
  buffer.write(lastThree);

  return buffer.toString();
}
