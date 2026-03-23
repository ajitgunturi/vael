# Vael

## What This Is

Vael is a privacy-first family finance app for Indian households. It gives families complete ownership of their financial life — a single, private, transparent view across every member, account, and goal — without surrendering data to servers, subscriptions, or third parties. Built with Flutter, local-first with encrypted Google Drive sync.

## Core Value

Privacy is non-negotiable. Data never leaves the device unencrypted. No telemetry, no analytics, no server-side processing. The user's cost is zero beyond the device they already own.

## Requirements

### Validated

<!-- Shipped and confirmed valuable (Phases 1–5). -->

- ✓ Multi-account management (savings, current, credit card, loan, investment, wallet) — Phase 1
- ✓ Transaction CRUD with category tagging — Phase 1
- ✓ Family-scoped data isolation with selective visibility — Phase 1
- ✓ AES-GCM encryption with Family Encryption Key (FEK) — Phase 1
- ✓ Google Drive encrypted cloud sync (changeset-based, append-only) — Phase 2
- ✓ Budget tracking with category groups (essential, non-essential, investments, home) — Phase 2
- ✓ Goal tracking with inflation-adjusted targets and SIP calculation — Phase 2
- ✓ Dashboard with net worth, monthly summary, quick actions — Phase 2.5
- ✓ Adaptive layout (phone/tablet/desktop breakpoints) — Phase 2.5
- ✓ Family backup access with admin ownership and per-member FEK — Phase 3.5
- ✓ iCloud backup support — Phase 3.5
- ✓ Ownership transfer and key rotation — Phase 3.5
- ✓ 60-month projection engine — Phase 4
- ✓ Investment portfolio tracking (mutual funds, stocks, PPF, EPF, NPS, FD, bonds, policy) — Phase 4
- ✓ Recurring transaction rules engine — Phase 4
- ✓ CSV/PDF statement import with parser — Phase 4
- ✓ Balance reconciliation — Phase 4
- ✓ Loan amortization with EMI calculations — Phase 4
- ✓ App shell with onboarding flow — Phase 5
- ✓ Settings screen (backup, sync, passphrase, theme) — Phase 5
- ✓ E2E test suite (~110 tests across phases) — Phase 5
- ✓ Emergency fund engine with 6-month rolling essentials, income-stability-based targets — Phase 9
- ✓ Cash tier classification (instant/short-term/long-term) with auto-suggest — Phase 9
- ✓ EF detail screen with progress ring, account linking, tier summary — Phase 9
- ✓ Navigation badges (EF shield, tier chip) on account detail/list, budget essentials link, Settings tile — Phase 9

### Active

<!-- Current scope: Financial Planning Extension (Phases 6–10). -->

- [ ] Life profile (DOB, retirement age, risk profile, growth rates)
- [ ] Net worth milestones by decade with on-track/behind/ahead status
- [ ] Financial independence (FI) calculator (FI number, years-to-FI, Coast FI)
- [ ] Asset allocation targets by age band with glide path (conservative/moderate/aggressive)
- [ ] Income growth model (salary trajectory, career stage, side income)
- [ ] Major purchase planner (home, car, education with loan EMI impact)
- [ ] Sinking funds (purpose-specific short-term savings buckets)
- [ ] Cash flow calendar (day-by-day income/expense map with threshold alerts)
- [ ] Savings allocation rules (priority-ordered surplus distribution)
- [ ] Savings rate trend (12-month history with health bands)
- [ ] Opportunity fund designation and tracking
- [ ] Unified planning dashboard ("5 numbers" financial health view)
- [ ] Lifetime timeline visualization (decades, milestones, FI date, goals)
- [ ] Cash flow health summary with savings waterfall
- [ ] Planning insights integration (deterministic threshold-based alerts)

### Out of Scope

<!-- Explicit boundaries from INTENT.md. -->

