# Changelog

All notable changes to Vael are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- **Phase 6-8 Extension Plan** — Lifetime financial planning (BlackRock methodology), cash management & safety nets (Schwab methodology), unified planning dashboard with horizontal integration strategy
- **Docs Cleanup** — Removed duplicates, archived legacy docs, renamed for clarity, added guided reading path

## [0.5.0] — Phase 5: Polish + Distribution

### Added
- App shell with HomeShell wiring all 5 tabs
- Goals feature (list, form, progress tracking, SIP status)
- Onboarding flow (welcome → create family → passphrase → dashboard)
- Settings hub (backup, sync status, passphrase, sign out)
- File-backed database with opaque SHA-256 filenames
- Accessibility: WCAG AA contrast, semantic labels, dynamic type scaling
- E2E integration tests (11 tests covering Phase 5 features)
- CI/CD: GitHub Actions (analyze → test → build), Fastlane for iOS/Android

**Test count**: 760 unit/widget + 90 simulator/E2E tests

## [0.4.0] — Phase 3 + 3.5: Encryption + Sync

### Added
- AES-256-GCM encryption with round-trip verification
- PBKDF2 key derivation (100k iterations, SHA-256)
- FEK management (generate, wrap/unwrap)
- Encrypted Google Drive sync (push/pull/snapshot)
- Conflict resolution (last-writer-wins, additive merge, delete wins)
- Passphrase setup UI and sync status screen
- Per-member FEK wrapping (Phase 3.5)
- Drive permission management and ownership transfer (Phase 3.5)
- iCloud Drive support via cloud storage abstraction (Phase 3.5)

**Test count**: 517 tests

## [0.3.0] — Phase 2.5: UX Implementation

### Added
- Design system: ColorTokens (light/dark), Inter font, spacing constants
- Dashboard redesign: hero net worth card, compact tiles, quick actions, net worth chart
- Transaction grouping by date, search, kind filters
- Budget interactivity with donut chart
- Account type icons and balance coloring
- Empty states, pull-to-refresh, page transitions, live currency formatting

**Test count**: 403 tests

## [0.2.0] — Phase 2: Core Features

### Added
- Riverpod provider architecture (StreamProvider for DB, FutureProvider for computations)
- Dashboard aggregation (net worth, monthly summary, scope toggle)
- Account CRUD with visibility badges
- Transaction CRUD with balance cascade (7 cascade tests)
- Budget logic with category groups and overspend alerts
- Goal tracking with inflation-adjusted targets and required SIP
- Loan detail with amortization table and prepayment simulation

**Test count**: 293 tests

## [0.1.0] — Phase 1: Foundation

### Added
- Money type (integer minor units, Indian lakh formatting)
- Financial math: PMT, FV, PV, inflation adjust, amortization calculator
- drift database schema (families, users, accounts, categories, transactions, balance_snapshots, audit_log)
- Core DAOs with family-scoped queries and soft delete filtering
- Account balance rules (income adds, expense subtracts, transfer two-step, atomicity)
- Google Sign-In wrapper
- Adaptive navigation shell (phone/tablet/desktop breakpoints)
- Theme system (light/dark, WCAG AA contrast, amount colors)

**Test count**: 172 tests
