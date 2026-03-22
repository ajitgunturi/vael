---
phase: 06-life-profile-income-model
plan: 03
subsystem: ui, providers
tags: [riverpod, wizard, stepper, risk-profile, basis-points, flutter-widgets, settings]

# Dependency graph
requires:
  - phase: 06-01
    provides: "life_profiles table, LifeProfileDao, IncomeGrowthEngine with bp helpers"
provides:
  - "lifeProfileProvider StreamProvider watching DAO for reactive updates"
  - "familyProfilesProvider for combined family view"
  - "salaryTrajectoryProvider composing life profile with IncomeGrowthEngine"
  - "LifeProfileWizardScreen 3-step wizard (DOB+retirement, risk cards, rate sliders)"
  - "RiskProfileCard selectable widget with equity allocation display"
  - "RateSlider widget storing basis points, displaying percentage"
  - "Settings > Financial Planning > Life Profile entry point"
affects: [fi-calculator-ui, allocation-ui, planning-dashboard, settings-navigation]

# Tech tracking
tech-stack:
  added: []
  patterns: ["Riverpod StreamProvider.family for user-scoped reactive data", "basis-point slider UX (display % store bp)", "3-step Stepper wizard with edit-mode pre-fill"]

key-files:
  created:
    - lib/features/planning/providers/life_profile_provider.dart
    - lib/features/planning/providers/income_growth_provider.dart
    - lib/features/planning/screens/life_profile_wizard_screen.dart
    - lib/features/planning/widgets/risk_profile_card.dart
    - lib/features/planning/widgets/rate_slider.dart
    - test/features/planning/providers/life_profile_provider_test.dart
    - test/features/planning/screens/life_profile_wizard_screen_test.dart
  modified:
    - lib/features/settings/screens/settings_screen.dart

key-decisions:
  - "RiskProfileCard uses shield/balance/rocket icons with 35%/60%/85% equity labels for conservative/moderate/aggressive"
  - "RateSlider stores basis points internally, converts to percentage for display (stepBp=50 for 0.5% increments)"
  - "Wizard uses Stepper widget with 3 steps; edit mode pre-fills all fields from existing LifeProfile"
  - "Settings Financial Planning section inserted before theme toggle section"

patterns-established:
  - "3-step wizard pattern: Stepper with ConsumerStatefulWidget, optional existingProfile for edit mode"
  - "Rate slider pattern: integer bp storage with percentage display, reusable for future rate inputs"

requirements-completed: [LIFE-04]

# Metrics
duration: 20min
completed: 2026-03-23
---

# Phase 06 Plan 03: Life Profile Wizard & Settings Integration Summary

**3-step life profile wizard (DOB+retirement, risk cards with equity %, rate sliders with bp storage) accessible from Settings > Financial Planning, with Riverpod providers for reactive downstream updates (LIFE-04)**

## Performance

- **Duration:** 20 min
- **Started:** 2026-03-23T00:10:00Z
- **Completed:** 2026-03-23T00:30:00Z
- **Tasks:** 2 (1 auto + 1 human-verify checkpoint)
- **Files modified:** 8

## Accomplishments
- Riverpod providers (lifeProfileProvider, familyProfilesProvider, salaryTrajectoryProvider) enabling reactive downstream updates when profile changes
- 3-step wizard screen: DOB + retirement age, risk profile card selection (conservative/moderate/aggressive with equity %), rate sliders (income growth, inflation, SWR) + hike month dropdown
- Settings screen integration with Financial Planning section and Life Profile tile navigation
- Edit mode pre-fills all fields from existing profile, save triggers reactive provider updates
- Provider and widget tests passing (8 tests)

## Task Commits

Each task was committed atomically:

1. **Task 1: Riverpod providers, wizard screen, risk cards, rate sliders, and Settings integration** - `39334d6` (feat)
2. **Task 2: Verify life profile wizard flow and Settings integration** - checkpoint approved (human-verify)

## Files Created/Modified
- `lib/features/planning/providers/life_profile_provider.dart` - StreamProvider.family watching LifeProfileDao for user-scoped reactive data
- `lib/features/planning/providers/income_growth_provider.dart` - Provider composing life profile with IncomeGrowthEngine for salary trajectory
- `lib/features/planning/screens/life_profile_wizard_screen.dart` - 3-step Stepper wizard (DOB+retirement, risk cards, rate sliders + hike month)
- `lib/features/planning/widgets/risk_profile_card.dart` - Selectable card showing icon, risk level, and equity allocation percentage
- `lib/features/planning/widgets/rate_slider.dart` - Percentage display slider storing/emitting integer basis points
- `lib/features/settings/screens/settings_screen.dart` - Added Financial Planning section with Life Profile tile
- `test/features/planning/providers/life_profile_provider_test.dart` - Provider reactivity tests
- `test/features/planning/screens/life_profile_wizard_screen_test.dart` - Wizard step navigation and save tests

## Decisions Made
- RiskProfileCard uses shield/balance/rocket icons with 35%/60%/85% equity labels -- matches India-standard allocation guidance
- RateSlider stores basis points internally (0.5% step increments) -- consistent with Plan 01 bp storage pattern
- Wizard uses Material Stepper widget with ConsumerStatefulWidget -- edit mode pre-fills from existing LifeProfile
- Financial Planning section placed before theme toggle in Settings -- logical grouping for financial features

## Deviations from Plan

None - plan executed exactly as written. Task 1 files were committed alongside 06-02 Task 1 due to staging overlap (documented in 06-02-SUMMARY.md deviation #3).

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Life profile CRUD complete end-to-end: table, DAO, engine, providers, wizard UI, settings entry point
- Phase 6 fully complete -- all 3 plans delivered (LIFE-01 through LIFE-04, INCOME-01 through INCOME-04)
- Ready for Phase 7 (FI Calculator) which depends on life profile data (age, retirement, risk, SWR, growth rates)
- salaryTrajectoryProvider ready to feed FI calculations with career-aware income projections

## Self-Check: PASSED

- All 8 created/modified files verified present on disk
- Commit 39334d6 verified in git log

---
*Phase: 06-life-profile-income-model*
*Completed: 2026-03-23*
