# Vael — UI Design Specification v3.1

> **Design philosophy**: Calm, confident, minimal. Every pixel earns its place. Every datum is editable. Every screen reflects the same truth. A finance app that feels like a luxury instrument, not a spreadsheet.
>
> **v3 additions**: Recurring rules with month-float frequency, scenario sandbox (decision engine), net worth milestones, bill reminders/notifications, recurring income with annual hikes, budget auto-projection from recurring rules.
>
> **v3.1 additions**: Implementation status tracking. Phase 2.5 (UX Implementation) formalizes this spec as the single source of truth for all phases. All UI code must use tokens defined here — never raw hex in widgets.

### Implementation Status

| Section | Status | Phase |
|---------|--------|-------|
| §0 Core Design Contracts | 🔶 Partial — cascade rules in code, inline editing not yet | Phase 2 |
| §1.1 Color Palette | 🔲 Pending | Phase 2.5 (step 2.5.1) |
| §1.2 Theme Switching | 🔲 Pending | Phase 2.5 (step 2.5.3) |
| §1.3 Typography (Inter) | 🔲 Pending | Phase 2.5 (step 2.5.2) |
| §1.4 Spacing/Radius/Card | 🔲 Pending | Phase 2.5 (step 2.5.2) |
| §1.5 Icons & Motion | 🔲 Pending | Phase 2.5 (steps 2.5.5, 2.5.21) |
| §2.1 Lock Screen | 🔲 Pending | Phase 3 (passphrase setup) |
| §2.2 Dashboard | 🔶 Partial — basic cards, no hero/chart/actions | Phase 2.5 (steps 2.5.8-2.5.12) |
| §2.3 Accounts Screen | 🔶 Partial — grouped list, no icons/inline edit | Phase 2.5 (step 2.5.16) |
| §2.4 Account Detail | 🔲 Pending | Phase 4+ |
| §2.5 Transaction List | 🔶 Partial — flat list, no grouping/search/filters | Phase 2.5 (step 2.5.13) |
| §2.6+ Remaining screens | 🔲 Pending | Phases 3-5 |

---

## 0. Core Design Contracts

### 0.1 Account-Centric Data Architecture

Every screen in Vael is a **view projection** of underlying account data. There are no independent screens — they are all windows into the same financial graph.

```
                         ┌──────────┐
                         │ ACCOUNTS │  ← single source of truth
                         └────┬─────┘
                              │
    ┌────────┬────────┬───────┼────────┬──────────┬──────────────┐
    │        │        │       │        │          │              │
┌───┴───┐┌───┴──┐┌────┴──┐┌──┴───┐┌───┴────┐┌────┴──────┐┌─────┴────┐
│Trans- ││Recur-││Dashbd ││Budget││ Goals  ││Loans/Inv  ││Scenario  │
│actions││ring  ││NetWrth││Actual││Savings ││Outstanding││ Sandbox  │
└───────┘│Rules │└───────┘└──┬───┘└────────┘└───────────┘└──────────┘
         └──┬───┘            │
            │         ┌──────┴──────┐
            └────────→│Budget auto- │  Recurring expenses auto-project
                      │projection   │  into budget actuals
                      └─────────────┘
```

**Data ownership map** — which entity owns which numbers:

| Screen | Reads From | Writes To |
|--------|-----------|-----------|
| Dashboard | accounts.balance, transactions (monthly), budget.limits, goals.*, recurring_rules (upcoming), net_worth_milestones | — (read-only aggregate) |
| Accounts | accounts.*, transactions (per account) | accounts (create/edit/delete) |
| Transactions | transactions.*, accounts.name, categories.* | transactions (create/edit/delete) → triggers account.balance recompute |
| Recurring Rules | recurring_rules.*, accounts.name, categories.* | recurring_rules (create/edit/delete/pause/resume) → triggers budget projection recompute |
| Budget | budgets.limits, transactions (actuals by category), recurring_rules (projected) | budgets.limits (edit) |
| Goals | goals.*, accounts.balance (linked), investment_holdings | goals (create/edit/delete) |
| Loans | loan_details.*, accounts.balance, amortization (computed) | loan_details (edit), transactions (prepayment) |
| Investments | investment_holdings.*, accounts.balance | investment_holdings (edit) |
| Projections | recurring_rules, loan_details, goals, accounts, scenarios (if active) | — (read-only computation) |
| Scenario Sandbox | scenarios.*, scenario_changes.*, all source data for projection | scenarios (create/edit/delete), scenario_changes (CRUD) → on accept: converts to real entities |
| Net Worth Milestones | net_worth_milestones.*, accounts.balance (for current net worth) | net_worth_milestones (create/edit/delete) |
| Notifications | recurring_rules (upcoming), loan_details (EMI due), accounts (credit card due), vault_records (expiry) | notification_preferences (edit) |
| Document Vault | vault_records.*, accounts.name (linked) | vault_records (create/edit/delete) |

### 0.2 Cascade Rules

When a user edits ANY value, these cascades fire **synchronously before the screen updates**:

| User Action | Immediate Cascade | Affected Screens |
|------------|-------------------|-----------------|
| Edit transaction amount | → Recompute account balance (delta of old vs new) | Dashboard (net worth, monthly summary), Account Detail (balance), Budget (actuals) |
| Edit transaction category | → Recompute budget actuals for old AND new category groups | Dashboard (budget section), Budget screen |
| Edit transaction account | → Recompute balance on BOTH old and new accounts | Dashboard (net worth), both Account Details, Budget (if shared account status differs) |
| Delete transaction | → Reverse balance impact on account(s) | Dashboard, Account Detail, Budget |
| Edit account balance (manual adj) | → Create adjustment transaction in audit log | Dashboard (net worth), Account Detail |
| Edit budget limit | → Recompute remaining/overspent status | Dashboard (budget section), Budget screen |
| Edit goal target/savings | → Recompute SIP, status (ON_TRACK/AT_RISK) | Dashboard (goals section), Goals screen |
| Edit loan details | → Regenerate amortization schedule | Loan Detail, Dashboard (net worth if outstanding changes) |
| Edit recurring rule | → Recompute budget projections + projection engine | Budget (projected amounts), Projections, Dashboard (upcoming section) |
| Pause/resume recurring rule | → Toggle projected amounts in/out of budget + projections | Budget, Projections, Notifications (suppress/restore reminders) |
| Edit recurring rule frequency | → Recompute all future occurrences + budget projections | Budget (actuals shift), Projections (60-mo recalc), Notifications (reschedule) |
| Edit recurring rule escalation | → Recompute future amounts with new hike rate | Projections (income/expense curves change), Budget (future months) |
| Create/delete account | → Recompute net worth, update all account selectors | Every screen with account picker or net worth |
| Edit investment holding | → Recompute portfolio value, linked goal progress | Dashboard, Goals, Investments |
| Create/edit scenario | → Recompute scenario projection (isolated from real data) | Scenario Sandbox, Projections (if scenario overlay active) |
| Accept scenario decision | → Convert scenario changes to real entities (accounts, recurring rules, goals) | ALL screens — cascades as if each entity was created individually |
| Create/edit net worth milestone | → Recompute progress % against current net worth | Dashboard (milestone card), Net Worth Milestones screen |
| Net worth crosses milestone | → Trigger local notification + milestone card highlight | Dashboard, Notifications |
| Self-transfer between accounts | → Debit source + credit destination (atomic). Net worth unchanged. | Both Account Details, Dashboard (account list only, net worth stable) |
| EMI payment (from account → loan) | → Debit source account, split into principal (reduces loan outstanding) + interest (expense). Regenerate remaining amortization. | Source Account Detail, Loan Detail (outstanding, schedule), Dashboard (net worth stable — liability offset), Budget (EMI as expense) |
| Multi-leg salary flow (income → transfer → EMI) | → Creates 3 separate transactions, each with its own cascade. All execute atomically. | Salary Account, Savings Account, Loan Account, Dashboard, Budget |
| Edit notification preferences | → Reschedule local notifications | Notifications screen only |

**Implementation rule**: All cascades go through the drift DAO layer. UI observes Riverpod providers that watch database streams. No screen ever caches a stale value — every displayed number is a live derivation.

### 0.3 Inline Editing Contract

**Every displayed datum that came from user input is tappable and editable.** Read-only computed values (net worth, budget actuals, amortization rows) are NOT editable but show a tooltip explaining their derivation.

| Edit Pattern | When To Use | Behavior |
|-------------|-------------|----------|
| **Inline tap-to-edit** | Single fields: amounts, names, dates | Tap → field becomes editable in-place → save on blur/enter → cascade fires |
| **Bottom sheet edit** | Multi-field entities: transactions, accounts | Tap row → bottom sheet opens pre-filled → edit any field → save → cascade fires |
| **Long-press context menu** | Destructive actions | Long-press → menu: Edit, Duplicate, Delete → confirmation for delete |
| **Swipe actions** | Quick delete/archive on lists | Swipe left → red Delete, Swipe right → gray Archive (soft delete) |

**Visual edit affordance**: Editable values show a subtle `onSurfaceVariant` underline-dot pattern on hover/focus (desktop) or a brief shimmer on first load (mobile) to signal tappability. Non-editable computed values have no affordance.

### 0.4 Consistency Rules

These rules apply to EVERY screen without exception:

| Rule | Details |
|------|---------|
| **Amount formatting** | Always ₹X,XX,XXX.XX (Indian lakh/crore). Positive = green, Negative = red, Neutral (transfers) = gray. Minor units internally, formatted for display. |
| **Date formatting** | "20 Mar 2026" (short), "20 March 2026" (long). Relative for recent: "Today", "Yesterday", "2 days ago". |
| **Account badge** | Every amount shown MUST display its source account as a chip/badge below or beside it: `🏦 HDFC Savings`. This is how users trace any number back to its account. |
| **Edit indicator** | Editable values: `onSurface` color. Computed values: `onSurfaceVariant` color + "(calculated)" suffix on tap. |
| **Loading state** | Shimmer skeleton matching exact layout. Never a spinner. Never a blank screen. |
| **Empty state** | Illustration + action CTA. Never just "No data". |
| **Error state** | Inline below the field, `error` color, with specific message. Never toast-only. |
| **Confirmation** | Destructive actions (delete, overwrite) always require explicit confirmation dialog. |
| **Undo** | Non-destructive edits show a 5-second "Undo" snackbar after save. |
| **Sync indicator** | Every screen header shows sync status dot: 🟢 synced, 🟡 pending, 🔴 error. |
| **Theme-agnostic contrast** | All text meets WCAG AA (4.5:1) in BOTH light and dark mode. Verified per token pair. |

### 0.5 Visibility & Family Privacy Model

Every account has a visibility setting controlled by its **owner** (the family member who created it). No one — not even ADMIN — can override another member's visibility choice.

#### Visibility Levels (per account)

| Level | Icon | Balance Visible? | Transactions Visible? | Appears in Family Net Worth? | Appears in Family Budget? |
|-------|------|-----------------|----------------------|------------------------------|--------------------------|
| `SHARED` | 👁 | Yes — all family members see balance | Yes — transactions from this account visible in family views | Yes — balance contributes to family net worth | Yes — expenses count toward shared budget actuals |
| `NAME_ONLY` | 👁‍🗨 | **No** — balance shows as `₹ ••••••` | **No** — transactions hidden from family views (visible only to owner) | **No** — excluded from family net worth | **No** — excluded from shared budget |
| `HIDDEN` | 🔒 | No — account not listed for other members | No | No | No |

**Key rules:**
- Owner always sees their own accounts in full, regardless of visibility setting
- `SHARED` = full transparency into this account for the family
- `NAME_ONLY` = family knows the account exists (e.g., "Pravallika has a HDFC Savings account") but cannot see balance, transactions, or any derived numbers
- `HIDDEN` = family doesn't even know this account exists (for truly private accounts)
- Default for new accounts: `SHARED` (can be changed at creation or any time after)

#### Family Net Worth Computation

```
Family Net Worth (as seen by any member) =
  SUM(balance) of all accounts WHERE visibility = SHARED
  across ALL family members

  + viewer's own accounts regardless of visibility
    (you always see your own contribution)
```

**What each family member sees:**

```
AJIT'S VIEW (Ajit has 3 accounts, Pravallika has 2):
┌─────────────────────────────────────┐
│  Family Net Worth             [C]   │
│  ₹48,15,678                        │  Includes all of Ajit's +
│  (includes 4 of 5 accounts)        │  Pravallika's SHARED accounts
│                                     │
│  👤 Ajit's Accounts                 │
│  🏦 HDFC Savings    ₹3,24,567  👁  │  His own — always visible
│  📈 Zerodha         ₹18,54,320 👁  │  Shared
│  🏦 Personal FD     ₹2,00,000  🔒  │  Hidden from Pravallika,
│                                     │  but Ajit sees it
│                                     │
│  👤 Pravallika's Accounts                │
│  🏦 SBI Savings     ₹1,45,230  👁  │  Shared — Ajit sees balance
│  💳 SBI Credit      ₹ ••••••  👁‍🗨  │  NAME_ONLY — exists but
│                                     │  balance hidden from Ajit
│                                     │
│  ℹ️ Some accounts have limited      │  bodySmall, {onSurfaceVariant}
│  visibility. Family net worth       │
│  reflects shared accounts only.     │
└─────────────────────────────────────┘

PRIYA'S VIEW (same data, different perspective):
┌─────────────────────────────────────┐
│  Family Net Worth             [C]   │
│  ₹23,24,117                        │  Different number! Includes
│  (includes 3 of 4 accounts)        │  all Pravallika's + Ajit's SHARED
│                                     │
│  👤 Pravallika's Accounts                │
│  🏦 SBI Savings     ₹1,45,230  👁  │  Her own — always visible
│  💳 SBI Credit      -₹12,450  👁‍🗨  │  She sees her own balance
│                                     │  (it's her account)
│                                     │
│  👤 Ajit's Accounts                 │
│  🏦 HDFC Savings    ₹3,24,567  👁  │  Shared — Pravallika sees
│  📈 Zerodha         ₹18,54,320 👁  │  Shared — Pravallika sees
│                                     │  (Ajit's Personal FD is
│                                     │   HIDDEN — Pravallika doesn't
│                                     │   even see it listed)
│                                     │
│  ℹ️ Some accounts have limited      │
│  visibility.                        │
└─────────────────────────────────────┘
```

**Critical UX**: Net worth numbers differ per viewer. The app never lies — it shows exactly what the viewer has access to, and notes that some accounts have limited visibility. No fake totals.

#### Transfers Between Family Members

Transfers can happen between any two accounts in the family — including across members. Visibility rules apply:

| Scenario | Transaction Visibility | Balance Effect |
|----------|----------------------|----------------|
| Ajit (SHARED) → Pravallika (SHARED) | Both members see the full transaction + amounts | Both accounts update, family net worth unchanged |
| Ajit (SHARED) → Pravallika (NAME_ONLY) | Ajit sees: "Transfer to Pravallika's SBI Credit" with amount. Pravallika sees full transaction (it's her account). Other family members see Ajit's side only: "Transfer to Pravallika's account ₹X" but not the target account balance. | Ajit's account -₹X (visible). Pravallika's account +₹X (visible only to Pravallika). Family net worth: only Ajit's side counted (Pravallika's is hidden). |
| Ajit (SHARED) → Pravallika (HIDDEN) | Ajit sees: "Transfer ₹X" with his account. Pravallika sees full transaction. Other family members see: "Transfer ₹X from Ajit's account" — destination not shown. | Same as above but account name not visible to others. |
| Ajit (HIDDEN) → Pravallika (SHARED) | Only Ajit and Pravallika see this transaction. For Pravallika it appears as "Received ₹X from Ajit." Other members see Pravallika's balance change but not the source. | Pravallika's balance updates (visible), source hidden. |

**Transaction list rules per viewer:**
- You see ALL transactions on YOUR accounts (regardless of visibility)
- You see transactions on other members' SHARED accounts
- You do NOT see transactions on other members' NAME_ONLY or HIDDEN accounts
- If a transfer involves one visible and one hidden account, you see only the visible side

#### Inter-Member Transfer in Transaction Sheet

```
┌─────────────────────────────┐
│  ─── drag handle ───        │
│                             │
│  New Transaction            │
│                             │
│  ┌──────┐┌──────┐┌─────┐┌───┐│
│  │○Expen││○Incom││◉Trans││○EMI││
│  │ se   ││ e    ││ fer  ││   ││
│  └──────┘└──────┘└─────┘└───┘│
│                             │
│  ₹ 15,000                  │
│  ━━━━━━━━━━━━━━━━━━━━━━━━  │
│                             │
│  🏦 From Account        [E] │
│  ┌─────────────────────────┐│
│  │  🏦 HDFC Savings      > ││  Your accounts
│  │  👤 Ajit                ││  Owner shown
│  └─────────────────────────┘│
│                             │
│  ➡️ To Account           [E] │
│  ┌─────────────────────────┐│
│  │  🏦 SBI Savings       > ││  Can pick any family account
│  │  👤 Pravallika               ││  Owner shown
│  │  👁 Shared              ││  Visibility badge
│  └─────────────────────────┘│
│                             │
│  ℹ️ Inter-member transfer    │  bodySmall, {onSurfaceVariant}
│  Pravallika will see this as     │  Explain what the other
│  "Received ₹15,000 from     │  member will see
│  Ajit's HDFC Savings"       │
│                             │
│  CASCADE PREVIEW            │
│  ┌─────────────────────────┐│
│  │ 🏦 HDFC Savings (Ajit): ││
│  │    ₹3,24,567 → ₹3,09,567││
│  │ 🏦 SBI Savings (Pravallika): ││
│  │    ₹1,45,230 → ₹1,60,230││
│  │ Family net worth: ₹0 Δ   ││  Both SHARED → no change
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │      Save Transfer       ││
│  └─────────────────────────┘│
└─────────────────────────────┘
```

