# Intent & Purpose Statement

This document governs every design decision, feature inclusion, and architectural tradeoff in Vael. When in doubt, return here.

## Purpose

> **Vael exists to give families complete ownership of their financial life — a single, private, transparent view across every member, account, and goal — without surrendering data to servers, subscriptions, or third parties.**

## Intent

Vael is built on five governing principles. When any two conflict, the one listed first wins.

### 1. Privacy is non-negotiable, convenience is earned

Data never leaves the device unencrypted. No telemetry, no analytics, no server-side processing. Convenience features (biometric unlock, cloud sync) are opt-in and must preserve the encryption boundary.

**Big tech is storage, never audience.** Vael uses Google Drive as an encrypted storage transport — nothing more. Google (or any cloud provider) must never be able to read, infer, or profile family financial data. Every byte written to Drive — changesets, snapshots, backups, metadata — must be encrypted client-side with the Family Encryption Key (FEK) before leaving the device. File names, folder structures, and sync metadata on Drive must not leak financial semantics (no file names like `budget_march.json` or `salary_transactions.csv`). If a cloud provider were to scan, index, or hand over the entire Drive folder, the result must be indistinguishable from random noise.

### 2. The family is the unit, but individuals have boundaries

Vael models finances at the family level — shared budgets, combined net worth, collective goals. But every member controls what they share. Selective visibility is a first-class concept, not an afterthought.

### 3. Deterministic over intelligent

Financial calculations use math and rules, not models. No AI/ML features — on-device or cloud. Users make their own judgments from clear, accurate numbers. Projections are formula-driven (PMT, FV, amortization), not predicted.

### 4. India-native, globally coherent

Built for Indian banking formats (HDFC, SBI, ICICI), loan structures (EMI, flat-rate), and tax planning patterns. But the architecture doesn't hardcode geography — it's extensible to other regions without rewrites.

### 5. Self-contained and zero-cost to operate

No backend servers. No subscriptions. No recurring fees. Google Drive is a sync transport, not a dependency — the app works fully offline. The user's cost is zero beyond the device they already own.

## Anti-Vision — What Vael Will Never Become

- **Not a social app.** No sharing outside the family. No leaderboards, comparisons, or community features.
- **Not a bank connector.** No Plaid/Yodlee/account-aggregator integrations. Data enters via manual entry or statement import (CSV/PDF). This is a feature, not a limitation — it keeps the trust boundary at the device.
- **Not a subscription product.** No freemium tiers, no premium unlocks, no server costs passed to users.
- **Not an AI assistant.** No chatbots, spending predictions, or "smart" categorization. The user is the intelligence; Vael is the instrument.

## Decision Framework

When facing a design or implementation choice, apply this test:

| Question | If YES | If NO |
|---|---|---|
| Does data leave the device unencrypted? | **Block.** Redesign. | Proceed. |
| Can a cloud provider read, infer, or profile data from what's stored? | **Block.** Encrypt content AND sanitize file/folder names. | Proceed. |
| Does it require a server we operate? | **Block.** Find a local-first alternative. | Proceed. |
| Does it force visibility a family member didn't opt into? | **Block.** Add visibility controls. | Proceed. |
| Does it add a recurring cost for the user? | **Block.** Find a zero-cost path. | Proceed. |
| Does it introduce ML/AI inference? | **Block.** Use deterministic logic. | Proceed. |
| Does it connect directly to a bank API? | **Block.** Use file-based import. | Proceed. |

## Success Criteria

Vael succeeds when:

- A family can see their complete financial picture in under 10 seconds after opening the app.
- A new family member can join and sync without any technical knowledge beyond entering a shared passphrase.
- The app works identically with airplane mode on.
- No one outside the family — including the developer — can read the family's financial data.
- The app can be maintained and run indefinitely at zero marginal cost.
