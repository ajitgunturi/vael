# Contributing to Vael

Thank you for your interest in Vael. This document explains how to contribute effectively.

## Principles

Before contributing, read [docs/INTENT.md](docs/INTENT.md). Every change must pass the Decision Framework table in that document. If any row returns **Block**, the proposal must be redesigned.

Key constraints:
- No data leaves the device unencrypted
- No server dependencies beyond Google Drive (as blind storage)
- No AI/ML — all logic is deterministic
- No telemetry, analytics, or crash reporting
- All monetary values are integers (minor units, never floats)

## Development Setup

### Prerequisites

- Flutter 3.x, Dart SDK
- A `.env` file with Google OAuth client IDs (see below)

### First-Time Setup

```bash
git clone <repo>
cp .env.example .env             # Fill in values (see "Credentials" below)
make setup                       # Install deps + bootstrap config + activate git hooks
make build-runner                # Generate drift code
make check                       # Format + lint + test
```

### Credentials

Vael uses Google Sign-In for Drive sync. OAuth client IDs are **not** checked into git — they live in a `.env` file that you create locally.

1. Get the `.env` file from a project maintainer (shared via secure channel — AirDrop, Signal, or password manager)
2. Place it at the repo root: `cp /path/to/shared/.env .env`
3. Run `make bootstrap` (or `make setup`, which runs bootstrap automatically)

This generates the platform config files (`GoogleService-Info.plist`, `key.properties`) from your `.env`. These generated files are gitignored.

If you need to create credentials from scratch (new Google Cloud project), see [docs/GOOGLE_CLOUD_SETUP.md](docs/GOOGLE_CLOUD_SETUP.md).

Your Google account must also be added as a **test user** in the Google Cloud Console OAuth consent screen — ask a maintainer to add your email.

### Running the App

```bash
make run-macos                   # macOS (injects client ID from .env automatically)
make run-ios                     # iOS (uses generated GoogleService-Info.plist)
make run-android                 # Android (uses SHA-1 registered in Cloud Console)
```

### Pre-Commit Hooks

`make setup` activates pre-commit hooks (`.githooks/`) that run format check, static analysis, and the full test suite before every commit. This prevents CI failures from reaching the remote.

## TDD Is Mandatory

All production code follows Red-Green-Refactor:

1. **Red** — Write a failing test that defines the expected behavior
2. **Green** — Write the minimum code to make it pass
3. **Refactor** — Clean up while keeping tests green

PRs without tests written *before* the implementation will not be merged.

### Test Naming

Name tests as behavioral specs:
```
should_round_to_nearest_paisa_when_splitting_amount
encrypts_empty_plaintext
wrong_key_fails_to_decrypt
```

### Domain-Specific Rules

| Domain | Requirement |
|--------|-------------|
| Financial math | Exact integer assertions, no floating-point tolerance |
| Encryption | Round-trip tests mandatory (encrypt → decrypt → assert equality) |
| Sync engine | Conflict resolution tests with deterministic mock clocks |
| Statement import | Parser tests against real anonymized fixtures |

## Horizontal Integration

Building a screen in isolation is only half the work. Every new screen must be **wired into the navigation graph** — reachable by a real user tapping through the app.

### Why This Matters

In wave-based development, it's easy to build a vertical slice (screen + logic + tests) that works perfectly in isolation but is unreachable from the running app. We've been burned by this: screens existed as files, E2E tests pumped them directly, but the debug build had no way to navigate to them. This section prevents that from recurring.

### What You Must Do

1. **Wire navigation entry points.** When you add a screen, add the `Navigator.push` call from an existing screen. Common entry points:
   - Dashboard quick actions grid — for top-level feature screens
   - AppBar action buttons — for contextual features (e.g., Import on Transactions)
   - List tile `onTap` — for detail screens (e.g., Loan Detail from account tile)
   - Settings tiles — for configuration screens

2. **Never ship dead buttons.** If a button or tile has `onPressed: () {}` or `onTap: null`, either wire it to a real destination or remove it. Placeholder no-ops are not acceptable.

3. **Update navigation tests.** Every phase that introduces new screens must include integration tests that verify the screen is reachable via tap interaction starting from `HomeShell`. Do not rely solely on direct `pumpWidget` — that tests the screen, not the wiring.

4. **Provide empty-state defaults for data-driven screens.** If a screen's constructor requires backend data (sync status, manifest data), provide sensible defaults so the screen renders in debug builds before that backend is configured.

### Navigation Test Pattern

```dart
// Start from the real shell
await tester.pumpWidget(buildApp()); // HomeShell-based app

// Navigate via tap (not direct pumpWidget)
await tester.tap(find.text('Investments'));
await tester.pumpAndSettle();

// Assert the target screen rendered
expect(find.text('No investment buckets yet'), findsOneWidget);
```

Extend `navigation_flow_test.dart` or `phase5_e2e_test.dart` rather than creating new navigation test files.

## Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>
```

Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`

Examples:
```
feat(sync): add conflict resolution for concurrent edits
fix(crypto): handle empty plaintext in AES-GCM
test(financial): add amortization edge case for 0% rate
```

## Pull Requests

1. Branch from `main` with a descriptive name (`feat/recurring-rules`, `fix/balance-rounding`)
2. Keep PRs focused — one logical change per PR
3. Fill out the PR template completely
4. Ensure `make check` passes locally before pushing
5. All CI checks must be green before review

### Security-Sensitive Changes

Changes touching files in `lib/core/crypto/` or `lib/core/sync/` require extra scrutiny:
- Encryption round-trip tests for any new crypto path
- No plaintext data in Drive file names, folder names, or sync metadata
- No secrets (keys, passphrases) logged, printed, or stored in plaintext
- Review the [Security Policy](SECURITY.md) before modifying these areas

## Code Style

- Follow `analysis_options.yaml` — the linter catches most issues
- Use `ColorTokens.of(context)` for colors, never raw hex in widgets
- Use `Spacing.xs/sm/md/lg/xl/xxl` constants, never magic numbers
- Use `EmptyState` widget for empty screens, never bare text
- Use shimmer skeletons (`SkeletonBox`/`SkeletonCard`) for loading states, never spinners

## What We Will Not Accept

- Features that require a backend server
- Analytics, telemetry, or user tracking of any kind
- Direct bank API connections (Plaid, Yodlee, account aggregators)
- AI/ML features (predictions, smart categorization, chatbots)
- Floating-point arithmetic for monetary values
- Dependencies that transmit data to third parties

## Reporting Issues

- Use the bug report template for defects
- Use the feature request template for new ideas
- Check existing issues before creating duplicates
- For security vulnerabilities, see [SECURITY.md](SECURITY.md) — do **not** open a public issue
