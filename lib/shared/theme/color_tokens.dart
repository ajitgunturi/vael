import 'dart:ui';

/// Semantic color tokens for financial amounts and status indicators.
///
/// These tokens provide consistent visual meaning across the app:
/// green for positive/income, red for negative/expenses, gray for neutral/zero.
class ColorTokens {
  ColorTokens._();

  /// Green — income, positive amounts, gains.
  static const Color positive = Color(0xFF2E7D32);

  /// Red — expenses, negative amounts, losses.
  static const Color negative = Color(0xFFC62828);

  /// Gray — zero amounts, neutral status.
  static const Color neutral = Color(0xFF757575);
}
