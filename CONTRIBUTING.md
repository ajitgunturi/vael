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

```bash
# Prerequisites: Flutter 3.x, Dart SDK
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
```

Use `make check` to run both analysis and tests in one step.

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