#### Account Picker — Family-Aware

```
┌─────────────────────────────┐
│  Select Account      🔍     │
├─────────────────────────────┤
│                             │
│  👤 YOUR ACCOUNTS           │  labelSmall
│  🏦 HDFC Savings   ₹3.2L   │  Full balance visible
│  📈 Zerodha        ₹18.5L  │
│  🏦 Personal FD    ₹2.0L   │  Even HIDDEN ones (it's yours)
│                             │
│  👤 PRIYA'S ACCOUNTS        │  labelSmall
│  🏦 SBI Savings    ₹1.4L 👁│  SHARED — balance shown
│  💳 SBI Credit     •••• 👁‍🗨 │  NAME_ONLY — no balance
│                             │  (HIDDEN accounts of other
│                             │   members are NOT listed here)
│                             │
└─────────────────────────────┘
```

#### Dashboard — Family vs Personal Toggle

```
┌─────────────────────────────┐
│  ◇ Dashboard      🟢  🔔 👤 │
├─────────────────────────────┤
│  ┌──────────┐┌────────────┐ │
│  │ ◉ Family ││ ○ Personal │ │  Scope toggle
│  └──────────┘└────────────┘ │
│                             │
│  FAMILY MODE:               │
│  Net Worth: ₹48,15,678 [C] │  All SHARED accounts
│  (4 of 5 accounts)          │  Partial count noted
│                             │
│  PERSONAL MODE:             │
│  Net Worth: ₹23,78,887 [C] │  Only YOUR accounts (all)
│  (3 accounts)               │  Full picture of your own
│                             │
└─────────────────────────────┘
```

#### Visibility Cascade Rules