- AI/ML features (spending predictions, smart categorization, chatbots) — deterministic only per INTENT.md
- Bank API integrations (Plaid, Yodlee, account aggregators) — file-based import only
- Backend servers or recurring costs — local-first, zero-cost operation
- Social features (leaderboards, sharing outside family) — family is the boundary
- Subscription/freemium tiers — permanently free
- Real-time chat or messaging — not a social app
- Video/media content — outside financial domain

## Context

### Architecture
- **Layered Clean Architecture**: Core (data + crypto + financial logic) → Features (screens + providers) → Shared (theme + layout + widgets)
- **State management**: Riverpod family providers, reactive streams from Drift DAOs
- **Data**: Drift ORM with SQLCipher encryption, changeset-based sync to Google Drive
- **Financial math**: Integer arithmetic (paise/basis points), deterministic formulas (PMT, FV, PV, amortization, SIP)
- **Testing**: 400+ tests across unit, widget, and E2E; TDD mandatory

### Extension Architecture (Phases 6–8)
The extension plan adds a **Planning Intelligence Layer** on top of the existing core:
- New financial math engines (FI calculator, milestone engine, allocation engine, emergency fund engine, cash flow calendar, savings allocation engine)
- 7 new drift tables + 2 modified tables (additive schema migrations only)
- ~15 new screens across `features/planning/` and `features/cash_management/`
- 32 new navigation integration tests + cross-feature round-trip tests

### Known Dependencies / Gap Remediation
- **C7**: Projection engine needs to consume recurring rules, investment returns, life-stage data (resolve in Phase 6)
- **C10**: Balance snapshots never created — needed for savings rate trend (resolve in Phase 7)
- **M5**: Goal-investment linking unused — needed for purchase planner (resolve in Phase 6)
- **C1**: SQLCipher activation — all new tables must be encrypted at rest
- **C5**: Lock screen — financial planning data is highly sensitive

## Constraints

- **Tech stack**: Flutter/Dart, Drift ORM, Riverpod, SQLCipher — no new frameworks
- **Privacy**: All data encrypted at rest (SQLCipher) and in transit (AES-GCM FEK). Cloud providers see only noise.
- **Math**: Integer arithmetic only (paise for money, basis points for rates). No floating-point tolerance.
- **No servers**: All computation local. Zero marginal cost.
- **Horizontal integration**: Every new screen must be reachable from HomeShell via tap navigation. No dead buttons. Navigation integration tests mandatory at 3 breakpoints (400dp, 750dp, 1200dp).
- **TDD**: Red-green-refactor. Tests written before implementation. Domain-specific rules (exact integer assertions, round-trip crypto, deterministic mock clocks, real anonymized fixtures).
- **Code style**: `ColorTokens.of(context)` for colors, `Spacing.*` constants, `EmptyState` widget for empty screens, shimmer skeletons for loading.
- **Schema**: Additive migrations only — no existing column removals.
- **Family scoping**: New features respect family/user boundaries and visibility model.
- **Flutter path**: `/Users/ajitg/fvm/versions/stable/bin/flutter`

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Phases 6-8 are additive extensions (no changes to existing code) | Preserve stability of Phases 1-5 foundation | — Pending |
| BlackRock + Schwab dual-perspective approach | Covers both long-term wealth building AND short-term cash management | — Pending |
| No new bottom tabs (stay at 5) | UX limit; surface via dashboard cards, settings section, contextual navigation | — Pending |
| Deterministic glide paths (rule-based tables, not ML) | INTENT.md compliance; user makes judgments from clear numbers | — Pending |
| Resolve C1/C5 gaps before Phases 6-7 | New tables contain sensitive planning data requiring encryption + lock screen | — Pending |
| Sinking funds are separate from investment goals | Different UX (no inflation, no SIP, short-term, deterministic) | — Pending |
| Savings allocation is advisory only (no auto-create transactions) | User makes the judgment call; deterministic principle | — Pending |

---
*Last updated: 2026-03-22 after initialization*
