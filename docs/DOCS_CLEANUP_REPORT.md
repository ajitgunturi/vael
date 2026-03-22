# Docs Cleanup Report — Duplicate & Overlap Audit

> Generated 2026-03-22. Audited 22 documentation files (3,059 total lines).
> Estimated duplication: 20-30%. Goal: a repo a new developer can understand in one sitting.

---

## The Problem

A new developer opening this repo sees 13 docs + 7 root markdown files. Many repeat the same principles, setup steps, or architectural decisions. The result: "where do I start?" paralysis.

**Target state**: A developer reads 4 files in order and is ready to contribute. Everything else is reference material they reach for when needed — not upfront reading.

---

## Duplicates Found

### 1. CLAUDE.md ↔ INTENT.md (EXACT DUPLICATE)

CLAUDE.md (88 lines) restates INTENT.md's governing principles, tech stack, TDD mandate, horizontal integration rules, and boundary rules nearly verbatim. CLAUDE.md exists only because the AI tooling loads it into context — it is NOT a separate document with independent value.

**Action**: Delete `CLAUDE.md`. The system prompt already loads INTENT.md content. Keeping both means every principle change must be made in two places (and they will drift).

### 2. ROADMAP.md ↔ PLAN.md (STRUCTURAL DUPLICATE)

Both files define the same 5-phase breakdown with the same phase names. ROADMAP.md (111 lines) is a summary; PLAN.md (684 lines) is the detailed TDD implementation plan with commit references, test counts, dependency graphs, and E2E test specs.

ROADMAP.md adds nothing that PLAN.md doesn't cover more thoroughly.

**Action**: Delete `docs/ROADMAP.md`. Rename `PLAN.md` → `ROADMAP.md` (root level) so there is one source of truth for "what gets built when."

### 3. Encryption concepts repeated in 3 files

| File | Lines on key hierarchy / FEK / PBKDF2 |
|------|--------------------------------------|
| ENCRYPTION.md | Full spec (94 lines total) |
| SYNC.md §"What's Encrypted" | ~15 lines restating FEK usage |
| PHASE_3_5_FAMILY_BACKUP_ACCESS.md §"Key Hierarchy" | ~57 lines restating + extending with per-member wrapping |

**Action**: SYNC.md should say "See ENCRYPTION.md for key hierarchy" (one line, not 15). PHASE_3_5 should say "Extends the key model from ENCRYPTION.md" and only describe the per-member delta.

### 4. TDD / Principles repeated in 4 files

| File | Lines on TDD, principles, or contribution rules |
|------|------------------------------------------------|
| CLAUDE.md | ~40 lines (TDD mandate, boundary rules) |
| CONTRIBUTING.md | ~60 lines (TDD, horizontal integration, commit rules) |
| INTENT.md | ~30 lines (governing principles, decision framework) |
| README.md | ~10 lines (mentions TDD and principles) |

