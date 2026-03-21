import 'package:flutter/material.dart';

/// Full semantic color token set from `docs/UI_DESIGN.md` §1.1.
///
/// Usage: `final colors = ColorTokens.of(context);`
/// Then access tokens like `colors.income`, `colors.surface`, etc.
///
/// Never use raw hex in widgets — always go through this token layer.
/// Light/dark resolution is automatic based on [Theme.of(context).brightness].
class ColorTokens {
  const ColorTokens._({
    // Surface
    required this.surface,
    required this.surfaceDim,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.inverseSurface,
    // Text
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.onSurfaceDisabled,
    required this.inverseOnSurface,
    // Semantic
    required this.income,
    required this.incomeContainer,
    required this.onIncomeContainer,
    required this.expense,
    required this.expenseContainer,
    required this.onExpenseContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.neutral,
    // Action
    required this.primary,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.outline,
    required this.outlineVariant,
    // Chart
    required this.chartLine1,
    required this.chartLine2,
    required this.chartLine3,
    required this.chartFill1,
    required this.chartGrid,
    required this.chartTooltipBg,
  });

  // ── Surface ──
  final Color surface;
  final Color surfaceDim;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color inverseSurface;

  // ── Text ──
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color onSurfaceDisabled;
  final Color inverseOnSurface;

  // ── Semantic ──
  final Color income;
  final Color incomeContainer;
  final Color onIncomeContainer;
  final Color expense;
  final Color expenseContainer;
  final Color onExpenseContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color neutral;

  // ── Action ──
  final Color primary;
  final Color primaryContainer;
  final Color onPrimary;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color outline;
  final Color outlineVariant;

  // ── Chart ──
  final Color chartLine1;
  final Color chartLine2;
  final Color chartLine3;
  final Color chartFill1;
  final Color chartGrid;
  final Color chartTooltipBg;

  // ── Deprecated legacy statics (backward compat with Phase 2 code) ──
  // These return hardcoded light-mode values matching the old Phase 1 constants.
  // Migrate to ColorTokens.of(context).income / .expense / .neutral.

  @Deprecated('Use ColorTokens.of(context).income instead')
  static const Color positive = Color(0xFF2E7D32);

  @Deprecated('Use ColorTokens.of(context).expense instead')
  static const Color negative = Color(0xFFC62828);

  @Deprecated('Use ColorTokens.of(context).neutral instead')
  static const Color neutralStatic = Color(0xFF757575);

  /// Resolve tokens for the current theme brightness.
  static ColorTokens of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark() : light();
  }

  /// Light theme token set — `UI_DESIGN.md` §1.1.
  static ColorTokens light() => const ColorTokens._(
        // Surface
        surface: Color(0xFFFAFAF9),
        surfaceDim: Color(0xFFF0EFED),
        surfaceContainer: Color(0xFFF2F1EF),
        surfaceContainerHigh: Color(0xFFE8E7E5),
        surfaceContainerHighest: Color(0xFFDEDDDB),
        inverseSurface: Color(0xFF1A1A1A),
        // Text
        onSurface: Color(0xFF1A1A1A),
        onSurfaceVariant: Color(0xFF6B6B6B),
        onSurfaceDisabled: Color(0xFFB0B0B0),
        inverseOnSurface: Color(0xFFF5F5F5),
        // Semantic
        income: Color(0xFF2D7A2D),
        incomeContainer: Color(0xFFE8F5E3),
        onIncomeContainer: Color(0xFF1A4A1A),
        expense: Color(0xFFB3261E),
        expenseContainer: Color(0xFFFCECEA),
        onExpenseContainer: Color(0xFF6E1610),
        warning: Color(0xFF8B6914),
        warningContainer: Color(0xFFFFF3D6),
        onWarningContainer: Color(0xFF5C4400),
        neutral: Color(0xFF6B6B6B),
        // Action
        primary: Color(0xFF2D5A27),
        primaryContainer: Color(0xFFD4EDCF),
        onPrimary: Color(0xFFFFFFFF),
        onPrimaryContainer: Color(0xFF0A1A08),
        secondary: Color(0xFF1A4A7A),
        outline: Color(0xFFD4D3D1),
        outlineVariant: Color(0xFFEDEDEB),
        // Chart
        chartLine1: Color(0xFF2D5A27),
        chartLine2: Color(0xFFB3261E),
        chartLine3: Color(0xFF1A4A7A),
        chartFill1: Color(0x202D5A27),
        chartGrid: Color(0xFFEDEDEB),
        chartTooltipBg: Color(0xFF1A1A1A),
      );

  /// Dark theme token set — `UI_DESIGN.md` §1.1.
  static ColorTokens dark() => const ColorTokens._(
        // Surface
        surface: Color(0xFF0F0F0F),
        surfaceDim: Color(0xFF0F0F0F),
        surfaceContainer: Color(0xFF1A1A1A),
        surfaceContainerHigh: Color(0xFF252525),
        surfaceContainerHighest: Color(0xFF303030),
        inverseSurface: Color(0xFFE8E8E8),
        // Text
        onSurface: Color(0xFFE8E6E3),
        onSurfaceVariant: Color(0xFFA3A3A0),
        onSurfaceDisabled: Color(0xFF555555),
        inverseOnSurface: Color(0xFF1A1A1A),
        // Semantic
        income: Color(0xFF6ECF6E),
        incomeContainer: Color(0xFF142E14),
        onIncomeContainer: Color(0xFFA8E6A8),
        expense: Color(0xFFF2B8B5),
        expenseContainer: Color(0xFF3B1410),
        onExpenseContainer: Color(0xFFF2B8B5),
        warning: Color(0xFFD4A843),
        warningContainer: Color(0xFF3B2E0A),
        onWarningContainer: Color(0xFFFFD980),
        neutral: Color(0xFFA3A3A0),
        // Action
        primary: Color(0xFF7BC470),
        primaryContainer: Color(0xFF1A3317),
        onPrimary: Color(0xFF0A1A08),
        onPrimaryContainer: Color(0xFFD4EDCF),
        secondary: Color(0xFF7EB3E0),
        outline: Color(0xFF3A3A3A),
        outlineVariant: Color(0xFF252525),
        // Chart
        chartLine1: Color(0xFF7BC470),
        chartLine2: Color(0xFFF2B8B5),
        chartLine3: Color(0xFF7EB3E0),
        chartFill1: Color(0x207BC470),
        chartGrid: Color(0xFF252525),
        chartTooltipBg: Color(0xFF303030),
      );
}
