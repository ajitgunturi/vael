/// Responsive breakpoint thresholds for adaptive layout switching.
///
/// - Compact (< 600dp): phone portrait → BottomNavigationBar
/// - Medium (600–900dp): tablet portrait → NavigationRail
/// - Expanded (≥ 900dp): landscape iPad / Mac → NavigationDrawer
class Breakpoints {
  Breakpoints._();

  static const double compact = 600.0;
  static const double medium = 900.0;

  static bool isCompact(double width) => width < compact;
  static bool isMedium(double width) => width >= compact && width < medium;
  static bool isExpanded(double width) => width >= medium;
}