**Action**: INTENT.md is the authority. CONTRIBUTING.md should link to it ("Development governed by docs/INTENT.md"). README.md should point to it. CLAUDE.md gets deleted (see #1).

### 5. Security guidelines in 3 files

| File | Security content |
|------|-----------------|
| SECURITY.md | Full vulnerability reporting + security-critical file list (71 lines) |
| CONTRIBUTING.md §"Security-Sensitive Changes" | Repeats the security-critical file list |
| .github/PULL_REQUEST_TEMPLATE.md | Mentions "see SECURITY.md" |

**Action**: CONTRIBUTING.md §Security should be 2 lines: "For changes touching crypto, sync, or auth, see SECURITY.md for review requirements."

### 6. Setup instructions fragmented across 4 files

| File | What it covers |
|------|---------------|
| RUNNING.md (239 lines, truncated) | Dev environment, Flutter setup, emulators |
| GOOGLE_CLOUD_SETUP.md (345 lines) | OAuth, Cloud Console, client IDs |
| DEVELOPER_ACCOUNT_SETUP.md (279 lines) | App Store / Play Store accounts |
| CONTRIBUTING.md §"Setup" | Partial setup steps |

A developer must read 4 documents and mentally merge them to get running.

**Action**: RUNNING.md becomes the single "Getting Started" guide. It should contain or link to the others in sequence. Rename DEVELOPER_ACCOUNT_SETUP.md → STORE_DISTRIBUTION.md (it's about publishing, not coding setup).

---

## Files That Serve No Current Purpose

### 7. BUSINESS_LOGIC.md — Legacy porting guide

202 lines describing Java-to-Dart porting decisions from the legacy family-finances app. This was useful during Phase 1-2; that work is complete (commit b933378). The actual business logic now lives in `lib/core/financial/`.

**Action**: Move to `docs/archived/BUSINESS_LOGIC_PORTING.md`.

### 8. lib/features/family/README_MIGRATION.md — Archival note

10 lines explaining that the family/ directory was consolidated into settings/. This was a one-time refactoring note.

**Action**: Delete. The refactoring is done; the note adds no ongoing value.

### 9. CHANGELOG.md — Stale

Lists Phase 1-3 under "Unreleased" with no version numbers or dates. Phase 5 is complete but not reflected.

**Action**: Update to reflect actual state, or delete if the team uses git log instead.

---

## Files That Need Renaming or Restructuring

### 10. PHASE_3_5_FAMILY_BACKUP_ACCESS.md — Name too long, disconnected

350 lines of detailed Phase 3.5 design (manifest V2, per-member key wrapping, ownership transfer). Not referenced from ROADMAP.md or PLAN.md.

**Action**: Rename to `PHASE_3_5_DETAIL.md`. Add a one-line reference from PLAN.md's Phase 3.5 section.

### 11. CLOUD_STORAGE_ABSTRACTION.md — Orphaned design doc

335 lines on the iCloud/Google Drive abstraction layer. Referenced only vaguely in PLAN.md Phase 3.5.

**Action**: Rename to `PHASE_3_5_CLOUD_STORAGE.md` so it's clearly associated with its phase.

### 12. docs/README.md — Index without guidance

32 lines listing all docs with one-line summaries. No "where to start" flow.

**Action**: Add a "First-Time Developer" section at the top with a 4-step reading path.

---

## Recommended Final Structure

### What a new developer should read (in order, ~45 minutes)

```
1. docs/INTENT.md (5 min)      — Why Vael exists, what it will never become
2. docs/ARCHITECTURE.md (15 min) — How it's built, project structure
3. docs/RUNNING.md (15 min)     — Get it running on your machine
4. STATE.md (10 min)            — What's done, what's next
```

Everything else is reference material pulled in when needed.

### Proposed file tree

```
Root:
├── README.md                    ← Project overview (keep, add "start here" pointer)
├── ROADMAP.md                   ← Renamed from PLAN.md (single source of truth)
├── STATE.md                     ← Current progress snapshot (keep)
├── CONTRIBUTING.md              ← Trimmed to essentials, links to INTENT.md
├── SECURITY.md                  ← Keep as-is (well-written)
├── CODE_OF_CONDUCT.md           ← Keep (standard)
├── CHANGELOG.md                 ← Update or delete

docs/
├── README.md                    ← Index with guided reading path
├── INTENT.md                    ← Constitutional doc (keep as-is)
├── ARCHITECTURE.md              ← System design (keep as-is)
├── DATA_MODEL.md                ← Schema reference (keep, expand)
├── ENCRYPTION.md                ← Crypto spec (keep as-is)
├── SYNC.md                      ← Sync protocol (trim encryption overlap)
├── UI_DESIGN.md                 ← Design system spec (keep as-is)
├── MIGRATION.md                 ← Data migration from legacy (keep)
├── RUNNING.md                   ← COMPLETE and consolidate setup here
├── GAP_ANALYSIS.md              ← Current gaps (keep)
├── EXTENSION_PLAN_FINANCIAL_PLANNING.md ← New (just created)
├── STORE_DISTRIBUTION.md        ← Renamed from DEVELOPER_ACCOUNT_SETUP.md
├── GOOGLE_CLOUD_SETUP.md        ← Keep (referenced from RUNNING.md)
├── PHASE_3_5_DETAIL.md          ← Renamed from PHASE_3_5_FAMILY_BACKUP_ACCESS.md
├── PHASE_3_5_CLOUD_STORAGE.md   ← Renamed from CLOUD_STORAGE_ABSTRACTION.md
├── agents/
│   ├── Lifetime-Planner.md      ← Keep
│   └── Risk-Planner.md          ← Keep
└── archived/
    └── BUSINESS_LOGIC_PORTING.md ← Moved from BUSINESS_LOGIC.md
```

### Files to DELETE

| File | Reason |
|------|--------|
| `CLAUDE.md` | Exact duplicate of INTENT.md content |
| `docs/ROADMAP.md` | Duplicate of PLAN.md (less detailed) |
| `lib/features/family/README_MIGRATION.md` | One-time refactoring note, work is done |

### Files to RENAME

| Current Name | New Name | Reason |
|-------------|----------|--------|
| `PLAN.md` | `ROADMAP.md` | Clearer name, becomes the single roadmap |
| `docs/DEVELOPER_ACCOUNT_SETUP.md` | `docs/STORE_DISTRIBUTION.md` | It's about App Store publishing, not dev setup |
| `docs/PHASE_3_5_FAMILY_BACKUP_ACCESS.md` | `docs/PHASE_3_5_DETAIL.md` | Too verbose, hard to discover |
| `docs/CLOUD_STORAGE_ABSTRACTION.md` | `docs/PHASE_3_5_CLOUD_STORAGE.md` | Associate with its phase |
| `docs/BUSINESS_LOGIC.md` | `docs/archived/BUSINESS_LOGIC_PORTING.md` | Legacy reference, not active |

### Files to FIX

| File | Fix |
|------|-----|
| `docs/RUNNING.md` | Complete the truncated sections (cuts off mid-content) |
| `docs/SYNC.md` | Replace §"What's Encrypted" with "See ENCRYPTION.md" |
| `CONTRIBUTING.md` | Trim to ~80 lines; link to INTENT.md for principles, RUNNING.md for setup, SECURITY.md for security |
| `docs/README.md` | Add "First-Time Developer? Start Here" section |
| `CHANGELOG.md` | Update to reflect Phase 5 completion, or delete |
| `docs/DATA_MODEL.md` | Expand with FK relationships and soft-delete pattern docs |

---

## Impact Summary

| Metric | Before | After |
|--------|--------|-------|
| Files a new dev must read | ~8 (unclear which) | 4 (clear path) |
| Total doc files | 22 | 19 (3 deleted) |
| Duplicated content | ~600-900 lines | ~0 lines |
| "Where do I start?" answer | Unclear | INTENT → ARCHITECTURE → RUNNING → STATE |
| Setup docs to merge mentally | 4 | 1 (RUNNING.md, linking to others) |
