---
phase: 07-fi-calculator-net-worth-milestones
plan: 02
subsystem: ui
tags: [flutter, riverpod, fi-calculator, material3, responsive]

# Dependency graph
requires:
  - phase: 07-fi-calculator-net-worth-milestones
    provides: FiCalculator pure static engine, RateSlider widget, MilestoneEngine
provides:
  - FiCalculatorScreen with hero FI number, years-to-FI, Coast FI
  - FiHeroCard and FiSecondaryCard reusable widgets
  - FiInputs data class and fiDefaultInputsProvider for FI input management
  - Standalone mode with placeholder defaults
affects: [07-fi-calculator-net-worth-milestones, dashboard]

# Tech tracking
tech-stack:
  added: []
  patterns: [provider-override-in-widget-tests, compact-indian-currency-formatter]

key-files:
  created:
    - lib/features/planning/providers/fi_calculator_provider.dart
    - lib/features/planning/widgets/fi_hero_card.dart
    - lib/features/planning/widgets/fi_secondary_card.dart
    - lib/features/planning/screens/fi_calculator_screen.dart
    - test/features/planning/providers/fi_calculator_provider_test.dart
    - test/features/planning/screens/fi_calculator_screen_test.dart
  modified: []

key-decisions:
  - "Provider override in widget tests to avoid drift stream timer issues with ProviderScope disposal"
  - "Compact Indian currency formatter (Cr/L) for FI hero display instead of full Money.formatted"
  - "FiInputs initialized once from provider defaults; slider state managed locally in ConsumerStatefulWidget"

patterns-established:
  - "Provider override pattern: override fiDefaultInputsProvider in widget tests to avoid drift stream timers"
  - "Compact currency display: _formatCompactIndian for large amounts (Cr/L suffixes)"

requirements-completed: [FI-04, FI-05]

# Metrics
duration: 25min
completed: 2026-03-22
---

# Phase 07 Plan 02: FI Calculator Screen Summary

**FI Calculator screen with hero number, years-to-FI/Coast FI cards, 3 rate sliders, expenses input, and standalone mode with placeholder defaults**

## Performance

- **Duration:** 25 min
- **Started:** 2026-03-22T20:16:13Z
- **Completed:** 2026-03-22T20:41:25Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments
- FiInputs data class with standalone defaults and life profile integration via fiDefaultInputsProvider
- FI Calculator screen with hero card (displayLarge, tabular figures, primary color), two secondary metric cards (years-to-FI, Coast FI), 3 RateSlider inputs, and monthly expenses TextField
- Standalone mode: profile banner prompts user to set up life profile, all sliders functional with Rs 50K/3%/10%/6% defaults
- 14 tests total (6 provider unit tests + 8 widget tests) all passing

## Task Commits

Each task was committed atomically:

1. **Task 1: FI Calculator provider and input model** - `cf4bce9` (feat)
2. **Task 2: FI Calculator screen with hero card, secondary cards, and 4 sliders** - `2c0ee21` (feat)

## Files Created/Modified
- `lib/features/planning/providers/fi_calculator_provider.dart` - FiInputs data class + fiDefaultInputsProvider (reads life profile or falls back to defaults)
- `lib/features/planning/widgets/fi_hero_card.dart` - Large FI number display card with displayLarge, primary color, context subtitle
- `lib/features/planning/widgets/fi_secondary_card.dart` - Years-to-FI and Coast FI cards with unreachable warning state
- `lib/features/planning/screens/fi_calculator_screen.dart` - Full FI Calculator screen: hero, secondary cards, 3 sliders, expenses input, profile banner
- `test/features/planning/providers/fi_calculator_provider_test.dart` - 6 tests for FiInputs and provider
- `test/features/planning/screens/fi_calculator_screen_test.dart` - 8 widget tests for screen rendering, interaction, and profile states

## Decisions Made
- **Provider override in widget tests:** Drift stream providers leave pending timers when ProviderScope disposes in test environment. Overriding fiDefaultInputsProvider with a synchronous value avoids this while the actual stream wiring is verified in provider unit tests.
- **Compact Indian currency formatter:** Created `_formatCompactIndian` helper for FI hero card display (e.g. "3.20 Cr", "85.0 L") since Money.formatted shows full Indian grouping which is too verbose for hero display.
- **Local slider state with one-time init:** FiInputs from provider initializes state variables once; subsequent slider changes are local setState. This avoids provider round-trips on every slider drag while still pre-filling from life profile.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed AsyncValue.valueOrNull to .value**
- **Found during:** Task 1 (provider implementation)
- **Issue:** Riverpod 3.1.0 does not expose `valueOrNull` on AsyncValue; the API uses `.value`
- **Fix:** Changed `profileAsync.valueOrNull` to `profileAsync.value`
- **Files modified:** lib/features/planning/providers/fi_calculator_provider.dart
- **Verification:** Provider tests pass
- **Committed in:** cf4bce9 (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Minor API compatibility fix. No scope creep.

## Issues Encountered
- Drift stream providers create pending timers during ProviderScope disposal in widget tests, causing "Timer is still pending" assertions. Resolved by overriding the provider with synchronous values in screen tests, keeping stream wiring verification in provider unit tests.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- FI Calculator screen ready for navigation wiring in Plan 03
- FiHeroCard and FiSecondaryCard available for reuse in milestone dashboard
- FiInputs data class can be extended with budget actuals integration

---
*Phase: 07-fi-calculator-net-worth-milestones*
*Completed: 2026-03-22*

## Self-Check: PASSED

- All 6 source/test files exist on disk
- Both task commits verified (cf4bce9, 2c0ee21)
- 14 tests passing (6 provider + 8 screen)