| User Action | Cascade |
|------------|---------|
| Change account from SHARED → NAME_ONLY | Family net worth recalculates (this account's balance removed). Other members' dashboards update. Budget actuals from this account's transactions excluded from shared budget. |
| Change account from NAME_ONLY → SHARED | Reverse: balance added to family net worth. Transactions become visible in family views. Budget actuals included. |
| Change account to HIDDEN | Account disappears from other members' views entirely. All transactions on this account removed from family views. |
| Transfer to NAME_ONLY/HIDDEN account | Source side visible to family (if source is SHARED). Destination side visible only to destination account owner. Family net worth only reflects the source debit. |

---

## 1. Design System

### 1.1 Color Palette — Dual Theme

Every color token is defined as a **light/dark pair**. The app uses `ThemeMode.system` by default with manual override in settings.

#### Surface Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `surface` | `#FAFAF9` | `#0F0F0F` | App background |
| `surfaceDim` | `#F0EFED` | `#0F0F0F` | Recessed areas (behind cards) |
| `surfaceContainer` | `#F2F1EF` | `#1A1A1A` | Cards, sheets, elevated surfaces |
| `surfaceContainerHigh` | `#E8E7E5` | `#252525` | Selected states, hover backgrounds |
| `surfaceContainerHighest` | `#DEDDDB` | `#303030` | Emphasized containers, active nav items |
| `inverseSurface` | `#1A1A1A` | `#E8E8E8` | Snackbars, tooltips (always opposite) |

#### Text Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `onSurface` | `#1A1A1A` | `#E8E6E3` | Primary text, editable values |
| `onSurfaceVariant` | `#6B6B6B` | `#A3A3A0` | Secondary text, computed values, labels |
| `onSurfaceDisabled` | `#B0B0B0` | `#555555` | Disabled inputs, placeholder text |
| `inverseOnSurface` | `#F5F5F5` | `#1A1A1A` | Text on inverse surfaces |

#### Semantic Colors — Income/Expense/Warning/Error

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `income` | `#2D7A2D` | `#6ECF6E` | Income amounts, positive changes, on-track |
| `incomeContainer` | `#E8F5E3` | `#142E14` | Income row backgrounds, success cards |
| `onIncomeContainer` | `#1A4A1A` | `#A8E6A8` | Text on income containers |
| `expense` | `#B3261E` | `#F2B8B5` | Expense amounts, negative changes, overspend |
| `expenseContainer` | `#FCECEA` | `#3B1410` | Expense row backgrounds, error cards |
| `onExpenseContainer` | `#6E1610` | `#F2B8B5` | Text on expense containers |
| `warning` | `#8B6914` | `#D4A843` | At-risk goals, close-to-limit budgets |
| `warningContainer` | `#FFF3D6` | `#3B2E0A` | Warning backgrounds |
| `onWarningContainer` | `#5C4400` | `#FFD980` | Text on warning containers |
| `neutral` | `#6B6B6B` | `#A3A3A0` | Transfers, non-judgmental amounts |

#### Action Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `primary` | `#2D5A27` | `#7BC470` | Primary buttons, active nav, links |
| `primaryContainer` | `#D4EDCF` | `#1A3317` | Selected chips, toggle backgrounds |
| `onPrimary` | `#FFFFFF` | `#0A1A08` | Text on primary buttons |
| `onPrimaryContainer` | `#0A1A08` | `#D4EDCF` | Text on primary containers |
| `secondary` | `#1A4A7A` | `#7EB3E0` | Secondary actions, info links |
| `outline` | `#D4D3D1` | `#3A3A3A` | Card borders, dividers |
| `outlineVariant` | `#EDEDEB` | `#252525` | Faint borders, table lines |

#### Chart Colors (optimized for both themes)

| Token | Light | Dark | Purpose |
|-------|-------|------|---------|
| `chartLine1` | `#2D5A27` | `#7BC470` | Primary series (net worth, income) |
| `chartLine2` | `#B3261E` | `#F2B8B5` | Secondary series (expenses) |
| `chartLine3` | `#1A4A7A` | `#7EB3E0` | Tertiary series (savings) |
| `chartFill1` | `#2D5A2720` | `#7BC47020` | Area fill (20% opacity) |
| `chartGrid` | `#EDEDEB` | `#252525` | Grid lines |
| `chartTooltipBg` | `#1A1A1A` | `#303030` | Tooltip background |

### 1.2 Theme Switching

```
┌─ LIGHT MODE ──────────────────────┐  ┌─ DARK MODE ───────────────────────┐
│                                   │  │                                   │
│  ┌─ #F2F1EF ─────────────────┐   │  │  ┌─ #1A1A1A ─────────────────┐   │
│  │  Net Worth                │   │  │  │  Net Worth                │   │
│  │  ₹42,15,678  (#2D7A2D)   │   │  │  │  ₹42,15,678  (#6ECF6E)   │   │
│  │  ↑₹1.2L this month       │   │  │  │  ↑₹1.2L this month       │   │
│  │  ─── #D4D3D1 border ──── │   │  │  │  ─── #3A3A3A border ──── │   │
│  │  Income     Expense       │   │  │  │  Income     Expense       │   │
│  │  +₹2.1L    -₹1.4L        │   │  │  │  +₹2.1L    -₹1.4L        │   │
│  │  (#2D7A2D)  (#B3261E)     │   │  │  │  (#6ECF6E)  (#F2B8B5)     │   │
│  └───────────────────────────┘   │  │  └───────────────────────────┘   │
│  background: #FAFAF9              │  │  background: #0F0F0F              │
└───────────────────────────────────┘  └───────────────────────────────────┘
```

**Rule**: Never reference a raw hex in widget code. Always use `Theme.of(context).colorScheme.tokenName` or the semantic extension (`context.colors.income`). This guarantees theme parity.

### 1.3 Typography

Using **Inter** (Google Fonts). All styles identical in both themes — only color changes.

| Style | Weight | Size | Spacing | Usage |
|-------|--------|------|---------|-------|
| `displayLarge` | 300 | 40sp | -1.5 | Net worth headline |
| `displayMedium` | 300 | 32sp | -0.5 | Section totals, account balances |
| `headlineLarge` | 500 | 24sp | 0 | Screen titles |
| `headlineMedium` | 500 | 20sp | 0 | Card titles, section headers |
| `titleLarge` | 600 | 18sp | 0 | Account names, goal names |
| `titleMedium` | 500 | 16sp | 0.15 | List item primary text |
| `bodyLarge` | 400 | 16sp | 0.5 | Body text, descriptions |
| `bodyMedium` | 400 | 14sp | 0.25 | Secondary descriptions |
| `bodySmall` | 400 | 12sp | 0.4 | Captions, timestamps, "calculated" labels |
| `labelLarge` | 500 | 14sp | 0.1 | Buttons, tabs |
| `labelMedium` | 500 | 12sp | 0.5 | Chips, badges, account badges |
| `labelSmall` | 500 | 11sp | 0.5 | Overlines, tiny labels |

**Number display**: `fontFeatures: [FontFeature.tabularFigures()]` for all monetary amounts.
**Indian formatting**: `₹1,23,456.78` via `intl` package `en_IN` locale.
**Abbreviations**: `₹1.2L` (lakh), `₹1.5Cr` (crore) for compact display. Full on tap.

### 1.4 Spacing, Radius, Card Style

| Token | Value | Usage |
|-------|-------|-------|
| `spacingXs` | 4dp | Icon-to-text, inline gaps |
| `spacingSm` | 8dp | Compact list padding, chip spacing |
| `spacingMd` | 16dp | Standard padding, card insets |
| `spacingLg` | 24dp | Section gaps |
| `spacingXl` | 32dp | Screen padding (phone) |
| `spacingXxl` | 48dp | Major section breaks |
| `radiusSm` | 8dp | Buttons, chips, badges |
| `radiusMd` | 12dp | Cards, list tiles |
| `radiusLg` | 16dp | Bottom sheets |
| `radiusXl` | 24dp | Modal dialogs |

**Card recipe** (both themes):
```
Container(
  decoration: BoxDecoration(
    color: theme.surfaceContainer,       // #F2F1EF light, #1A1A1A dark
    border: Border.all(theme.outline),   // #D4D3D1 light, #3A3A3A dark
    borderRadius: radiusMd,              // 12dp
  ),
  // NO boxShadow. Ever.
)
```

### 1.5 Icons & Motion

**Icons**: Lucide Icons, 24dp, 1.5px stroke. `CupertinoIcons` for platform-native (back arrow, share).

**Motion**:
| Pattern | Duration | Curve |
|---------|----------|-------|
| Page transition | 300ms | `easeInOutCubic` |
| Bottom sheet open | 350ms | `easeOutCubic` |
| Inline edit field appear | 200ms | `easeOut` |
| Amount count-up | 600ms | `easeOutExpo` |
| Cascade ripple (visual confirmation) | 150ms | `easeIn` — brief highlight on updated values |
| Shimmer loading | 1500ms | `linear` (loop) |
| Undo snackbar | 5000ms display | slide up |

---

## 2. Screen Designs

### Legend for All Wireframes

```
[E] = Editable (tap to edit inline or open edit sheet)
[C] = Computed (derived value, shows source on tap)
[→] = Navigates to detail screen
[⋮] = Overflow menu (Edit, Delete, etc.)
🟢/🟡/🔴 = Sync status dot
━━━ = Divider line
◉/○ = Selected/unselected toggle
```

### Color annotations in wireframes
```
{income}  = income token (green in both themes)
{expense} = expense token (red in both themes)
{warning} = warning token (amber in both themes)
{neutral} = onSurfaceVariant (gray in both themes)
{surface} = surface background
{card}    = surfaceContainer background
```

---

### 2.1 Lock Screen

```
{surface} background

┌─────────────────────────────┐
│                             │
│                             │
│         ◇ VAEL ◇            │  Logo: geometric diamond
│                             │  {primary} color in both themes
│     Welcome back, Ajit      │  displayMedium, {onSurface}
│                             │
│   ┌───────────────────────┐ │
│   │  ● ● ● ●  ● ● ● ●   │ │  Passphrase input (masked)
│   └───────────────────────┘ │  {outline} border → {primary} on focus
│                             │
│   ┌───────────────────────┐ │
│   │     🔐 Use Biometric   │ │  Outlined button, {primary} border
│   └───────────────────────┘ │
│                             │
│   🟢 Encrypted & private    │  bodySmall, {onSurfaceVariant}
│   Your data never leaves    │  {primary} dot = encryption active
│   this device               │
│                             │
└─────────────────────────────┘
```

**Theme behavior**:
- Light: warm off-white bg, dark text, green accents
- Dark: near-black bg (#0F0F0F), light text, brighter green logo
- Logo: same SVG, color switches via `Theme.of(context).colorScheme.primary`
- Biometric auto-triggers on launch → success → animate logo expand → dashboard

---

### 2.2 Dashboard

The hub. Every number traces back to an account. Every section links to its detail screen.

#### Phone Layout — Light Mode
```
{surface} background
┌─────────────────────────────┐
│  ◇ Dashboard      🟢  🔔 👤 │  Sync dot in header
├─────────────────────────────┤
│                             │
│  Net Worth              [C] │  {onSurfaceVariant} label
│  ₹42,15,678        {income} │  displayLarge, animated count-up
│  ↑ ₹1,23,456 this month    │  bodySmall {income}, tap → breakdown
│                             │
│  {card} ┌──────────────────┐│
│  │ ▁▂▃▄▅▆▇█▇▅▆▇█          ││  Net worth 6mo chart
│  │ {chartLine1} area fill  ││  Tap point → tooltip with date+value
│  │ Sep  Oct  Nov  Dec  Jan ││  {onSurfaceVariant} axis labels
│  └──────────────────────────┘│
│                             │
│  March 2026                 │  headlineMedium
│  {card}┌───────┐┌───────┐┌──┐│
│  │ Income  [C]││Expense ││Net ││
│  │ +₹2.1L    ││ -₹1.4L ││+70K││  Each card tappable [→]
│  │ {income}   ││{expense}││{income}│  → Transaction list (filtered)
│  │ 🏦 3 accts ││🏦 3 accts││[C] ││  Account count badge
│  └───────┘└───────┘└──────┘│
│                             │
│  Accounts              All→ │  headlineMedium + nav link
│  {card}┌───────────────────┐│
│  │ 🏦 HDFC Savings    [→] ││  [E] on detail screen, not here
│  │    ₹3,24,567   {income} ││  Account badge IS the row itself
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 💳 HDFC Credit     [→] ││
│  │    -₹12,450    {expense}││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 📈 Zerodha         [→] ││
│  │    ₹18,54,320  {income} ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🏠 Home Loan       [→] ││
│  │    -₹28,12,340 {expense}││
│  └─────────────────────────┘│
│                             │
│  Budget: March         All→ │
│  {card}┌───────────────────┐│
│  │ Essential     ████░░ 67%││  Progress bar {income}
│  │ ₹52K / ₹78K        [C] ││  Computed from transactions
│  │ 🏦 shared accounts     ││  Account source badge
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ Non-Essential ████████⚠ ││  {expense} bar when over
│  │ ₹33K / ₹30K   {warning}││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ Investments   ██░░░░ 33%││  {income}
│  │ ₹10K / ₹30K        [C] ││
│  └─────────────────────────┘│
│                             │
│  Goals                 All→ │
│  ←scroll─────────────────→  │
│  {card}┌──────────┐┌──────────┐│
│  │ 🎯 Emergency  ││🎓 Education││  Horizontal scroll
│  │    Fund   [→] ││   Fund [→]││
│  │  ┌────┐       ││  ┌────┐   ││
│  │  │72% │ {inc} ││  │24% │{w}││  Circular progress
│  │  └────┘       ││  └────┘   ││
│  │ ₹7.2L/₹10L   ││ ₹4.8L/₹20L││
│  │ 🏦 HDFC+Groww ││ 🏦 PPF    ││  Linked accounts shown
│  │ ON TRACK  🟢  ││ AT RISK 🟡││
│  └──────────┘└──────────┘│
│                             │
├─────────────────────────────┤
│ 🏠    💰    [+]   📊    ⋯  │  Bottom nav
│ Home  Accts  Add  Budget More│
└─────────────────────────────┘
```

#### Phone Layout — Dark Mode (same structure, token colors swap)
```
{surface: #0F0F0F} background
┌─────────────────────────────┐
│  ◇ Dashboard      🟢  🔔 👤 │  Same layout
├─────────────────────────────┤
│                             │
│  Net Worth              [C] │  {onSurfaceVariant: #A3A3A0}
│  ₹42,15,678   {income:#6ECF6E}│  Brighter green on dark
│  ↑ ₹1,23,456 this month    │
│                             │
│  {card: #1A1A1A}┌──────────┐│
│  │ Chart with {chartLine1:  ││  #7BC470 line on dark bg
│  │  #7BC470} line           ││  More vivid, less washed out
│  │ {chartGrid: #252525}     ││  Subtle grid
│  └──────────────────────────┘│
│  ...                        │  All structure identical
│  {outline: #3A3A3A} borders │  Darker borders
│                             │
│  Amounts:                   │
│  Income:  {income: #6ECF6E} │  Lighter green
│  Expense: {expense: #F2B8B5}│  Salmon pink (not harsh red)
│  Warning: {warning: #D4A843}│  Warm gold
│                             │
└─────────────────────────────┘
```

#### Tablet/Desktop Layout (Both Themes)
```
┌──────┬──────────────────────────────────────────────┐
│{card}│  Dashboard                        🟢  🔔 👤  │
│      ├──────────────────────┬───────────────────────┤
│ ◉    │  {card}              │  {card}               │
│ 🏠   │  Net Worth       [C] │  March 2026           │
│ Home │  ₹42,15,678          │  ┌──────┐┌──────┐┌──┐│
│      │  ↑₹1.2L              │  │Income││Expense││Net││
│ ○    │                      │  │+₹2.1L││-₹1.4L││+70││
│ 💰   │  ┌──────────────┐   │  └──────┘└──────┘└──┘│
│ Accts│  │ Larger chart  │   │                       │
│      │  │ with hover    │   │  Budget: March        │
│ ○    │  │ tooltips      │   │  ████░░░ Essential 67%│
│ 📊   │  └──────────────┘   │  ████████ Non-Ess  ⚠  │
│Budget│                      │  ██░░░░░ Invest   33% │
│      ├──────────────────────┼───────────────────────┤
│ ○    │  Accounts            │  Goals                │
│ 🎯   │  {card} rows with   │  {card} grid, 3 across│
│ Goals│  hover highlight     │  with progress circles│
│      │  🏦 HDFC   ₹3.2L    │  🎯 Emergency   72% ✓│
│ ○    │  💳 HDFC  -₹12K     │  🎓 Education   24% ⚠│
│ 🏠   │  📈 Zerodha ₹18.5L  │  🏖️ Vacation    55% ✓│
│ Loans│  🏠 Home  -₹28.1L   │                       │
│      │  All accounts [→]   │  All goals [→]        │
│ ○ ⚙️ │                      │                       │
└──────┴──────────────────────┴───────────────────────┘

Side nav: {surfaceContainer} bg, {primary} for selected item,
{onSurfaceVariant} for unselected. Same in both themes.
```

**Dashboard edit interactions**: Dashboard is read-only (computed aggregates). Every value is tappable to navigate to its source screen where editing happens. Tap net worth → net worth breakdown → tap account → account detail (editable). This preserves the principle: **edit at the source, view everywhere**.

---

### 2.3 Accounts Screen

#### Phone: Account List (with inline account editing)

```
┌─────────────────────────────┐
│  ← Accounts       🟢  + Add│
├─────────────────────────────┤
│  Total: ₹38,12,897  [C]    │  {income} if positive
│                             │
│  BANKING                    │  labelSmall, {onSurfaceVariant}
│  {card}┌───────────────────┐│
│  │ 🏦 HDFC Savings    [E]⋮││  [E] = tap name to edit
│  │    ₹3,24,567       [→] ││  [→] = tap amount → detail
│  │    Last txn: Today      ││  bodySmall, {onSurfaceVariant}
│  │    👁 Shared with family ││  Visibility badge
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🏦 SBI Savings     [E]⋮││
│  │    ₹1,45,230       [→] ││
│  │    Last txn: 3 days ago ││
│  │    🔒 Private           ││  Not shared
│  └─────────────────────────┘│
│                             │
│  INVESTMENTS                │
│  {card}┌───────────────────┐│
│  │ 📈 Zerodha         [E]⋮││
│  │    ₹18,54,320      [→] ││
│  │    ↑12.4% returns   [C] ││  Computed from holdings
│  │    👁 Shared             ││
│  └─────────────────────────┘│
│                             │
│  CREDIT CARDS               │
│  {card}┌───────────────────┐│
│  │ 💳 HDFC Regalia    [E]⋮││
│  │    -₹12,450    {expense}││
│  │    Due: 25 Mar      [E] ││  Editable due date
│  │    👁 Shared             ││
│  └─────────────────────────┘│
│                             │
│  LOANS                      │
│  {card}┌───────────────────┐│
│  │ 🏠 Home Loan - SBI [E]⋮││
│  │    -₹28,12,340 {expense}││
│  │    EMI: ₹32,456/mo [E] ││  Tap → loan detail
│  │    👁 Shared             ││
│  └─────────────────────────┘│
│                             │
│  WALLET                     │
│  {card}┌───────────────────┐│
│  │ 👛 Cash in hand    [E]⋮││
│  │    ₹5,000          [E] ││  Manual balance, editable
│  │    👁 Private            ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘

Long-press any account row:
┌─────────────────────┐
│  ✏️  Edit Account     │
│  👁  Toggle Visibility│
│  📄  Import Statement │
│  🗑️  Delete Account   │  {expense} color, confirmation required
└─────────────────────┘

Swipe left on any account:
  ┌─────────────────────────┬──────┐
  │ 🏦 HDFC Savings ₹3.2L  │🗑 Del│  {expense} bg
  └─────────────────────────┴──────┘
```

#### Account Edit (Bottom Sheet)

```
┌─────────────────────────────┐
│  ─── drag handle ───        │
│                             │
│  Edit Account               │  headlineMedium
│                             │
│  Name                   [E] │
│  ┌─────────────────────────┐│
│  │  HDFC Savings            ││  Pre-filled, tap to edit
│  └─────────────────────────┘│
│                             │
│  Type                   [E] │
│  ┌─────────────────────────┐│
│  │  🏦 Savings           > ││  Dropdown: Savings, Current,
│  └─────────────────────────┘│  Credit Card, Loan, Investment, Wallet
│                             │
│  Institution            [E] │
│  ┌─────────────────────────┐│
│  │  HDFC Bank               ││
│  └─────────────────────────┘│
│                             │
│  Currency               [E] │
│  ┌─────────────────────────┐│
│  │  ₹ INR               >  ││
│  └─────────────────────────┘│
│                             │
│  Visibility             [E] │
│  ◉ Shared with family       │  Toggle
│  ○ Private to me            │
│                             │
│  ┌─────────────────────────┐│
│  │      Save Changes        ││  {primary} filled button
│  └─────────────────────────┘│
│                             │
│  CASCADE PREVIEW:           │  bodySmall, {onSurfaceVariant}
│  Changing type will         │  Show cascade impact before save
│  reclassify in net worth    │
│  breakdown.                 │
│                             │
└─────────────────────────────┘
```

**Cascade preview**: Before saving edits, show a brief summary of what will change on other screens. This builds user confidence that the app handles consistency.

---

### 2.4 Account Detail

```
┌─────────────────────────────┐
│  ← HDFC Savings   🟢   [⋮] │  ⋮: Edit, Import, Delete
├─────────────────────────────┤
│                             │
│  Balance                [C] │  Computed from transactions
│  ₹3,24,567                 │  displayMedium, {income}
│  (calculated from txns)     │  bodySmall, {onSurfaceVariant}
│                             │
│  {card}┌──────────────────┐ │
│  │ Balance trend (6mo)    │ │  Area chart, {chartLine1}
│  │ Tap any point for value│ │  From balance_snapshots
│  └────────────────────────┘ │
│                             │
│  Quick Stats            [C] │
│  {card}┌──────┐┌──────┐    │
│  │ This Month ││ Avg Mo│    │
│  │ In: +₹1.2L ││In:+₹1.1L│  Computed aggregates
│  │ Out:-₹45K  ││Out:-₹42K│
│  └──────┘└──────┘           │
│                             │
│  Transactions          All→ │
│                             │
│  Today                      │
│  {card}┌───────────────────┐│
│  │ 🍕 Swiggy        [E][⋮]││  Every transaction editable
│  │    Food · HDFC Sav  [E] ││  Category editable inline
│  │              -₹456  [E] ││  Amount editable
│  │    🏦 HDFC Savings      ││  Account badge (this account)
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🛒 Amazon         [E][⋮]││
│  │    Shopping · HDFC  [E] ││
│  │            -₹2,340  [E] ││
│  │    🏦 HDFC Savings      ││
│  └─────────────────────────┘│
│                             │
│  Yesterday                  │
│  {card}┌───────────────────┐│
│  │ 💰 Salary         [E][⋮]││
│  │    Income · HDFC    [E] ││
│  │          +₹1,20,000 [E] ││  {income}
│  │    🏦 HDFC Savings      ││
│  └─────────────────────────┘│
│                             │
│  {card}┌───────────────────┐│
│  │  📄 Import Statement    ││  Outlined button, {secondary}
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

**Inline transaction editing**: Tap the amount → number pad appears inline → edit → save → account balance recomputes → dashboard updates. Tap category chip → category picker appears → change → budget actuals recompute.

---

### 2.5 Transaction List

```
┌─────────────────────────────┐
│  ← Transactions    🟢 🔍 ⇅ │
├─────────────────────────────┤
│  ┌──┐ ┌──────┐ ┌─────────┐ │  Filter chips (scrollable)
│  │◉All│ │○Income│ │○Expense │ │
│  └──┘ └──────┘ └─────────┘ │
│  ┌──────────┐ ┌───────────┐ │
│  │ ○Transfer │ │○EMI/Ins   │ │
│  └──────────┘ └───────────┘ │
│  ┌────────────┐┌───────────┐│  Second row: date + account
│  │📅 Mar 2026 ││🏦All Accts ││  Both editable/filterable
│  └────────────┘└───────────┘│
├─────────────────────────────┤
│                             │
│  20 March 2026              │
│  {card}┌───────────────────┐│
│  │ 🍕 Swiggy         [E][⋮]││  Long-press: Edit, Dup, Delete
│  │    Food & Dining    [E] ││  Tap category → change
│  │    🏦 HDFC Savings      ││  Account badge — always visible
│  │              -₹456  [E] ││  {expense}
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🛒 Amazon          [E][⋮]││
│  │    Shopping         [E] ││
│  │    💳 HDFC Credit       ││  Different account badge
│  │            -₹2,340  [E] ││  {expense}
│  └─────────────────────────┘│
│                             │
│  19 March 2026              │
│  {card}┌───────────────────┐│
│  │ 💰 March Salary    [E][⋮]││
│  │    Income           [E] ││
│  │    🏦 HDFC Savings      ││
│  │          +₹1,20,000 [E] ││  {income}
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ ↔ Transfer to Zerodha   ││  {neutral} — no +/-
│  │    Transfer              ││
│  │    🏦 HDFC → 📈 Zerodha  ││  Both accounts shown
│  │             ₹25,000     ││  {neutral}
│  └─────────────────────────┘│
│                             │
│                      ┌────┐ │
│                      │ +  │ │  FAB: New Transaction
│                      └────┘ │
└─────────────────────────────┘

Swipe actions on any transaction:
  ←┌────────────────────┬──────┬──────┐
   │ 🍕 Swiggy  -₹456  │📋 Dup│🗑 Del│
   └────────────────────┴──────┴──────┘
```

---

### 2.6 Add/Edit Transaction (Bottom Sheet)

This is the most critical edit surface. Used for both create and edit.

```
┌─────────────────────────────┐
│  ─── drag handle ───        │
│                             │
│  New Transaction            │  headlineMedium
│  (or "Edit Transaction")    │  Pre-filled when editing
│                             │
│  ┌──────┐┌──────┐┌─────┐┌───┐│
│  │◉Expen││○Incom││○Trans││○EMI││ Segmented control
│  │ se   ││ e    ││ fer  ││   ││ Changes form fields below
│  └──────┘└──────┘└─────┘└───┘│
│                             │
│  ₹ 456                     │  displayLarge, auto-focus
│  ━━━━━━━━━━━━━━━━━━━━━━━━  │  Underline, calculator-style input
│                             │
│  📅 Date                [E] │
│  ┌─────────────────────────┐│
│  │  20 Mar 2026          > ││  Tap → date picker
│  └─────────────────────────┘│
│                             │
│  📝 Description         [E] │
│  ┌─────────────────────────┐│
│  │  Swiggy                  ││  Free text
│  └─────────────────────────┘│
│                             │
│  🏦 Account             [E] │
│  ┌─────────────────────────┐│
│  │  🏦 HDFC Savings      > ││  Account picker
│  └─────────────────────────┘│
│                             │
│  📁 Category            [E] │
│  ┌─────────────────────────┐│
│  │  🍕 Food & Dining     > ││  Category picker
│  └─────────────────────────┘│
│                             │
│  ─── Transfer only ─────── │
│  ➡️ To Account           [E] │
│  ┌─────────────────────────┐│
│  │  📈 Zerodha            > ││  Second account picker
│  └─────────────────────────┘│
│                             │
│  Self-transfer note:        │  bodySmall, {onSurfaceVariant}
│  Both accounts are yours.   │
│  Net worth won't change.    │  Shown when both accts same family
│  ─────────────────────────  │
│                             │
│  ─── EMI Payment only ──── │  (shown when EMI tab selected)
│  🏦 Pay From            [E] │
│  ┌─────────────────────────┐│
│  │  🏦 HDFC Savings      > ││  Source account
│  └─────────────────────────┘│
│  🏠 Loan Account         [E] │
│  ┌─────────────────────────┐│
│  │  🏠 Home Loan — SBI   > ││  Only shows LOAN type accounts
│  └─────────────────────────┘│
│                             │
│  EMI Breakdown          [C] │  Auto-computed from amortization
│  ┌─────────────────────────┐│
│  │ Total EMI:    ₹32,456   ││
│  │ Principal:    ₹9,512    ││  {income} — reduces outstanding
│  │ Interest:     ₹22,944   ││  {expense} — pure cost
│  │                         ││
│  │ Outstanding after:      ││
│  │ ₹28,12,340 → ₹28,02,828││  Shows reduction
│  └─────────────────────────┘│
│  ─────────────────────────  │
│                             │
│  CASCADE PREVIEW            │  {onSurfaceVariant}, bodySmall
│  ┌─────────────────────────┐│
│  │ Expense/Transfer:       ││
│  │ 🏦 HDFC Savings:        ││
│  │    ₹3,24,567 → ₹3,24,111││ Show balance impact
│  │ 📊 Food budget:          ││
│  │    ₹18,044 → ₹18,500   ││  Show budget impact
│  │                         ││
│  │ EMI Payment:            ││  (shown for EMI type)
│  │ 🏦 Source balance:       ││
│  │    ₹3,24,567 → ₹2,92,111││
│  │ 🏠 Loan outstanding:    ││
│  │    ₹28,12,340→₹28,02,828││ Principal portion reduces loan
│  │ 📊 Budget (EMI):        ││
│  │    +₹32,456 to Essential ││ EMI counts as expense in budget
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │      Save Transaction    ││  {primary} filled button
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

**Account picker** (nested bottom sheet):
```
┌─────────────────────────────┐
│  ─── drag handle ───        │
│  Select Account      🔍     │
├─────────────────────────────┤
│                             │
│  BANKING                    │
│  🏦 HDFC Savings   ₹3.2L   │  Show balance to help user choose
│  🏦 SBI Savings    ₹1.4L   │
│                             │
│  INVESTMENTS                │
│  📈 Zerodha        ₹18.5L  │
│  📈 Groww MF       ₹5.1L   │
│                             │
│  CREDIT CARDS               │
│  💳 HDFC Regalia   -₹12K   │
│                             │
│  WALLET                     │
│  👛 Cash           ₹5K     │
│                             │
└─────────────────────────────┘
```

**Category picker** (nested bottom sheet):
```
┌─────────────────────────────┐
│  ─── drag handle ───        │
│  Select Category     🔍     │
├─────────────────────────────┤
│                             │
│  ESSENTIAL                  │  Group headers
│  🍕 Food & Dining           │
│  🏠 Rent                    │
│  ⚡ Utilities               │
│  🚗 Transport               │
│  🏥 Healthcare              │
│  📱 Phone & Internet        │
│                             │
│  NON-ESSENTIAL              │
│  🛒 Shopping                │
│  🎬 Entertainment           │
│  ✈️ Travel                   │
│  👤 Personal Care           │
│                             │
│  HOME EXPENSES              │
│  🔧 Maintenance             │
│  🧹 Household               │
│                             │
│  INVESTMENTS                │
│  📈 SIP / Mutual Funds      │
│  💰 Fixed Deposits           │
│  📊 Stocks                  │
│                             │
└─────────────────────────────┘
```

**Edit mode specifics**:
- When editing an existing transaction, the sheet title changes to "Edit Transaction"
- All fields pre-filled with current values
- The CASCADE PREVIEW shows the **delta** from old → new
- Changing the account triggers a cascade preview showing impact on BOTH the old and new account
- "Delete" button appears at bottom in {expense} color with confirmation dialog

---

### 2.7 Budget Screen

```
┌─────────────────────────────┐
│  ← Budget           🟢  ✏️ │  ✏️ → edit mode (limits become editable)
├─────────────────────────────┤
│  ◀  March 2026          ▶  │  Month navigator
│                             │
│  Total Budget           [C] │
│  ₹1,40,000                 │  displayMedium
│  Spent: ₹98,450 (70%)  [C] │  Computed from transactions
│  ████████████░░░░░░░   {income}│  Overall progress bar
│  🏦 Based on shared accounts│  Account source
│                             │
├─────────────────────────────┤
│                             │
│  Essential              [→] │  Tap → transaction list filtered
│  ₹65,000 / ₹80,000 [C]/[E] │  Actual is [C], Limit is [E]
│  ████████████████░░░░  81%  │  {income} (under budget)
│  {card}┌───────────────────┐│
│  │ 🍕 Food        [C]     ││
│  │   ₹18,500 / ₹20,000 [E]││  Tap limit → inline edit
│  │   ████████████████░░92% ││  {warning} (close to limit)
│  │   🏦 HDFC+SBI           ││  Source accounts
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🏠 Rent         [C]     ││
│  │   ₹25,000 / ₹25,000 [E]││
│  │   ██████████████████100%││  {onSurface} (exact)
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ ⚡ Utilities     [C]     ││
│  │   ₹4,200 / ₹8,000   [E]││
│  │   ██████████░░░░░░░ 53% ││  {income}
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🚗 Transport     [C]     ││
│  │   ₹8,300 / ₹12,000  [E]││
│  │   █████████████░░░░ 69% ││  {income}
│  └─────────────────────────┘│
│                             │
│  Non-Essential       ⚠  [→] │  {warning} badge
│  ₹33,450 / ₹30,000 [C]/[E] │
│  ██████████████████████112% │  {expense} bar
│  {card}┌───────────────────┐│
│  │ 🛒 Shopping      [C]     ││
│  │   ₹15,340 / ₹12,000 [E]││  {expense} — over
│  │   ██████████████████128%││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🎬 Entertainment  [C]     ││
│  │   ₹8,110 / ₹8,000   [E]││  {warning}
│  │   █████████████████ 101%││
│  └─────────────────────────┘│
│                             │
│  Investments            [→] │
│  ₹25,000 / ₹30,000 [C]/[E] │
│  ████████████████░░░░  83%  │  {income}
│                             │
└─────────────────────────────┘

Edit mode (tap ✏️):
  All [E] limit fields become active input fields
  with up/down steppers (₹1,000 increments)
  ┌─────────────────────────┐
  │ Food   ₹20,000  [-][+]  │  Inline stepper
  │ Rent   ₹25,000  [-][+]  │
  └─────────────────────────┘
  "Save Budgets" button appears at bottom
```

**Budget cascade**: Editing a budget limit only affects the Budget screen and Dashboard budget section. But when a **transaction** is edited (amount, category, account), budget actuals recompute automatically across all affected category groups.

---

### 2.8 Goals Screen

```
┌─────────────────────────────┐
│  ← Goals            🟢 + Add│
├─────────────────────────────┤
│                             │
│  {card}┌───────────────────┐│
│  │                         ││
│  │  🎯 Emergency Fund [E][⋮]││  Name editable, overflow menu
│  │                         ││
│  │     ┌─────┐             ││
│  │     │ 72% │ {income}    ││  Circular progress
│  │     │  ✓  │             ││  Check = on track
│  │     └─────┘             ││
│  │                         ││
│  │  ₹7,20,000 / ₹10,00,000││  [E] current / [E] target
│  │  🏦 HDFC Savings + Groww ││  Linked accounts
│  │  Target: Dec 2026   [E] ││  Editable
│  │  Inflation: 6%      [E] ││  Editable
│  │  Adj target: ₹10.6L [C] ││  Computed
│  │  SIP needed: ₹31,111[C] ││  Computed
│  │  Status: ON TRACK 🟢[C] ││  Computed from savings vs SIP
│  │                         ││
│  │  Linked Accounts:       ││  Show which accounts feed this
│  │  🏦 HDFC    ₹4.2L       ││
│  │  📈 Groww   ₹3.0L       ││
│  │  ┌──────────────────┐   ││
│  │  │ + Link Account   │   ││  Add account to goal
│  │  └──────────────────┘   ││
│  └─────────────────────────┘│
│                             │
│  {card}┌───────────────────┐│
│  │  🎓 Aarav's Edu   [E][⋮]││
│  │     ┌─────┐             ││
│  │     │ 24% │ {warning}   ││
│  │     │  ⚠  │             ││
│  │     └─────┘             ││
│  │  ₹4,80,000 / ₹20,00,000││
│  │  🏦 PPF                 ││
│  │  Target: Mar 2032   [E] ││
│  │  Inflation: 7%      [E] ││
│  │  Adj target: ₹26.8L [C] ││  {warning} — inflation impact
│  │  SIP needed: ₹30,556[C] ││
│  │  Status: AT RISK  🟡[C] ││  {warning}
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘

Goal Edit (tap [E] on name or ⋮ → Edit):
┌─────────────────────────────┐
│  ─── drag handle ───        │
│  Edit Goal                  │
│                             │
│  Name                   [E] │
│  ┌─────────────────────────┐│
│  │  Emergency Fund          ││
│  └─────────────────────────┘│
│  Target Amount          [E] │
│  ┌─────────────────────────┐│
│  │  ₹ 10,00,000            ││
│  └─────────────────────────┘│
│  Target Date            [E] │
│  ┌─────────────────────────┐│
│  │  Dec 2026             >  ││
│  └─────────────────────────┘│
│  Current Savings        [E] │
│  ┌─────────────────────────┐│
│  │  ₹ 7,20,000             ││  Or auto-compute from linked accts
│  └─────────────────────────┘│
│  Inflation Rate         [E] │
│  ┌─────────────────────────┐│
│  │  6  %                    ││
│  └─────────────────────────┘│
│  Priority               [E] │
│  ┌──────┐┌──────┐┌────────┐│
│  │○ Low ││◉ Med ││○ High  ││
│  └──────┘└──────┘└────────┘│
│                             │
│  CASCADE PREVIEW            │
│  ┌─────────────────────────┐│
│  │ SIP: ₹31,111 → ₹28,889 ││  Computed impact
│  │ Status: ON TRACK (no Δ) ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │      Save Goal           ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │      Delete Goal         ││  {expense} outlined
│  └─────────────────────────┘│
└─────────────────────────────┘
```

---

### 2.9 Loan Detail

```
┌─────────────────────────────┐
│  ← Home Loan — SBI 🟢  [⋮] │  ⋮: Edit Details, Delete
├─────────────────────────────┤
│                             │
│  Outstanding            [C] │
│  ₹28,12,340                │  displayMedium, {expense}
│  🏦 SBI Home Loan account  │  Account badge
│                             │
│  {card}┌──────┐┌──────┐    │
│  │ EMI   [E] ││ Rate [E]│  │  ALL loan params editable
│  │ ₹32,456   ││ 8.5%    │  │
│  │ /month    ││ p.a.    │  │
│  └──────┘└──────┘           │
│  {card}┌──────┐┌──────┐    │
│  │ Tenure [C]││ Int  [C]│  │  Computed from schedule
│  │ 18y 4m    ││ ₹12.4L  │  │
│  │ remaining ││ remaining│  │
│  └──────┘└──────┘           │
│                             │
│  Amortization           [C] │  headlineMedium
│  {card}┌───────────────────┐│
│  │ Month│  EMI │Princ│ Int ││  Scrollable computed table
│  │━━━━━━┿━━━━━━┿━━━━━┿━━━━││
│  │Apr'26│32,456│9,512│22.9K││  Not editable (derived)
│  │May'26│32,456│9,579│22.8K││  Tap row → tooltip with
│  │Jun'26│32,456│9,647│22.8K││  cumulative principal paid
│  │ ...  │      │     │     ││
│  └─────────────────────────┘│
│  (computed — changes when   │
│   you edit rate/EMI/prepay) │  bodySmall, {onSurfaceVariant}
│                             │
│  ── Adjust Current State ── │  headlineMedium
│  After initial setup, real  │  bodySmall, {onSurfaceVariant}
│  numbers may differ due to  │
│  past prepayments or bank   │
│  adjustments. Edit freely:  │
│                             │
│  {card}┌───────────────────┐│
│  │ Outstanding Princ   [E] ││  Override computed outstanding
│  │ ₹ 28,12,340             ││  User can set to actual bank value
│  │                         ││
│  │ Current EMI         [E] ││  May differ from original calc
│  │ ₹ 32,456                ││  (bank may have restructured)
│  │                         ││
│  │ Current Rate        [E] ││  Floating rate changes
│  │ 8.5 % p.a.              ││  User updates when bank revises
│  │                         ││
│  │ Remaining Tenure    [E] ││  Override if bank adjusted
│  │ 220 months              ││
│  │                         ││
│  │ ┌─────────────────────┐ ││
│  │ │ Save & Recalculate  │ ││  Regenerates amort from
│  │ └─────────────────────┘ ││  current state forward
│  │                         ││
│  │ CASCADE:                ││
│  │ Amort schedule: regen   ││
│  │ Remaining interest: [C] ││
│  │ Projections: recalc     ││
│  └─────────────────────────┘│
│                             │
│  ── Original Loan Details ─ │  headlineMedium
│  {card}┌───────────────────┐│
│  │ Original Princ     [E] ││
│  │ ₹ 45,00,000            ││  For reference / initial calc
│  │ Original Rate      [E] ││
│  │ 8.5 %                  ││
│  │ Original Tenure    [E] ││
│  │ 240 months              ││
│  │ Start Date         [E] ││
│  │ Jan 2020                ││
│  │ Disbursement       [E] ││
│  │ Feb 2020                ││
│  └─────────────────────────┘│
│                             │
│  ── Prepayment ──────────── │  headlineMedium
│  {card}┌───────────────────┐│
│  │ Prepayments go 100%     ││  bodySmall, {onSurfaceVariant}
│  │ to principal — zero     ││  Explicitly stated
│  │ interest charged.       ││
│  │                         ││
│  │ Prepay amount:      [E] ││
│  │ ₹ [        5,00,000  ] ││  Amount input
│  │                         ││
│  │ 🏦 Pay from:        [E] ││
│  │ 🏦 HDFC Savings      >  ││  Source account
│  │                         ││
│  │ Impact preview:     [C] ││
│  │ Outstanding:            ││
│  │  ₹28,12,340 → ₹23,12,340│  100% to principal
│  │ New tenure: 15y 2m      ││  {income}
│  │ Saved: 3y 2m            ││
│  │ Interest saved: ₹4.2L   ││  {income}
│  │                         ││
│  │ ┌─────────────────────┐ ││
│  │ │  Record Prepayment  │ ││  Creates EXPENSE txn (not EMI)
│  │ └─────────────────────┘ ││  + reduces outstanding + regen
│  │                         ││
│  │ CASCADE:                ││
│  │ 🏦 Savings: -₹5L        ││
│  │ 🏠 Outstanding: -₹5L    ││  Full amount = principal
│  │ Net worth: ₹0 change    ││  Asset ↓ = Liability ↓
│  │ Amort schedule: regen   ││
│  │ Remaining interest: ↓   ││
│  └─────────────────────────┘│
│                             │
│  Past Prepayments       [C] │
│  {card}┌───────────────────┐│
│  │ Date    │ Amount │Saved ││
│  │━━━━━━━━━┿━━━━━━━━┿━━━━━━││
│  │ Jun'24  │ ₹2,00,000│₹1.2L││
│  │ Dec'24  │ ₹3,00,000│₹2.1L││
│  │─────────┼────────┼──────││
│  │ Total   │ ₹5,00,000│₹3.3L││  {income}
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

---

### 2.10 Investment Portfolio (Bucket-Based)

Investments are tracked as **purpose-driven buckets**, not individual holdings. The user says "I have ₹12L in my retirement fund" — they don't need to track each mutual fund unit. Each bucket has a type, an estimated return rate, and optionally links to a goal.

**Bucket types** (with platform default returns):

| Bucket Type | Default Return | Description |
|-------------|---------------|-------------|
| `MUTUAL_FUNDS` | 12% p.a. | Equity mutual funds, SIPs |
| `STOCKS` | 12% p.a. | Direct equity |
| `PPF` | 7.1% p.a. | Public Provident Fund (15yr lock-in) |
| `EPF` | 8.15% p.a. | Employee Provident Fund |
| `NPS` | 10% p.a. | National Pension System |
| `FIXED_DEPOSIT` | 7% p.a. | Bank FDs, company FDs |
| `BONDS` | 7.5% p.a. | Govt/corporate bonds |
| `ULIP` | 8% p.a. | Unit-linked insurance plans |
| `POLICY` | 5% p.a. | Endowment, money-back policies |
| `GOLD` | 8% p.a. | Physical gold, SGBs, gold ETFs |
| `REAL_ESTATE` | 6% p.a. | Property investments (non-home) |
| `OTHER_FIXED_INCOME` | 6.5% p.a. | Post office schemes, NSC, SCSS, etc. |

Users can override the return rate per bucket.

#### Portfolio Overview
```
┌─────────────────────────────┐
│  ← Investments    🟢  + Add │
├─────────────────────────────┤
│                             │
│  Total Portfolio        [C] │
│  ₹52,40,000                │  displayLarge, {income}
│  Weighted avg return: 9.8%  │  [C] computed from bucket mix
│                             │
│  {card}┌───────────────────┐│
│  │ Allocation Donut   [C]  ││
│  │    ┌─────────┐          ││
│  │    │  MF 34% │          ││  Donut chart
│  │    │ PPF 19% │          ││  Color per bucket type
│  │    │ EPF 15% │          ││  Tap slice → highlight bucket
│  │    │Stocks12%│          ││
│  │    │  FD 10% │          ││
│  │    │Other 10%│          ││
│  │    └─────────┘          ││
│  └─────────────────────────┘│
│                             │
│  Investment Buckets         │  headlineMedium
│                             │
│  {card}┌───────────────────┐│
│  │ 📈 Mutual Funds  [E][⋮]││
│  │    ₹18,00,000   {income}││  Current value [E]
│  │    Invested: ₹12,00,000 ││  [E] — what you put in
│  │    Returns: +₹6,00,000  ││  [C] = current - invested
│  │    Rate: 12% p.a.   [E] ││  Override or use default
│  │    🏦 Zerodha + Groww   ││  Linked accounts
│  │    🎯 Retirement Fund   ││  Linked goal (if any)
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🏛️ PPF            [E][⋮]││
│  │    ₹10,00,000   {income}││
│  │    Invested: ₹8,40,000  ││
│  │    Returns: +₹1,60,000  ││
│  │    Rate: 7.1% p.a.  [E] ││  Govt rate, editable
│  │    🏦 SBI PPF Account   ││
│  │    🎯 Aarav's Education ││  Linked goal
│  │    Maturity: Apr 2035   ││  [E] lock-in end date
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🏢 EPF            [E][⋮]││
│  │    ₹7,80,000    {income}││
│  │    Invested: ₹6,00,000  ││
│  │    Returns: +₹1,80,000  ││
│  │    Rate: 8.15% p.a. [E] ││
│  │    🏦 EPF Account       ││
│  │    🎯 Retirement Fund   ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 📊 Stocks         [E][⋮]││
│  │    ₹6,20,000    {income}││
│  │    Invested: ₹4,50,000  ││
│  │    Returns: +₹1,70,000  ││
│  │    Rate: 12% p.a.   [E] ││
│  │    🏦 Zerodha           ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🏦 Fixed Deposits [E][⋮]││
│  │    ₹5,00,000    {income}││
│  │    Invested: ₹4,50,000  ││
│  │    Returns: +₹50,000    ││
│  │    Rate: 7% p.a.    [E] ││
│  │    🏦 HDFC FD           ││
│  │    Maturity: Dec 2026   ││  [E]
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🛡️ ULIP           [E][⋮]││
│  │    ₹3,20,000    {income}││
│  │    Invested: ₹3,00,000  ││
│  │    Returns: +₹20,000    ││
│  │    Rate: 8% p.a.    [E] ││
│  │    🏦 LIC ULIP          ││
│  │    Maturity: Jan 2035   ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 📮 Other Fixed Inc[E][⋮]││
│  │    ₹2,20,000    {income}││
│  │    NSC + SCSS            ││  [E] description
│  │    Rate: 6.5% p.a.  [E] ││
│  │    🏦 Post Office        ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

#### Investment Projection (50 Years)

```
┌─────────────────────────────┐
│  ← Investment Projection 🟢│
├─────────────────────────────┤
│                             │
│  {card}┌──────┐┌──────┐┌──┐│
│  │◉ All  ││○ By  ││○ By ││  View tabs
│  │Buckets││Goal  ││Type ││  All / grouped by goal / by type
│  └──────┘└──────┘└──────┘│
│                             │
│  Projection Horizon     [E] │
│  ┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐ │
│  │5y││10y││◉20y││30y││40y││50y│  Quick select
│  └──┘└──┘└──┘└──┘└──┘└──┘ │
│                             │
│  {card}┌───────────────────┐│
│  │                         ││
│  │ ₹52L today         [C] ││  Starting point
│  │           ╱──────       ││  Growth curves per bucket
│  │      ╱──╱╱  ₹2.8Cr     ││  Stacked area chart
│  │  ╱─╱╱╱╱     in 20yr    ││  Each bucket = colored band
│  │╱╱╱╱                     ││
│  │ '26 '30 '35 '40 '46    ││
│  │                         ││
│  │ Legend:                 ││
│  │ ██ MF  ██ PPF  ██ EPF  ││  Color-coded
│  │ ██ Stocks ██ FD ██ Other││
│  └─────────────────────────┘│
│                             │
│  Projected Values       [C] │
│  {card}┌───────────────────┐│
│  │ Horizon │ Value │ Growth ││
│  │━━━━━━━━━┿━━━━━━━┿━━━━━━━││
│  │  5 yr   │₹82.6L │ +₹30L ││
│  │ 10 yr   │₹1.4Cr │ +₹88L ││
│  │ 20 yr   │₹2.8Cr │+₹2.3Cr││  {income} — compound effect
│  │ 30 yr   │₹5.2Cr │+₹4.7Cr││
│  │ 50 yr   │₹14.1Cr│+₹13.6Cr│  Dramatic compound growth
│  └─────────────────────────┘│
│                             │
│  By Bucket (at 20yr)    [C] │
│  {card}┌───────────────────┐│
│  │ Bucket   │ Now  │ 20yr  ││
│  │━━━━━━━━━━┿━━━━━━┿━━━━━━━││
│  │ MF       │₹18L  │ ₹1.1Cr││  12% compound
│  │ PPF      │₹10L  │ ₹39.6L││  7.1% compound
│  │ EPF      │₹7.8L │ ₹37.5L││  8.15% compound
│  │ Stocks   │₹6.2L │ ₹59.7L││  12% compound
│  │ FD       │₹5L   │ ₹19.3L││  7% compound
│  │ ULIP     │₹3.2L │ ₹14.9L││  8% compound
│  │ Other FI │₹2.2L │ ₹7.7L ││  6.5% compound
│  └─────────────────────────┘│
│                             │
│  Course Correction      [C] │  headlineMedium
│  {card}┌───────────────────┐│
│  │ 🎯 Retirement Fund      ││
│  │    Goal: ₹5Cr by 2050   ││
│  │    Projected: ₹4.2Cr    ││  {expense} — shortfall
│  │    Gap: ₹80L         ⚠  ││  {warning}
│  │    To close gap:        ││
│  │    +₹8,500/mo SIP   [→] ││  Actionable suggestion
│  │    (tap to add to        ││  Links to scenario sandbox
│  │     scenario sandbox)    ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🎓 Education Fund       ││
│  │    Goal: ₹26.8L by 2032 ││
│  │    Projected: ₹28.1L    ││  {income} — on track
│  │    Surplus: ₹1.3L    ✓  ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🎯 Emergency Fund       ││
│  │    Goal: ₹10L by 2026   ││
│  │    Projected: ₹10.4L    ││  {income}
│  │    On track          ✓  ││
│  └─────────────────────────┘│
│                             │
│  Assumptions            [E] │  headlineMedium
│  {card}┌───────────────────┐│
│  │ These projections assume:││
│  │ • No additional invest.  ││
│  │ • Returns compound at    ││
│  │   bucket default rates   ││
│  │ • No withdrawals         ││
│  │                          ││
│  │ Edit return rates in     ││
│  │ each bucket above to     ││
│  │ see different outcomes   ││
│  │                          ││
│  │ Include SIPs?       [E]  ││
│  │ ◉ Yes (add ₹25K/mo)     ││  Factor in recurring SIP rules
│  │ ○ No (lump sum only)     ││
│  └─────────────────────────┘│
│                             │
│  CASCADE NOTE:              │
│  Editing bucket values or   │
│  return rates affects:      │
│  • Portfolio value (this pg)│
│  • Linked goal progress     │
│  • Dashboard net worth      │
│  • Projection engine        │
│  • Course correction advice │
│                             │
└─────────────────────────────┘
```

#### Add/Edit Investment Bucket (Bottom Sheet)

```
┌─────────────────────────────┐
│  ─── drag handle ───        │
│                             │
│  New Investment Bucket      │  headlineMedium
│                             │
│  Bucket Type            [E] │
│  ┌─────────────────────────┐│
│  │  📈 Mutual Funds     >  ││  Picker with all types
│  └─────────────────────────┘│
│  (PPF, EPF, NPS, FD, Stocks,│
│   ULIP, Bonds, Gold, Real   │
│   Estate, Other Fixed Inc)  │
│                             │
│  Label (optional)       [E] │
│  ┌─────────────────────────┐│
│  │  Retirement SIPs         ││  User's name for this bucket
│  └─────────────────────────┘│
│                             │
│  Invested Amount        [E] │
│  ┌─────────────────────────┐│
│  │  ₹ 12,00,000            ││  What they've put in
│  └─────────────────────────┘│
│                             │
│  Current Value          [E] │
│  ┌─────────────────────────┐│
│  │  ₹ 18,00,000            ││  What it's worth now
│  └─────────────────────────┘│
│                             │
│  Expected Return        [E] │
│  ┌─────────────────────────┐│
│  │  12  % p.a.              ││  Pre-filled from bucket default
│  └─────────────────────────┘│
│  Platform default: 12%      │  bodySmall reference
│                             │
│  🏦 Linked Account      [E] │
│  ┌─────────────────────────┐│
│  │  📈 Zerodha           >  ││  Which account holds this
│  └─────────────────────────┘│
│                             │
│  🎯 Linked Goal (opt)   [E] │
│  ┌─────────────────────────┐│
│  │  🎯 Retirement Fund  >  ││  Maps to goal for tracking
│  └─────────────────────────┘│
│                             │
│  Maturity Date (opt)    [E] │
│  ┌─────────────────────────┐│
│  │  None                 >  ││  For PPF, FD, ULIP, etc.
│  └─────────────────────────┘│
│                             │
│  CASCADE PREVIEW            │
│  ┌─────────────────────────┐│
│  │ 📊 Portfolio: +₹18L     ││
│  │ 📈 Net worth: +₹18L     ││
│  │ 🎯 Retirement: 72% → 85%││  Goal progress impact
│  │ 50yr projection: +₹4.2Cr││  Long-term compound impact
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │      Save Bucket         ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

---

### 2.11 Projections (Read-Only Computation)

```
┌─────────────────────────────┐
│  ← Projections       🟢 ⚙️ │  ⚙️ → edit projection params
├─────────────────────────────┤
│                             │
│  {card}┌──────┐┌──────┐┌──┐│
│  │◉ Opt ││○ Real││○ Cons││  Scenario tabs
│  │imistic││istic ││ervat.││
│  └──────┘└──────┘└──────┘│
│                             │
│  {card}┌───────────────────┐│
│  │              ╱──  [C]   ││  60-month projection
│  │         ╱──╱╱           ││  3 lines (opt/real/cons)
│  │    ╱──╱╱╱               ││  Shaded confidence band
│  │ ╱╱╱╱                    ││  {chartLine1/2/3}
│  │╱                        ││
│  │ '26  '27  '28  '29  '30││
│  └─────────────────────────┘│
│  Tap chart → tooltip with   │
│  month/income/expense/net   │
│                             │
│  Key Metrics (selected) [C] │
│  {card}┌──────┐┌──────┐    │
│  │ Net Worth ││ Monthly│    │
│  │ in 5yr    ││ Savings│    │
│  │ ₹1.2Cr   ││ ₹72K   │    │
│  │ {income}  ││ avg    │    │
│  └──────┘└──────┘           │
│  {card}┌──────┐┌──────┐    │
│  │ First     ││ Total  │    │
│  │ Deficit   ││Interest│    │
│  │ Never ✓   ││ Earned │    │
│  │ {income}  ││ ₹32.4L │    │
│  └──────┘└──────┘           │
│                             │
│  All projections are        │
│  computed from your current │
│  accounts, recurring rules, │
│  and loan schedules. Edit   │
│  those to change projections│  {onSurfaceVariant} helper text
│                             │
│  Inputs powering this:  [→] │
│  🏦 12 accounts             │
│  🔄 8 recurring rules       │
│  🏠 2 loans                 │
│  📈 4 investment buckets    │
│  (tap to review/edit)       │
│                             │
└─────────────────────────────┘
```

**Key design choice**: Projections are entirely computed. They cannot be edited directly. Instead, the screen shows a clear "Inputs powering this" section linking back to the editable source entities. This maintains the principle: **edit at source, cascades flow downstream**.

---

### 2.12 Statement Import Flow

#### Step 1: File Selection
```
┌─────────────────────────────┐
│  ← Import Statement  🟢    │
├─────────────────────────────┤
│                             │
│  {card}┌───────────────────┐│
│  │                         ││
│  │   📄 Drop CSV or tap    ││  Dashed border, {outline}
│  │      to browse          ││  Drag-and-drop on desktop
│  │                         ││
│  └─────────────────────────┘│
│                             │
│  Supported: HDFC, SBI,     │
│  ICICI, Generic CSV         │
│                             │
│  Target Account         [E] │
│  ┌─────────────────────────┐│
│  │  🏦 HDFC Savings      > ││  Account picker
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │      Continue            ││  Enabled after file + account
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

#### Step 2: Review & Edit (every row editable)
```
┌─────────────────────────────┐
│  ← Review        23 found   │
├─────────────────────────────┤
│  HDFC Bank format detected  │  {onSurfaceVariant}
│  🏦 Target: HDFC Savings    │  Account badge
│                             │
│  {card}┌───────────────────┐│
│  │ ☑ Swiggy        [E]    ││  Name editable
│  │   -₹456         [E]    ││  Amount editable
│  │   20 Mar 2026   [E]    ││  Date editable
│  │   🍕 Food       [E] [v]││  Category dropdown
│  │   🏦 HDFC Savings      ││  Account badge
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ ☑ Amazon         [E]    ││
│  │   -₹2,340       [E]    ││
│  │   20 Mar 2026   [E]    ││
│  │   🛒 Shopping    [E] [v]││
│  │   🏦 HDFC Savings      ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ ☐ NEFT-Transfer  [E]    ││  Unchecked = skip
│  │   -₹25,000      [E]    ││  {neutral} — detected transfer
│  │   19 Mar 2026   [E]    ││
│  │   ↔ Transfer     [E] [v]││
│  │   🏦 HDFC → ?           ││  Target account unknown
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ ☑ Salary         [E]    ││
│  │   +₹1,20,000    [E]    ││  {income}
│  │   01 Mar 2026   [E]    ││
│  │   💰 Income      [E] [v]││
│  │   🏦 HDFC Savings      ││
│  └─────────────────────────┘│
│                             │
│  3 duplicates auto-skipped  │  bodySmall
│                             │
│  CASCADE PREVIEW            │
│  ┌─────────────────────────┐│
│  │ 🏦 HDFC Savings:        ││
│  │    ₹3,24,567 → ₹4,41,771││ Net balance impact
│  │ 📊 Budget impact:        ││
│  │    Food: +₹456           ││
│  │    Shopping: +₹2,340     ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │  Import 20 Transactions  ││  Count updates with checkboxes
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

---

### 2.13 Family Management

```
┌─────────────────────────────┐
│  ← Family            🟢    │
├─────────────────────────────┤
│                             │
│  Gupta Family           [E] │  Tap name to edit
│  Base currency: ₹ INR  [E] │
│  Created: Jan 2026          │
│                             │
│  Members                    │
│  {card}┌───────────────────┐│
│  │ 👤 Ajit Gupta     [E][⋮]││  Edit role, remove member
│  │    Admin · 3 devices    ││
│  │    Last sync: 2 min 🟢  ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 👤 Pravallika Gupta    [E][⋮]││
│  │    Member · 1 device    ││
│  │    Last sync: 1 hr  🟡  ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │  👥 Invite Family Member ││  {primary} outlined
│  └─────────────────────────┘│
│                             │
│  Security                   │
│  {card}┌───────────────────┐│
│  │ 🔐 Change Passphrase [→]││
│  │ 🗝️ View Recovery Key [→]││
│  │ 📱 Manage Devices    [→]││
│  └─────────────────────────┘│
│                             │
│  Sync Status                │
│  {card}┌───────────────────┐│
│  │ Last push: 2 min ago    ││
│  │ Last pull: 2 min ago    ││
│  │ Pending changes: 0  🟢  ││
│  │                         ││
│  │ ┌─────────────────────┐ ││
│  │ │  🔄 Force Sync Now  │ ││  {secondary} outlined
│  │ └─────────────────────┘ ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

---

### 2.14 Settings

```
┌─────────────────────────────┐
│  ← Settings          🟢    │
├─────────────────────────────┤
│                             │
│  Appearance                 │
│  {card}┌───────────────────┐│
│  │ Theme                [E]││
│  │ ┌──────┐┌──────┐┌─────┐││  Segmented control
│  │ │○ Light││◉ System││○ Dark│││  Visual preview swatch
│  │ └──────┘└──────┘└─────┘││  Instant theme switch, no restart
│  │                         ││
│  │ Currency             [E]││
│  │ ₹ Indian Rupee (INR) > ││
│  └─────────────────────────┘│
│                             │
│  Security                   │
│  {card}┌───────────────────┐│
│  │ Biometric Unlock [E][●] ││  Toggle
│  │ Auto-lock        [E]   ││
│  │   5 minutes          >  ││  Picker: 1m, 5m, 15m, 30m, never
│  │ Screen Privacy   [E][●] ││  Blur in app switcher
│  └─────────────────────────┘│
│                             │
│  Data                       │
│  {card}┌───────────────────┐│
│  │ Export Data (Encrypted)>││
│  │ Import from Backup    > ││
│  │ Migrate from Storely  > ││
│  └─────────────────────────┘│
│                             │
│  Sync                       │
│  {card}┌───────────────────┐│
│  │ Google Drive   [E] On 🟢││
│  │ Auto-sync      [E] [●] ││
│  │ Sync Freq      [E]     ││
│  │   15 minutes         >  ││
│  └─────────────────────────┘│
│                             │
│  Categories             [→] │
│  {card}┌───────────────────┐│
│  │ Manage Categories    >  ││  Full CRUD on categories
│  │ Manage Category Groups> ││  Edit group assignments
│  └─────────────────────────┘│
│                             │
│  Recurring Rules        [→] │
│  {card}┌───────────────────┐│
│  │ Manage Recurring     >  ││  Full CRUD
│  │ Income rules: 3         ││
│  │ Expense rules: 5        ││
│  └─────────────────────────┘│
│                             │
│  About                      │
│  {card}┌───────────────────┐│
│  │ Version          1.0.0  ││
│  │ Encryption    AES-256 🟢││
│  │ Database         OK  🟢 ││  Health check
│  │ Open Source Licenses  > ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

---

### 2.15 Onboarding Flow

Same structure as v1 but with explicit theme handling:

```
Onboarding uses system theme preference from device.
If device is in dark mode → onboarding renders in dark mode.
No manual toggle during onboarding — it appears after setup.

Step 1: Welcome → Step 2: Google Sign-In →
Step 3: Create/Join Family → Step 4: Set Passphrase →
Step 5: Recovery Key display → Dashboard
```

All onboarding screens use the same token system, so they automatically render correctly in both themes.

---

### 2.16 Recurring Rules

The recurring rules screen manages all automated income and expense entries. The key UX innovation here is **frequency as months** — a single numeric input that covers biweekly (0.5) through annual (12).

#### Recurring Rules List
```
┌─────────────────────────────┐
│  ← Recurring Rules  🟢 +Add│
├─────────────────────────────┤
│                             │
│  Upcoming This Week         │  headlineMedium
│  {card}┌───────────────────┐│
│  │ 🔴 HDFC EMI    21 Mar  ││  Due date badge
│  │    -₹32,456    {expense}││
│  │    🏦 HDFC Savings      ││  Account badge
│  │    Monthly (1mo)        ││  Frequency shown
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🟡 Netflix     23 Mar  ││  Yellow = upcoming soon
│  │    -₹649       {expense}││
│  │    💳 HDFC Credit       ││
│  │    Monthly (1mo)        ││
│  └─────────────────────────┘│
│                             │
│  INCOME                     │  labelSmall, {onSurfaceVariant}
│  {card}┌───────────────────┐│
│  │ 💰 Salary       [E] [⋮]││
│  │    +₹1,20,000  {income} ││
│  │    🏦 HDFC Savings      ││
│  │    Monthly (1mo)        ││
│  │    📈 Hike: 10%/yr  [E] ││  Annual escalation
│  │    Next hike: Apr 2027  ││  Computed from start + hike cycle
│  │    Status: Active 🟢    ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 💰 Freelance     [E] [⋮]││
│  │    +₹35,000    {income} ││
│  │    🏦 SBI Savings       ││
│  │    Quarterly (3mo)      ││
│  │    📈 Hike: 5%/yr   [E] ││
│  │    Status: Active 🟢    ││
│  └─────────────────────────┘│
│                             │
│  EXPENSES                   │
│  {card}┌───────────────────┐│
│  │ 🏠 Rent          [E] [⋮]││
│  │    -₹25,000    {expense}││
│  │    🏦 HDFC Savings      ││
│  │    Monthly (1mo)        ││
│  │    📈 Hike: 8%/yr   [E] ││  Rent escalation
│  │    Status: Active 🟢    ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🏠 Home Loan EMI [E] [⋮]││
│  │    -₹32,456    {expense}││
│  │    🏦 HDFC Savings      ││
│  │    Monthly (1mo)        ││
│  │    End: Jan 2040        ││  Linked to loan tenure
│  │    Status: Active 🟢    ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🏫 School Fee    [E] [⋮]││
│  │    -₹45,000    {expense}││
│  │    🏦 HDFC Savings      ││
│  │    Quarterly (3mo)      ││
│  │    📈 Hike: 12%/yr  [E] ││
│  │    Status: Active 🟢    ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🔒 Insurance Prem[E] [⋮]││
│  │    -₹85,000    {expense}││
│  │    🏦 SBI Savings       ││
│  │    Annual (12mo)        ││
│  │    Payment month: Sep   ││
│  │    Status: Active 🟢    ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🧹 Maid Service  [E] [⋮]││
│  │    -₹3,000     {expense}││
│  │    🏦 Cash              ││
│  │    Biweekly (0.5mo)     ││
│  │    Status: ⏸ Paused 🟡  ││  Paused state
│  │    Paused since: 1 Mar  ││
│  └─────────────────────────┘│
│                             │
│  Monthly Impact         [C] │  headlineMedium
│  {card}┌───────────────────┐│
│  │ Total recurring income  ││
│  │ +₹1,31,667/mo      [C] ││  {income}, prorated to monthly
│  │ Total recurring expense ││
│  │ -₹1,08,456/mo      [C] ││  {expense}, prorated to monthly
│  │ Net recurring flow      ││
│  │ +₹23,211/mo        [C] ││  {income} or {expense}
│  │                         ││
│  │ Budget impact: these    ││  {onSurfaceVariant}
│  │ auto-project into your  ││
│  │ monthly budget actuals  ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘

Long-press context menu:
┌─────────────────────┐
│  ✏️  Edit Rule        │
│  ⏸  Pause Rule       │  (or ▶ Resume if paused)
│  📋  Duplicate Rule   │
│  🗑️  Delete Rule      │
└─────────────────────┘
```

#### Add/Edit Recurring Rule (Bottom Sheet)

```
┌─────────────────────────────┐
│  ─── drag handle ───        │
│                             │
│  New Recurring Rule         │  headlineMedium
│  (or "Edit Recurring Rule") │
│                             │
│  ┌──────┐ ┌──────┐         │
│  │◉Expen│ │○Incom│         │  Segmented: Expense / Income
│  │ se   │ │ e    │         │
│  └──────┘ └──────┘         │
│                             │
│  Name                   [E] │
│  ┌─────────────────────────┐│
│  │  Rent                    ││
│  └─────────────────────────┘│
│                             │
│  Amount                 [E] │
│  ┌─────────────────────────┐│
│  │  ₹ 25,000               ││  Large amount input
│  └─────────────────────────┘│
│                             │
│  Frequency              [E] │
│  ┌─────────────────────────┐│
│  │  Every [  1  ▼] months  ││  Dropdown / input
│  └─────────────────────────┘│
│  Quick select:              │
│  ┌────┐┌────┐┌────┐┌─────┐ │
│  │0.5 ││ 1  ││ 3  ││ 12  │ │  Preset chips
│  │2wk ││ mo ││ qtr││ yr  │ │
│  └────┘└────┘└────┘└─────┘ │
│  ┌────┐┌────┐               │
│  │ 6  ││ 2  │               │  More presets
│  │6mo ││bimo│               │
│  └────┘└────┘               │
│                             │
│  🏦 Account             [E] │
│  ┌─────────────────────────┐│
│  │  🏦 HDFC Savings      > ││
│  └─────────────────────────┘│
│                             │
│  📁 Category            [E] │
│  ┌─────────────────────────┐│
│  │  🏠 Rent              > ││
│  └─────────────────────────┘│
│                             │
│  📅 Start Date          [E] │
│  ┌─────────────────────────┐│
│  │  01 Jan 2026          > ││
│  └─────────────────────────┘│
│                             │
│  📅 End Date (optional) [E] │
│  ┌─────────────────────────┐│
│  │  None (ongoing)       > ││  Can set or leave open
│  └─────────────────────────┘│
│                             │
│  Payment Day            [E] │
│  ┌─────────────────────────┐│
│  │  Day [  1  ▼] of period ││  Which day of month
│  └─────────────────────────┘│
│                             │
│  ── Annual Escalation ────  │  Section header
│                             │
│  📈 Hike Rate           [E] │
│  ┌─────────────────────────┐│
│  │  10  %  per year         ││  0% = no escalation
│  └─────────────────────────┘│
│                             │
│  Hike Month             [E] │
│  ┌─────────────────────────┐│
│  │  April               >  ││  Which month the hike applies
│  └─────────────────────────┘│
│                             │
│  ── Reminder ──────────── │
│                             │
│  🔔 Remind me          [E] │
│  ┌─────────────────────────┐│
│  │  1 day before        >  ││  None / Day of / 1 day / 3 days
│  └─────────────────────────┘│
│                             │
│  CASCADE PREVIEW            │
│  ┌─────────────────────────┐│
│  │ 📊 Budget impact:       ││
│  │    Rent: +₹25,000/mo   ││
│  │ 📈 Projection impact:   ││
│  │    Expense +₹25K/mo     ││
│  │    5yr net worth: -₹15L ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │      Save Rule           ││  {primary} filled
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

`★ Insight: Frequency-as-months is elegant because it maps to a single formula: next_date = start_date + (occurrence_count × frequency_months). For 0.5 months, this becomes biweekly (≈15 days). The payment_day field resolves "which day" ambiguity. Escalation compounds annually: amount × (1 + hike_rate)^years_elapsed.`

---

### 2.17 Scenario Sandbox (Decision Engine)

The most powerful planning screen. Users build hypothetical financial scenarios by stacking "what-if" changes and seeing the combined projection impact. A scenario is a container of changes that can be accepted (turning them into real entities) or discarded.

#### Scenario List
```
┌─────────────────────────────┐
│  ← Scenarios       🟢 + New│
├─────────────────────────────┤
│                             │
│  ACTIVE SCENARIOS           │
│  {card}┌───────────────────┐│
│  │ 🧪 "New Car Purchase"  ││  titleLarge
│  │    Created: 15 Mar [E]  ││
│  │    3 changes stacked    ││  Change count
│  │                         ││
│  │    5yr impact:      [C] ││  Quick summary
│  │    Net worth: -₹8.2L   ││  {expense} — negative impact
│  │    Monthly: -₹12K/mo   ││
│  │                         ││
│  │  ┌──────┐ ┌───────────┐││
│  │  │ Open │ │ ✓ Accept  │││  Two CTAs
│  │  └──────┘ └───────────┘││
│  └─────────────────────────┘│
│                             │
│  {card}┌───────────────────┐│
│  │ 🧪 "Job Switch to MNC" ││
│  │    Created: 10 Mar [E]  ││
│  │    5 changes stacked    ││
│  │                         ││
│  │    5yr impact:      [C] ││
│  │    Net worth: +₹42L    ││  {income} — positive impact
│  │    Monthly: +₹55K/mo   ││
│  │                         ││
│  │  ┌──────┐ ┌───────────┐││
│  │  │ Open │ │ ✓ Accept  │││
│  │  └──────┘ └───────────┘││
│  └─────────────────────────┘│
│                             │
│  PAST DECISIONS             │  labelSmall
│  {card}┌───────────────────┐│
│  │ ✓ "Increase SIP by 5K" ││  Accepted, grayed
│  │    Accepted: 5 Mar      ││
│  │    Now active in your   ││
│  │    recurring rules      ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

#### Scenario Builder (Detail)
```
┌─────────────────────────────┐
│  ← New Car Purchase  🟢 [⋮]│  ⋮: Rename, Duplicate, Delete
├─────────────────────────────┤
│                             │
│  What-If Changes            │  headlineMedium
│  Stack changes to see       │  bodySmall, {onSurfaceVariant}
│  their combined impact      │
│                             │
│  {card}┌───────────────────┐│
│  │ Change 1          [E][⋮]││
│  │ 🏦 New Loan: Car Loan   ││
│  │    Principal: ₹8,00,000 ││
│  │    Rate: 9.5% · 5yr     ││
│  │    EMI: ₹16,788/mo  [C] ││
│  │    🏦 → HDFC Savings    ││  Deducted from this account
│  └─────────────────────────┘│
│                             │
│  {card}┌───────────────────┐│
│  │ Change 2          [E][⋮]││
│  │ 📈 Reduce SIP           ││
│  │    Groww MF SIP          ││
│  │    ₹15,000 → ₹10,000/mo││  Show old → new
│  │    🏦 HDFC Savings      ││
│  └─────────────────────────┘│
│                             │
│  {card}┌───────────────────┐│
│  │ Change 3          [E][⋮]││
│  │ 💰 Insurance: Car Ins   ││
│  │    ₹18,000/yr (12mo)    ││  New recurring expense
│  │    🏦 HDFC Savings      ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │  + Add Change            ││  {primary} outlined
│  └─────────────────────────┘│
│                             │
│  ── Combined Impact ────── │  headlineMedium
│                             │
│  {card}┌───────────────────┐│
│  │ Projection Comparison   ││
│  │ ┌─────────────────────┐ ││
│  │ │ ──── Current (real)  │ ││  {chartLine1} solid
│  │ │ ╌╌╌╌ With scenario   │ ││  {chartLine2} dashed
│  │ │                      │ ││
│  │ │ Current     Scenario │ ││  Side-by-side at 5yr
│  │ │ ₹1.2Cr      ₹1.12Cr │ ││
│  │ │              -₹8.2L  │ ││  {expense} delta
│  │ └─────────────────────┘ ││
│  └─────────────────────────┘│
│                             │
│  {card}┌──────┐┌──────┐    │
│  │ Monthly   ││ 5yr Net│    │
│  │ Impact    ││ Worth  │    │
│  │ -₹12K/mo ││ -₹8.2L │    │  {expense}
│  │ {expense} ││{expense}│    │
│  └──────┘└──────┘           │
│  {card}┌──────┐┌──────┐    │
│  │ New EMI   ││ Total  │    │
│  │ Burden    ││Interest│    │
│  │ ₹16,788  ││ ₹2.07L │    │
│  │ /month   ││ over 5yr│    │
│  └──────┘└──────┘           │
│                             │
│  Monthly Breakdown      [C] │
│  {card}┌───────────────────┐│
│  │Mon│ Current │ Scenario  ││  Comparison table
│  │───┼─────────┼───────────││
│  │Apr│ +₹53K  │ +₹41K     ││  Show delta
│  │May│ +₹57K  │ +₹45K     ││
│  │...│         │            ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │   ✓ Accept This Decision ││  {primary} filled, prominent
│  └─────────────────────────┘│
│  Accepting will:            │  bodySmall, {onSurfaceVariant}
│  • Create "Car Loan" account│
│  • Add EMI recurring rule   │
│  • Update SIP rule amount   │
│  • Add insurance rule       │
│  This CANNOT be undone as   │
│  a batch — changes become   │
│  individual entities.       │
│                             │
│  ┌─────────────────────────┐│
│  │   Discard Scenario       ││  {expense} outlined
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

#### Add Change (Bottom Sheet)
```
┌─────────────────────────────┐
│  ─── drag handle ───        │
│                             │
│  Add What-If Change         │  headlineMedium
│                             │
│  What kind of change?       │
│                             │
│  {card}┌───────────────────┐│
│  │ 🏦 New Loan              ││  Tap → loan params form
│  │    Add a new loan with   ││  (principal, rate, tenure)
│  │    EMI impact            ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 💰 Change Income         ││  Tap → select recurring income
│  │    Modify salary, add    ││  rule → edit amount/hike
│  │    new income source     ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 💸 Change Expense        ││  Tap → select/add recurring
│  │    Add or modify a       ││  expense rule
│  │    recurring expense     ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 📈 Change Investment     ││  Tap → modify SIP, add new
│  │    Modify SIP amount,    ││  investment, change returns
│  │    add new investment    ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🎯 Change Goal           ││  Tap → modify goal target,
│  │    Adjust goal target    ││  date, or linked accounts
│  │    or timeline           ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 💰 Lump Sum Event        ││  One-time cash event
│  │    Bonus, inheritance,   ││  (not recurring)
│  │    large purchase        ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

**Accept flow cascade**:
```
User taps "Accept This Decision"
  │
  ├─→ Confirmation dialog with full entity list
  │    "This will create: 1 account, 2 recurring rules,
  │     modify 1 recurring rule"
  │
  ├─→ For each change in scenario:
  │    ├─→ New Loan → creates account + loan_details + EMI recurring rule
  │    ├─→ Change Income → updates recurring_rule.amount
  │    ├─→ New Expense → creates recurring_rule
  │    └─→ Each fires its own cascade (balance, budget, projections)
  │
  ├─→ Scenario marked as "accepted" (archived, not deleted)
  │
  └─→ All screens refresh with new reality
```

---

### 2.18 Net Worth Milestones

```
┌─────────────────────────────┐
│  ← Milestones       🟢 +Add│
├─────────────────────────────┤
│                             │
│  Current Net Worth      [C] │
│  ₹42,15,678                │  displayMedium, {income}
│                             │
│  {card}┌───────────────────┐│
│  │ 🏅 Next Milestone       ││
│  │                         ││
│  │ ₹50,00,000              ││  displayLarge, {onSurface}
│  │ ₹7,84,322 to go    [C] ││  {onSurfaceVariant}
│  │                         ││
│  │ ████████████████░░░ 84% ││  {income} progress bar
│  │                         ││
│  │ At current pace:    [C] ││
│  │ ~6 months (Sep 2026)    ││  Projected from savings rate
│  │                         ││
│  │ 🔔 Notify when reached  ││  Toggle [E]
│  └─────────────────────────┘│
│                             │
│  ALL MILESTONES             │
│  {card}┌───────────────────┐│
│  │ ✓ ₹10,00,000       [E] ││  Completed, {income}
│  │   Reached: Aug 2024     ││  bodySmall
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ ✓ ₹25,00,000       [E] ││  Completed
│  │   Reached: Mar 2025     ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ ✓ ₹40,00,000       [E] ││  Completed
│  │   Reached: Jan 2026     ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ → ₹50,00,000       [E] ││  Current target, {primary}
│  │   84% · ~Sep 2026   [C] ││  Active, bold
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ ○ ₹1,00,00,000     [E] ││  Future, {onSurfaceVariant}
│  │   42% · ~2028       [C] ││  Projected
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ ○ ₹2,00,00,000     [E] ││  Far future
│  │   21% · ~2031       [C] ││
│  └─────────────────────────┘│
│                             │
│  {card}┌───────────────────┐│
│  │ Net Worth History       ││
│  │ ┌─────────────────────┐ ││
│  │ │     ╱──              │ ││  Chart with milestone lines
│  │ │   ╱── ····₹50L····  │ ││  Dashed horizontal at each
│  │ │ ╱── ────₹40L────    │ ││  milestone target
│  │ │╱  ════₹25L════      │ ││  Completed = solid line
│  │ │  ▬▬▬▬₹10L▬▬▬▬       │ ││
│  │ │ 2024  2025   2026   │ ││
│  │ └─────────────────────┘ ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘

Add/Edit Milestone (Bottom Sheet):
┌─────────────────────────────┐
│  ─── drag handle ───        │
│  New Milestone              │
│                             │
│  Target Net Worth       [E] │
│  ┌─────────────────────────┐│
│  │  ₹ 50,00,000            ││  Large amount input
│  └─────────────────────────┘│
│                             │
│  Label (optional)       [E] │
│  ┌─────────────────────────┐│
│  │  "Financial freedom"     ││
│  └─────────────────────────┘│
│                             │
│  🔔 Notify when reached [E] │
│  ◉ Yes  ○ No               │
│                             │
│  Projected date:        [C] │
│  Sep 2026 (at current pace) │
│                             │
│  ┌─────────────────────────┐│
│  │      Save Milestone      ││
│  └─────────────────────────┘│
└─────────────────────────────┘
```

---

### 2.19 Notifications & Reminders

```
┌─────────────────────────────┐
│  ← Notifications     🟢    │
├─────────────────────────────┤
│                             │
│  Upcoming                   │  headlineMedium
│  {card}┌───────────────────┐│
│  │ 🔴 Tomorrow              ││  Date header, urgency color
│  │ 🏠 Rent — ₹25,000       ││  Recurring rule name
│  │    🏦 HDFC Savings      ││  Account badge
│  │    Recurring · Monthly  ││  Source type
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🟡 23 Mar (3 days)      ││
│  │ 💳 HDFC Credit Card Due ││  Credit card due date
│  │    ₹12,450 outstanding  ││
│  │    🏦 HDFC Savings      ││  Suggested payment account
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🟡 25 Mar (5 days)      ││
│  │ 🏠 Home Loan EMI        ││  Loan EMI
│  │    ₹32,456              ││
│  │    🏦 HDFC Savings      ││
│  └─────────────────────────┘│
│                             │
│  This Week                  │
│  {card}┌───────────────────┐│
│  │ ⚪ 24 Mar               ││  Normal priority
│  │ 📺 Netflix — ₹649       ││
│  │    💳 HDFC Credit       ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ ⚪ 26 Mar               ││
│  │ ⚡ Electricity — ₹3,200 ││
│  │    🏦 HDFC Savings      ││
│  └─────────────────────────┘│
│                             │
│  Later This Month           │
│  {card}┌───────────────────┐│
│  │ ⚪ 1 Apr                ││
│  │ 💰 Salary +₹1,20,000   ││  {income} — expected income
│  │    🏦 HDFC Savings      ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ ⚪ 5 Apr                ││
│  │ 📈 SIP — ₹15,000       ││
│  │    🏦 HDFC → Groww      ││
│  └─────────────────────────┘│
│                             │
│  Milestones                 │  headlineMedium
│  {card}┌───────────────────┐│
│  │ 🏅 ₹50L Net Worth      ││
│  │    84% · ~6 months away ││
│  │    🔔 Notification: On  ││
│  └─────────────────────────┘│
│                             │
├─────────────────────────────┤
│  Reminder Preferences   [→] │
│  {card}┌───────────────────┐│
│  │ Default reminder    [E] ││
│  │   1 day before       >  ││  None/Day of/1 day/3 days/1 week
│  │ Bill reminders      [E] ││
│  │   [●] Enabled           ││
│  │ EMI reminders       [E] ││
│  │   [●] Enabled           ││
│  │ Income alerts       [E] ││
│  │   [●] Enabled           ││  "Expected salary arrived"
│  │ Milestone alerts    [E] ││
│  │   [●] Enabled           ││
│  │ Overspend alerts    [E] ││
│  │   [●] Enabled           ││  Budget overspend warning
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

**Notification sources** (all local — no server push):
| Source | Trigger | Default Timing |
|--------|---------|----------------|
| Recurring expense rule | `next_occurrence - reminder_offset` | 1 day before |
| Recurring income rule | `next_occurrence` | Day of (confirmation) |
| Credit card due date | `account.due_date - reminder_offset` | 3 days before |
| Loan EMI | From recurring rule linked to loan | 1 day before |
| Budget overspend | `actuals > limit` for any category group | Immediate |
| Net worth milestone | `current_net_worth >= milestone.target` | Immediate |
| Goal at risk | `status` changes to `AT_RISK` | Immediate |

---

### 2.20 Budget Screen — Updated with Recurring Projections

The budget screen now has TWO layers of data:
1. **Actuals** — real transactions that have occurred (computed, not editable on budget screen)
2. **Projected** — expected amounts from active recurring rules that haven't fired yet this period

```
┌─────────────────────────────┐
│  ← Budget        🟢 ✏️  ⚙️ │  ✏️ edit limits, ⚙️ projection settings
├─────────────────────────────┤
│  ◀  March 2026          ▶  │
│                             │
│  Total Budget           [C] │
│  ₹1,40,000                 │
│  Spent: ₹72,450 (52%) [C]  │  Actual transactions so far
│  Projected: ₹1,18,450  [C] │  Actual + remaining recurring
│  ████████████▒▒▒▒░░░░      │
│  ████ actual  ▒▒▒▒ projected│  Two-tone bar
│                             │
│  Legend:                    │
│  ████ Spent (actual)        │  {income} solid
│  ▒▒▒▒ Projected (recurring) │  {income} 40% opacity / hatched
│  ░░░░ Remaining             │  {outline}
│                             │
├─────────────────────────────┤
│                             │
│  Essential              [→] │
│  ₹45K actual + ₹20K proj   │
│  of ₹80,000            [E] │  Limit editable
│  ████████████▒▒▒▒░░░  81%  │  Two-tone progress
│                             │
│  {card}┌───────────────────┐│
│  │ 🍕 Food                ││
│  │   Actual: ₹12,500  [C] ││  Real transactions
│  │   Projected: +₹6,000   ││  {onSurfaceVariant}, italic
│  │   (Swiggy, Zomato rules)││  Which rules contribute
│  │   Total: ₹18,500 / ₹20K││
│  │   ████████████▒▒▒░ 93% ││  {warning} — close
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🏠 Rent                ││
│  │   Actual: ₹25,000  [C] ││  Already paid
│  │   Projected: ₹0        ││  Monthly, already fired
│  │   Total: ₹25,000/₹25K  ││
│  │   ██████████████████100%││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ ⚡ Utilities            ││
│  │   Actual: ₹0       [C] ││  Not yet paid
│  │   Projected: +₹4,200   ││  Expected from recurring rule
│  │   (Electricity rule)    ││
│  │   Total: ₹4,200 / ₹8K  ││
│  │   ▒▒▒▒▒▒▒▒▒░░░░░░ 53% ││  All projected (hatched)
│  └─────────────────────────┘│
│                             │
│  Non-Essential          [→] │
│  ₹27K actual + ₹8K proj    │
│  of ₹30,000                │
│  ████████████████▒▒▒░  ⚠   │  {warning} — will likely overshoot
│  Projected overspend: ₹5K  │  {expense}, bodySmall
│                             │
│  Investments            [→] │
│  ₹15K actual + ₹10K proj   │
│  of ₹30,000                │
│  ██████████▒▒▒▒░░░░░  83%  │
│                             │
│  ── Projection Toggle ──── │
│  ┌─────────────────────────┐│
│  │ Show projections [E][●] ││  Toggle projected amounts
│  │ Source: 14 active rules ││  Link to recurring rules
│  │ Paused rules excluded   ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

**Budget projection logic**: For each active (non-paused) recurring expense rule, check if its next occurrence falls within the current budget month. If the transaction hasn't been created yet (no matching idempotent key), add the amount to "projected." Once the recurring rule fires and creates the real transaction, projected decreases and actual increases — the total stays the same.

---

### 2.21 Document Vault (Financial Records Locator)

The vault is NOT a document store — it records **where** important financial documents are physically or digitally located. Think of it as a family's encrypted index card system: "Where did we keep the flat registration papers?"

**Why not store the documents?** Storing PDFs/scans would: (1) balloon the encrypted sync payload on Google Drive, (2) create a high-value encrypted blob that attracts attention, (3) complicate the data model with binary attachments. Recording "SBI locker #412, Koramangala branch" is 50 bytes, fully encrypted, and answers the actual question families ask.

#### Vault Overview

```
┌─────────────────────────────┐
│  ← Document Vault   🟢 +Add│
├─────────────────────────────┤
│                             │
│  🔐 All records encrypted   │  bodySmall, {income} dot
│     on device & in sync     │
│                             │
│  🔍 Search vault...        │  Search bar
│                             │
│  PROPERTY                   │  labelSmall, {onSurfaceVariant}
│  {card}┌───────────────────┐│
│  │ 🏠 Flat Registration    ││
│  │    2BHK, Whitefield     ││  titleMedium [E]
│  │                         ││
│  │    📍 Physical location: ││  bodySmall label
│  │    SBI Locker #412,     ││  [E] — editable
│  │    Koramangala branch   ││
│  │                         ││
│  │    📋 Digital copy:      ││
│  │    Google Drive >       ││  [E] — free text
│  │    Personal > Property  ││
│  │                         ││
│  │    🏦 Linked: SBI Home  ││  Optional link to account
│  │    Loan account         ││
│  │    📅 Date: Mar 2020    ││  [E]
│  │    📝 Notes: Original + ││  [E]
│  │    2 certified copies   ││
│  │                     [⋮] ││  Edit, Delete
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🏗️ Land Papers — Plot   ││
│  │    Site in Devanahalli   ││
│  │                         ││
│  │    📍 Home safe, top    ││
│  │    shelf, brown envelope││
│  │                         ││
│  │    📋 Scanned copy:     ││
│  │    Laptop > Documents > ││
│  │    Property             ││
│  │                         ││
│  │    📅 Date: Jun 2018    ││
│  │    📝 Encumbrance cert  ││
│  │    renewed Dec 2025     ││
│  └─────────────────────────┘│
│                             │
│  BANKING                    │
│  {card}┌───────────────────┐│
│  │ 🏦 HDFC FD Certificates ││
│  │    3 FDs, total ₹5L     ││
│  │                         ││
│  │    📍 HDFC Locker,      ││
│  │    MG Road branch       ││
│  │                         ││
│  │    📋 E-receipts:       ││
│  │    HDFC NetBanking >    ││
│  │    Fixed Deposits       ││
│  │                         ││
│  │    🏦 Linked: HDFC FD   ││
│  │    📅 Maturity: Dec 2026││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🏦 PPF Passbook         ││
│  │    SBI PPF account      ││
│  │                         ││
│  │    📍 Home filing       ││
│  │    cabinet, 2nd drawer  ││
│  │                         ││
│  │    🏦 Linked: SBI PPF   ││
│  └─────────────────────────┘│
│                             │
│  INSURANCE                  │
│  {card}┌───────────────────┐│
│  │ 🛡️ LIC Jeevan Anand    ││
│  │    Policy #28374659     ││  [E]
│  │                         ││
│  │    📍 SBI Locker #412   ││
│  │                         ││
│  │    📋 Digital: LIC      ││
│  │    portal > My Policies ││
│  │                         ││
│  │    🏦 Linked: LIC ULIP  ││
│  │    📅 Maturity: Jan 2035││
│  │    📝 Nominee: Pravallika    ││  Important metadata
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🛡️ HDFC Ergo Car Ins   ││
│  │    Policy #HC-2025-1234 ││
│  │                         ││
│  │    📍 Glove compartment ││  Physical location
│  │    + email inbox        ││
│  │                         ││
│  │    📅 Renewal: Sep 2026 ││
│  │    📝 IDV: ₹4.5L       ││
│  └─────────────────────────┘│
│                             │
│  IDENTITY & GOVT            │
│  {card}┌───────────────────┐│
│  │ 🪪 PAN Cards            ││
│  │    Ajit + Pravallika          ││
│  │                         ││
│  │    📍 Home safe,        ││
│  │    document folder      ││
│  │                         ││
│  │    📋 DigiLocker        ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🪪 Aadhaar Cards        ││
│  │    Family (3 cards)     ││
│  │                         ││
│  │    📍 Wallet (originals)││
│  │    📋 DigiLocker        ││
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 📄 Will / Nominations   ││
│  │    Registered will      ││
│  │                         ││
│  │    📍 SBI Locker #412   ││
│  │    📋 Advocate Sharma,  ││
│  │    has certified copy   ││
│  │                         ││
│  │    📅 Date: Nov 2024    ││
│  │    📝 Review annually   ││
│  └─────────────────────────┘│
│                             │
│  VEHICLES                   │
│  {card}┌───────────────────┐│
│  │ 🚗 Car RC — Honda City  ││
│  │    KA-01-AB-1234        ││
│  │                         ││
│  │    📍 Glove compartment ││
│  │    📋 DigiLocker +      ││
│  │    Parivahan portal     ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

#### Add/Edit Vault Record (Bottom Sheet)

```
┌─────────────────────────────┐
│  ─── drag handle ───        │
│                             │
│  New Record                 │  headlineMedium
│                             │
│  Category               [E] │
│  ┌─────────────────────────┐│
│  │  🏠 Property          > ││  Picker:
│  └─────────────────────────┘│  Property, Banking, Insurance,
│                              │  Identity & Govt, Vehicles,
│                              │  Investments, Legal, Other
│                             │
│  Title                  [E] │
│  ┌─────────────────────────┐│
│  │  Flat Registration       ││
│  └─────────────────────────┘│
│                             │
│  Subtitle / Description [E] │
│  ┌─────────────────────────┐│
│  │  2BHK, Whitefield       ││  Optional context
│  └─────────────────────────┘│
│                             │
│  Reference Number (opt) [E] │
│  ┌─────────────────────────┐│
│  │  REG/2020/BLR/28374     ││  Policy #, account #, etc.
│  └─────────────────────────┘│
│                             │
│  ── Physical Location ────  │  Section
│                             │
│  📍 Where is it?        [E] │
│  ┌─────────────────────────┐│
│  │  SBI Locker #412,       ││  Free text, multiline
│  │  Koramangala branch     ││
│  └─────────────────────────┘│
│                             │
│  ── Digital Copy ─────────  │  Section
│                             │
│  📋 Where is the copy?  [E] │
│  ┌─────────────────────────┐│
│  │  Google Drive >          ││  Free text, multiline
│  │  Personal > Property    ││
│  └─────────────────────────┘│
│                             │
│  ── Linked Account (opt) ─  │
│                             │
│  🏦 Account             [E] │
│  ┌─────────────────────────┐│
│  │  🏠 SBI Home Loan    >  ││  Account picker (optional)
│  └─────────────────────────┘│
│                             │
│  ── Dates & Metadata ─────  │
│                             │
│  📅 Document Date       [E] │
│  ┌─────────────────────────┐│
│  │  Mar 2020             >  ││
│  └─────────────────────────┘│
│                             │
│  📅 Expiry / Renewal    [E] │
│  ┌─────────────────────────┐│
│  │  None                 >  ││  For insurance, FDs, etc.
│  └─────────────────────────┘│
│                             │
│  🔔 Remind before expiry[E] │
│  ┌─────────────────────────┐│
│  │  1 month before       >  ││  None / 1wk / 1mo / 3mo
│  └─────────────────────────┘│
│                             │
│  📝 Notes               [E] │
│  ┌─────────────────────────┐│
│  │  Original + 2 certified ││  Multiline free text
│  │  copies. Nominee: Pravallika ││  For anything that doesn't
│  │                         ││  fit structured fields
│  └─────────────────────────┘│
│                             │
│  👁 Visibility           [E] │
│  ◉ Shared with family       │
│  ○ Private to me            │
│                             │
│  ┌─────────────────────────┐│
│  │      Save Record         ││  {primary} filled
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

#### Vault Categories

| Category | Icon | Typical Records |
|----------|------|-----------------|
| Property | 🏠 | Flat registration, land papers, sale deed, encumbrance cert, property tax receipts |
| Banking | 🏦 | FD certificates, locker agreements, passbooks, cheque books |
| Insurance | 🛡️ | Life, health, vehicle, home policies, claim documents |
| Identity & Govt | 🪪 | PAN, Aadhaar, passport, voter ID, driving license |
| Investments | 📈 | Demat statements, MF folios, PPF passbook, NPS PRAN |
| Vehicles | 🚗 | RC, insurance, PUC, service records |
| Legal | ⚖️ | Will, power of attorney, trust deeds, contracts |
| Other | 📁 | Education certificates, medical records, warranties |

#### Vault-specific features

- **Search**: Full-text search across title, subtitle, location, notes. Instant results.
- **Expiry reminders**: Records with expiry dates (insurance, FDs) integrate with the Notification system.
- **Account linking**: Linking a vault record to an account creates a bidirectional reference — the account detail screen shows "📄 Related documents: Flat Registration, Home Loan Agreement."
- **Family visibility**: Each record can be private or shared. A will might be shared; a personal ID might be private.
- **No file storage**: The vault NEVER stores files, images, or attachments. It stores text metadata only. This keeps the encrypted sync payload tiny and avoids binary blob management.

---

### 2.22 Money Flow — Self-Transfers, EMI Chains, Salary Routing

This section defines how multi-leg money movements work. The core principle: **every leg is a separate, visible transaction** — no hidden mutations. The user sees exactly what happened to each account.

#### Transaction Kinds and Balance Rules

| Kind | From Account | To Account | Balance Effect | Budget Effect | Loan Effect |
|------|-------------|-----------|----------------|---------------|-------------|
| `INCOME` / `SALARY` / `DIVIDEND` | receives money | — | +amount to `fromAccount` | Not counted (income, not expense) | — |
| `EXPENSE` | pays money | — | -amount from `fromAccount` | +amount to category group actuals | — |
| `TRANSFER` | sends money | receives money | -amount from `fromAccount`, +amount to `toAccount` | NOT counted (net-worth-neutral) | — |
| `EMI_PAYMENT` | pays money | loan account | -amount from `fromAccount`, reduces loan outstanding by principal portion | +amount to Essential (EMI category) | Outstanding -= principal. Interest = expense. Amortization schedule advances. |
| `INSURANCE_PREMIUM` | pays money | — | -amount from `fromAccount` | +amount to Essential | — |

**Critical distinction**: `TRANSFER` is net-worth-neutral and budget-invisible. `EMI_PAYMENT` is net-worth-neutral (liability reduces as cash reduces) but budget-visible (it's a real expense commitment).

#### Salary Flow Example (3 Transactions)

This is the most common Indian household money flow:

```
SALARY DAY (1st of month)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Transaction 1: SALARY (Income)
┌─────────────────────────────────────────────┐
│  💰 March Salary                            │
│  Kind: SALARY                               │
│  Amount: +₹1,20,000                         │
│  Account: 🏦 HDFC Salary Account            │
│  Category: Income                           │
│                                             │
│  Effect:                                    │
│  🏦 HDFC Salary: ₹15,000 → ₹1,35,000      │
│  Net worth: +₹1,20,000                     │
│  Budget: no effect (income)                 │
└─────────────────────────────────────────────┘
          │
          ▼
Transaction 2: TRANSFER (Self-transfer)
┌─────────────────────────────────────────────┐
│  ↔ Transfer to Savings                      │
│  Kind: TRANSFER                             │
│  Amount: ₹1,00,000                          │
│  From: 🏦 HDFC Salary Account               │
│  To:   🏦 HDFC Savings Account              │
│                                             │
│  Effect:                                    │
│  🏦 HDFC Salary:  ₹1,35,000 → ₹35,000     │
│  🏦 HDFC Savings: ₹2,90,000 → ₹3,90,000   │
│  Net worth: ₹0 change (self-transfer)       │
│  Budget: no effect (transfer)               │
└─────────────────────────────────────────────┘
          │
          ▼
Transaction 3: EMI_PAYMENT (Loan payment)
┌─────────────────────────────────────────────┐
│  🏠 Home Loan EMI — March                   │
│  Kind: EMI_PAYMENT                          │
│  Amount: ₹32,456                            │
│  From: 🏦 HDFC Savings Account              │
│  Loan: 🏠 SBI Home Loan                     │
│                                             │
│  Principal/Interest split (from amort):     │
│  Principal: ₹9,512  (reduces outstanding)   │
│  Interest:  ₹22,944 (expense)               │
│                                             │
│  Effect:                                    │
│  🏦 HDFC Savings: ₹3,90,000 → ₹3,57,544   │
│  🏠 Loan outstanding: ₹28,12,340→₹28,02,828│
│  Net worth: ₹0 change                       │
│    (cash -₹32,456 BUT liability -₹9,512     │
│     so net impact = -₹22,944 interest)       │
│  Budget: +₹32,456 to Essential/EMI          │
│  Amortization: row marked as paid           │
└─────────────────────────────────────────────┘
```

**Net effect of all 3 transactions**:
```
Account Balances:
  🏦 Salary:   +₹1,20,000 then -₹1,00,000         = +₹20,000
  🏦 Savings:  +₹1,00,000 then -₹32,456            = +₹67,544
  🏠 Loan:     outstanding -₹9,512 (principal only)

Net Worth:
  +₹1,20,000 (salary) -₹22,944 (interest expense) = +₹97,056

Budget:
  Income: +₹1,20,000
  EMI expense: +₹32,456
```

#### Automating the Flow with Recurring Rules

Each leg can be a separate recurring rule:

```
┌─────────────────────────────────────────────┐
│  RECURRING RULES — SALARY FLOW              │
│                                             │
│  Rule 1: Salary Credit                      │
│  Type: INCOME | Amount: ₹1,20,000          │
│  Frequency: Monthly (1mo) | Day: 1st       │
│  Account: 🏦 HDFC Salary                    │
│  Hike: 10%/yr in April                     │
│                                             │
│  Rule 2: Transfer to Savings                │
│  Type: TRANSFER | Amount: ₹1,00,000        │
│  Frequency: Monthly (1mo) | Day: 2nd       │
│  From: 🏦 HDFC Salary                       │
│  To:   🏦 HDFC Savings                      │
│  Hike: 10%/yr (matches salary hike)        │
│                                             │
│  Rule 3: Home Loan EMI                      │
│  Type: EMI_PAYMENT | Amount: ₹32,456       │
│  Frequency: Monthly (1mo) | Day: 5th       │
│  From: 🏦 HDFC Savings                      │
│  Loan: 🏠 SBI Home Loan                     │
│  End:  Jan 2040 (loan tenure)               │
│  Hike: None (EMI is fixed)                  │
└─────────────────────────────────────────────┘
```

Each rule fires independently on its scheduled day, creating the corresponding transaction and triggering its cascade. The budget screen shows all three as projected if they haven't fired yet this month.

#### EMI Payment — Detailed Flow

When an EMI_PAYMENT transaction is created (manually or from recurring rule):

```
EMI_PAYMENT created (₹32,456, from Savings → Home Loan)
  │
  ├─→ Look up loan_details for the loan account
  │
  ├─→ Fetch current amortization schedule row for this month
  │     └─→ Get principal/interest split:
  │           principal = ₹9,512
  │           interest  = ₹22,944
  │
  ├─→ Update source account balance
  │     └─→ 🏦 Savings: -₹32,456
  │
  ├─→ Update loan outstanding
  │     └─→ 🏠 Loan: outstanding -= ₹9,512 (principal only)
  │     └─→ Mark this amortization row as "paid"
  │
  ├─→ Regenerate remaining amortization schedule
  │     (outstanding has changed → future splits recalculate)
  │
  ├─→ Budget cascade
  │     └─→ EMI counts as expense under Essential/EMI category
  │     └─→ Budget actuals += ₹32,456
  │
  ├─→ Dashboard cascade
  │     └─→ Net worth: recalculate (cash down, liability down)
  │     └─→ Monthly expense summary: +₹32,456
  │
  └─→ Loan Detail screen
        └─→ Outstanding balance updates
        └─→ Amortization table: current row shows "✓ Paid"
        └─→ Remaining tenure recalculates
        └─→ Remaining interest recalculates
```

#### Updated Loan Detail — EMI Payment History

The Loan Detail screen (2.9) gains an EMI payment history section:

```
  (... existing loan detail content above ...)

│  EMI Payment History        │  headlineMedium
│  {card}┌───────────────────┐│
│  │ Month │Status│Princ│ Int ││
│  │━━━━━━━┿━━━━━━┿━━━━━┿━━━━││
│  │Mar'26 │✓ Paid│9,512│22.9K││  {income} ✓
│  │  from 🏦 HDFC Savings   ││  Source account shown
│  │Feb'26 │✓ Paid│9,445│23.0K││
│  │  from 🏦 HDFC Savings   ││
│  │Jan'26 │✓ Paid│9,379│23.1K││
│  │  from 🏦 HDFC Savings   ││
│  │ ...   │      │     │     ││
│  │───────┼──────┼─────┼─────││
│  │Apr'26 │ Due  │9,579│22.9K││  {warning} — upcoming
│  │  🔔 Reminder: 4 Apr      ││  From recurring rule
│  │May'26 │ Due  │9,647│22.8K││  Future rows
│  └─────────────────────────┘│
│                             │
│  EMI Payment Stats      [C] │
│  {card}┌──────┐┌──────┐    │
│  │ Total    ││ Total  │    │
│  │ Principal││Interest│    │
│  │ Paid     ││ Paid   │    │
│  │ ₹16.88L  ││₹22.12L │    │  Lifetime stats
│  │ {income} ││{expense}│    │
│  └──────┘└──────┘           │
│  {card}┌──────┐┌──────┐    │
│  │Prepaid   ││Interest│    │
│  │Principal ││ Saved  │    │
│  │ ₹2.00L   ││ ₹1.84L │    │  From prepayments
│  │ {income} ││{income} │    │
│  └──────┘└──────┘           │
│                             │
│  ┌─────────────────────────┐│
│  │  🏦 Pay EMI Now          ││  {primary} — creates EMI_PAYMENT
│  └─────────────────────────┘│  Opens pre-filled transaction sheet
│  Next due: 5 Apr 2026      │  bodySmall
```

#### Self-Transfer Visibility in Transaction List

Self-transfers show BOTH accounts and are color-neutral:

```
│  19 March 2026              │
│  {card}┌───────────────────┐│
│  │ ↔ Transfer          [E] ││  {neutral} — gray, no judgment
│  │    🏦 HDFC Salary        ││  FROM account
│  │    → 🏦 HDFC Savings     ││  TO account (arrow prefix)
│  │             ₹1,00,000   ││  {neutral} — no +/-, just amount
│  │    Self-transfer         ││  bodySmall, {onSurfaceVariant}
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🏠 Home Loan EMI    [E] ││  EMI has its own icon
│  │    🏦 HDFC Savings       ││  FROM account
│  │    → 🏠 SBI Home Loan   ││  TO loan account
│  │             -₹32,456    ││  {expense} — EMI is a real cost
│  │    Princ: ₹9,512        ││  bodySmall, breakdown shown
│  │    Int:   ₹22,944       ││  bodySmall
│  └─────────────────────────┘│
```

#### Account Detail — Transfer Trail

In the Account Detail screen, transfers show the counterpart account:

```
│  🏦 HDFC Savings Account    │
│                             │
│  Today                      │
│  {card}┌───────────────────┐│
│  │ ↔ From Salary Acct  [E] ││  Incoming transfer
│  │    ← 🏦 HDFC Salary     ││  "←" = received from
│  │            +₹1,00,000   ││  {income} — positive for this acct
│  ├─ ━━━━━━━━━━━━━━━━━━━━━ ─┤│
│  │ 🏠 EMI — Home Loan  [E] ││
│  │    → 🏠 SBI Home Loan   ││  "→" = sent to
│  │             -₹32,456    ││  {expense} — outgoing
│  │    Princ ₹9.5K + Int ₹23K│  Split shown inline
│  └─────────────────────────┘│
```

---

## 3. Navigation Architecture

### Bottom Navigation (Phone)
| # | Icon | Label | Screen | Badge |
|---|------|-------|--------|-------|
| 1 | `LayoutDashboard` | Home | Dashboard | 🔴 count if notifications pending |
| 2 | `Wallet` | Accounts | Account list | — |
| 3 | `Plus` (elevated FAB) | — | Add Transaction (sheet) | — |
| 4 | `PieChart` | Budget | Budget overview | ⚠ if overspend or projected overspend |
| 5 | `Menu` | More | Drawer with full navigation | — |

#### "More" Drawer (Phone)
| Icon | Label | Screen | Badge |
|------|-------|--------|-------|
| `ArrowUpDown` | Transactions | Transaction list | — |
| `Repeat` | Recurring | Recurring rules | count of paused |
| `Target` | Goals | Goal list | — |
| `Building` | Loans | Loan list | — |
| `TrendingUp` | Investments | Portfolio view | — |
| `LineChart` | Projections | Projection view | — |
| `FlaskConical` | Scenarios | Decision engine | count of active |
| `Trophy` | Milestones | Net worth milestones | — |
| `Bell` | Notifications | Reminders & alerts | 🔴 count |
| `Archive` | Vault | Document locator | — |
| `Users` | Family | Family management | — |
| `Settings` | Settings | App settings | — |

### Side Navigation (Tablet/Desktop)
| Icon | Label | Screen |
|------|-------|--------|
| `LayoutDashboard` | Dashboard | Dashboard |
| `Wallet` | Accounts | Account list + detail |
| `ArrowUpDown` | Transactions | Transaction list |
| `Repeat` | Recurring | Recurring rules list |
| `PieChart` | Budget | Budget overview (with projections) |
| `Target` | Goals | Goal list |
| `Building` | Loans | Loan list |
| `TrendingUp` | Investments | Portfolio view (bucket-based) |
| `LineChart` | Projections | Projection view |
| `FlaskConical` | Scenarios | Decision engine |
| `Trophy` | Milestones | Net worth milestones |
| `Bell` | Notifications | Reminders & alerts |
| `Archive` | Vault | Document locator |
| `Users` | Family | Family management |
| `Settings` | Settings | App settings |

---

## 4. Cascade Flow Diagrams

### Transaction Edit Cascade
```
User edits transaction amount (₹456 → ₹500)
  │
  ├─→ drift DAO: UPDATE transactions SET amount = 50000
  │
  ├─→ AccountBalanceService.recompute(accountId)
  │     └─→ SUM(all transactions for account) → new balance
  │           └─→ Riverpod: accountProvider(id) notifies
  │                 ├─→ Account Detail screen: balance updates
  │                 ├─→ Account List screen: balance updates
  │                 └─→ Dashboard: net worth recomputes
  │
  ├─→ BudgetSummaryService.recompute(familyId, year, month)
  │     └─→ SUM(expenses by categoryGroup) → new actuals
  │           └─→ Riverpod: budgetProvider(month) notifies
  │                 ├─→ Budget screen: progress bars update
  │                 └─→ Dashboard: budget section updates
  │
  └─→ BalanceSnapshot.record(accountId, newBalance)
        └─→ Chart data updates on next view
```

### Account Delete Cascade
```
User deletes account (with confirmation dialog)
  │
  ├─→ CONFIRM: "This account has 47 transactions.
  │    Deleting will remove them from all views.
  │    Net worth will change by -₹3,24,567."
  │
  ├─→ drift DAO: UPDATE accounts SET deleted_at = now()
  │     (soft delete — transactions remain but hidden)
  │
  ├─→ All providers watching accounts list → notify
  │     ├─→ Dashboard: account disappears, net worth recomputes
  │     ├─→ Transaction list: filtered to exclude deleted account
  │     ├─→ Budget: actuals recompute (exclude deleted account txns)
  │     └─→ Goals: if linked, show warning "linked account deleted"
  │
  └─→ Sync engine: push DELETE changeset to Drive
```

### Goal-Account Link Cascade
```
User links account to goal
  │
  ├─→ goal.linkedAccounts += accountId
  │
  ├─→ GoalTrackingService.recompute(goalId)
  │     └─→ currentSavings = SUM(linked account balances)
  │     └─→ requiredSIP = recalculate
  │     └─→ status = ON_TRACK / AT_RISK
  │           └─→ Riverpod: goalProvider(id) notifies
  │                 ├─→ Goal detail: progress updates
  │                 └─→ Dashboard: goal card updates
  │
  └─→ Future account balance changes automatically
      flow into goal progress (no extra wiring needed)
```

### Recurring Rule Edit Cascade
```
User edits recurring rule (e.g., Rent ₹25K → ₹28K, or pauses a rule)
  │
  ├─→ drift DAO: UPDATE recurring_rules SET amount/isPaused/frequency
  │
  ├─→ BudgetProjectionService.recompute(familyId, year, month)
  │     └─→ For each active (non-paused) recurring expense rule:
  │           if next_occurrence in budget_month AND no matching txn:
  │             projected_amount += rule.amount (with escalation)
  │     └─→ Riverpod: budgetProvider(month) notifies
  │           ├─→ Budget screen: projected bars update
  │           └─→ Dashboard: budget section updates
  │
  ├─→ ProjectionEngine.recompute()
  │     └─→ 60-month recalculation with updated recurring inputs
  │           └─→ Projections screen refreshes
  │           └─→ Any active scenario comparisons refresh
  │
  ├─→ NotificationService.reschedule(ruleId)
  │     └─→ Cancel old local notifications
  │     └─→ Schedule new ones based on updated frequency/amount
  │
  └─→ Sync engine: push UPDATE changeset
```

### Scenario Accept Cascade
```
User accepts scenario "New Car Purchase" (3 changes)
  │
  ├─→ CONFIRM dialog: lists all entities to be created/modified
  │
  ├─→ For Change 1 (New Loan):
  │    ├─→ Create account (type: LOAN, name: "Car Loan")
  │    ├─→ Create loan_details (principal, rate, tenure)
  │    ├─→ Create recurring_rule (EMI, monthly, from account)
  │    └─→ Each triggers its own cascade (balance, budget, projections)
  │
  ├─→ For Change 2 (Reduce SIP):
  │    ├─→ Update recurring_rule.amount (₹15K → ₹10K)
  │    └─→ Triggers budget + projection cascade
  │
  ├─→ For Change 3 (Car Insurance):
  │    ├─→ Create recurring_rule (annual, ₹18K)
  │    └─→ Triggers budget + projection cascade
  │
  ├─→ Scenario archived (status: ACCEPTED, acceptedAt: now)
  │
  └─→ ALL providers refresh — every screen reflects new reality
```

### Net Worth Milestone Cascade
```
Balance change triggers net worth recompute
  │
  ├─→ NetWorthService.currentNetWorth() returns new value
  │
  ├─→ MilestoneService.checkMilestones(newNetWorth)
  │     └─→ For each incomplete milestone:
  │           if newNetWorth >= milestone.target:
  │             ├─→ milestone.reachedAt = now
  │             ├─→ Fire local notification (if enabled)
  │             └─→ Dashboard: milestone celebration card
  │
  └─→ MilestoneService.updateProjections()
        └─→ Recompute ETA for remaining milestones
              based on rolling 3-month savings rate
```

---

## 5. Theme Implementation Strategy

```dart
// lib/shared/theme/vael_theme.dart
//
// Single source of truth for both themes.
// Every widget uses Theme.of(context) or context.colors extension.
// NEVER hardcode a color hex in a widget file.

class VaelTheme {
  static ThemeData light() => ThemeData(
    colorScheme: _lightColorScheme,
    extensions: [VaelSemanticColors.light()],
    // ... typography, card theme, etc.
  );

  static ThemeData dark() => ThemeData(
    colorScheme: _darkColorScheme,
    extensions: [VaelSemanticColors.dark()],
  );
}

// Semantic extension for finance-specific colors
class VaelSemanticColors extends ThemeExtension<VaelSemanticColors> {
  final Color income;
  final Color incomeContainer;
  final Color expense;
  final Color expenseContainer;
  final Color warning;
  final Color warningContainer;
  final Color neutral;
  // ... constructors for light() and dark()
}

// Usage in any widget:
// final colors = Theme.of(context).extension<VaelSemanticColors>()!;
// Text('₹42,15,678', style: TextStyle(color: colors.income));
```

---

## 6. Accessibility (Both Themes)

| Requirement | Light Mode | Dark Mode |
|-------------|-----------|-----------|
| Text contrast (WCAG AA) | `onSurface` (#1A1A1A) on `surface` (#FAFAF9) = 17.4:1 ✓ | `onSurface` (#E8E6E3) on `surface` (#0F0F0F) = 15.8:1 ✓ |
| Income text | `income` (#2D7A2D) on `surface` = 5.2:1 ✓ | `income` (#6ECF6E) on `surface` = 8.1:1 ✓ |
| Expense text | `expense` (#B3261E) on `surface` = 5.0:1 ✓ | `expense` (#F2B8B5) on `surface` = 11.2:1 ✓ |
| Warning text | `warning` (#8B6914) on `surface` = 4.6:1 ✓ | `warning` (#D4A843) on `surface` = 8.5:1 ✓ |
| Touch targets | 48x48dp minimum everywhere | Same |
| Screen reader amounts | "Three lakh twenty-four thousand" | Same |
| Color-only indicators | Always paired with icon + text | Same |
| Focus indicators | 2dp {primary} outline | Same |

---

## 7. Design Principles Summary

| Principle | Implementation |
|-----------|---------------|
| **Account-centric** | Every number traces to an account. Account badges appear on every amount. |
| **Edit at source** | Editable data is changed where it originates. Computed values link back to source. |
| **Cascade-transparent** | Before saving, show what other screens will change. After saving, animate updates. |
| **Theme-paired** | Every color exists as a light/dark pair. No hardcoded hex in widgets. |
| **Consistent** | Same patterns (bottom sheet edit, swipe delete, cascade preview) on every screen. |
| **Calm** | Warm surfaces, no shadows, muted borders. Premium = restraint. |
| **Private** | Encryption status always visible. Lock screen is first-class. |
| **Indian** | ₹ symbol, lakh/crore, HDFC/SBI/ICICI first-class support. |
| **Bucket-over-unit** | Investments tracked by purpose/type, not individual holdings. Simpler input, better decisions. |
| **Scenario-first planning** | Financial decisions are modeled before committed. The sandbox protects against impulsive changes. |
| **Recurring-aware budget** | Budgets show actual + projected (from recurring rules). Users see where the month is heading, not just where it's been. |
| **Long-horizon visibility** | Investment projections run to 50 years. Compound growth makes the case for early, consistent investing. |
| **Notification-light** | All notifications are local. No server, no push infra. User controls every notification category independently. |

---

## 8. Screen Inventory (Complete)

| # | Screen | Section | New in v3 |
|---|--------|---------|-----------|
| 1 | Lock Screen | 2.1 | — |
| 2 | Dashboard | 2.2 | Updated: milestone card, upcoming recurring |
| 3 | Accounts | 2.3 | — |
| 4 | Account Detail | 2.4 | — |
| 5 | Transaction List | 2.5 | — |
| 6 | Add/Edit Transaction | 2.6 | — |
| 7 | Budget | 2.7 + 2.20 | Updated: recurring projections (two-tone bars) |
| 8 | Goals | 2.8 | — |
| 9 | Loan Detail | 2.9 | — |
| 10 | Investment Portfolio | 2.10 | **Redesigned**: bucket-based, 50yr projections |
| 11 | Projections | 2.11 | — |
| 12 | Statement Import | 2.12 | — |
| 13 | Family Management | 2.13 | — |
| 14 | Settings | 2.14 | — |
| 15 | Onboarding | 2.15 | — |
| 16 | Recurring Rules | 2.16 | **New**: month-float frequency, hikes, pause/resume |
| 17 | Scenario Sandbox | 2.17 | **New**: what-if decision engine |
| 18 | Net Worth Milestones | 2.18 | **New**: milestone tracking with projections |
| 19 | Notifications | 2.19 | **New**: bill reminders, due dates, alerts |
| 20 | Budget (with projections) | 2.20 | **New**: two-tone actual+projected bars |
| 21 | Document Vault | 2.21 | **New**: financial records locator (location, not files) |
| 22 | Money Flow (Self-Transfer, EMI, Salary) | 2.22 | **New**: multi-leg flows, EMI principal/interest split, transfer trail |
