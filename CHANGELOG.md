# Changelog

All notable changes to Vael are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- **Phase 3: Encryption + Sync** — AES-256-GCM encryption, PBKDF2 key derivation, FEK management, encrypted Google Drive sync with push/pull/snapshot, conflict resolution, passphrase setup and sync status UI (517 tests)
- **Phase 2.5: UX Implementation** — Design system (ColorTokens, Inter font, spacing), dashboard redesign with net worth chart, transaction grouping/search, budget interactivity with donut chart, account icons, empty states, pull-to-refresh, page transitions, live currency formatting (403 tests)
- **Phase 2: Core Features** — Riverpod providers, dashboard aggregation, account/transaction/budget/goal CRUD, loan amortization, balance rules with cascade tests (293 tests)
- **Phase 1: Foundation** — Money type (integer minor units), financial math (PMT, FV, amortization), drift database schema, core DAOs, Google Sign-In wrapper, adaptive scaffold, theme system (172 tests)
