/// Spacing constants from `UI_DESIGN.md` §1.4.
///
/// Usage: `SizedBox(height: Spacing.md)`, `EdgeInsets.all(Spacing.sm)`.
class Spacing {
  Spacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Card corner radius — 12dp per spec §1.4.
  static const double cardRadius = 12;
}
