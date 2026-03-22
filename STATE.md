# Vael — State

## Current Phase: 5 — Polish + Distribution (COMPLETE)
## Branch: feat/phase5

## Phase 5 Progress

### Wave 1: App Shell + HomeShell (COMPLETE) — commit 97c5491
- HomeShell ConsumerStatefulWidget wires AdaptiveScaffold with all 5 tabs
- Session providers (sessionFamilyIdProvider, sessionUserIdProvider) via Notifier pattern
- VaelApp conditionally renders HomeShell (session set) or OnboardingFlow (no session)
- Dev bootstrap seeds family+user in kDebugMode for simulator testing
- Files: lib/shared/shell/home_shell.dart, lib/core/providers/session_providers.dart, lib/app.dart, lib/main.dart

### Wave 2: Goals Feature (COMPLETE) — commit 52065f1
- GoalListScreen with progress bars, status chips, INR formatting, empty state
- GoalFormScreen with name/amount/date validation, DAO insertion
- GoalCard widget extracted from DashboardScreen._GoalTile for reuse
- Goal providers: goalDaoProvider, goalListProvider (StreamProvider.family)
- Wired to tab 4 in HomeShell
- Files: lib/features/goals/{providers,screens,widgets}/

### Wave 3: Onboarding Flow (COMPLETE) — latest commit
- Welcome screen with branding + "Get Started"
- Create Family step with name validation, UUID generation
- Seeds family+user in DB, activates session providers → transitions to HomeShell
- OnboardingNotifier tracks step progression
- Files: lib/features/onboarding/{providers,screens}/

### Wave 4: Settings Hub (COMPLETE) — latest commit
- SettingsScreen hub with ListTiles: Family Backup, Sync Status, Passphrase, Sign Out
- Navigation to placeholder backup/sync screens + real PassphraseSetupScreen
- Sign-out clears session providers → VaelApp reactively returns to OnboardingFlow
- HomeShell.onSettingsTap wired to push SettingsScreen
- App info section with branding
- 10 widget tests (SettingsScreen) + 1 new HomeShell navigation test
- Files: lib/features/settings/screens/settings_screen.dart, lib/shared/shell/home_shell.dart

### Wave 5: File-backed Database (COMPLETE) — latest commit
- databaseFileName() returns SHA-256 opaque hex filename (no financial semantics)
- databaseFile() returns File in getApplicationSupportDirectory()
- databaseProvider uses LazyDatabase for async file resolution
- Tests continue using NativeDatabase.memory() via override
- 3 unit tests for filename opacity, determinism, no-leakage
- Files: lib/core/database/database_path.dart, lib/core/providers/database_providers.dart

### Wave 6: Accessibility (COMPLETE) — latest commit
- WCAG AA contrast verified for both light/dark themes (15 color pair tests)
- Semantics labels on net worth hero, monthly tiles, goal progress bars
- Dynamic type scaling verified at 2x and 0.8x
- 19 a11y tests (15 contrast + 2 scaling + 2 semantics)
- Files: lib/features/dashboard/screens/dashboard_screen.dart, lib/features/goals/widgets/goal_card.dart, test/shared/accessibility_test.dart

### Wave 7: E2E Integration Tests (COMPLETE) — latest commit
- 11 E2E tests covering Phase 5 features
- HomeShell: tab navigation, settings gear → SettingsScreen
- Settings: Family Backup nav, Passphrase nav, Sign Out clears session
- Goals: empty state, FAB presence
- Session lifecycle: no session → onboarding, set session → HomeShell, sign out → onboarding
- Files: test/integration/phase5_e2e_test.dart

### Wave 8: CI/CD + Distribution (COMPLETE) — latest commit
- GitHub Actions CI enhanced: analyze → test → build-android (APK) → build-ios (no codesign)
- Android APK uploaded as artifact (7-day retention)
- iOS build on macos-latest runner
- Fastlane Fastfile for iOS (build/beta/release lanes)
- Fastlane Fastfile for Android (build/beta/release lanes)
- Files: .github/workflows/ci.yml, ios/fastlane/Fastfile, android/fastlane/Fastfile

## Plan File
Detailed plan with file-level breakdown: .claude/plans/inherited-greeting-eich.md

## Test Count: 760 unit/widget (all green) + 29 simulator tests + 23 journey tests + 38 retroactive E2E tests

## Key Patterns Established
- Widget tests override stream providers with Stream.value() to avoid drift timer issues
- Riverpod 3.x: use Notifier + NotifierProvider (no StateProvider)
- Pre-commit hook runs: dart format → flutter analyze --no-fatal-infos → flutter test
- Unused imports cause hook failure (analyze returns exit 1 on warnings)
