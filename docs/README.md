# Vael Documentation

## First-Time Developer? Start Here

| Step | File | Time | What you'll learn |
|------|------|------|-------------------|
| 1 | [INTENT.md](INTENT.md) | 5 min | Why Vael exists, what it will never become |
| 2 | [ARCHITECTURE.md](ARCHITECTURE.md) | 15 min | How it's built, project structure, platform strategy |
| 3 | [RUNNING.md](RUNNING.md) | 15 min | Get the app running on your machine |
| 4 | [../STATE.md](../STATE.md) | 10 min | What's been built, what's next |

Everything below is reference material — pull it in when you need it.

## Reference Index

### Core Design

| Document | Covers |
|----------|--------|
| [DATA_MODEL.md](DATA_MODEL.md) | SQLite schema (drift), table definitions, relationships |
| [ENCRYPTION.md](ENCRYPTION.md) | Key hierarchy (FEK/KEK), PBKDF2, AES-256-GCM, SQLCipher |
| [SYNC.md](SYNC.md) | Google Drive sync protocol, changeset format, conflict resolution |
| [UI_DESIGN.md](UI_DESIGN.md) | Design system, color tokens, typography, component specs |

### Phase-Specific Design

| Document | Covers |
|----------|--------|
| [PHASE_3_5_DETAIL.md](PHASE_3_5_DETAIL.md) | Per-member key wrapping, manifest V2, ownership transfer |
| [PHASE_3_5_CLOUD_STORAGE.md](PHASE_3_5_CLOUD_STORAGE.md) | iCloud/Google Drive abstraction layer |
| [EXTENSION_PLAN_FINANCIAL_PLANNING.md](EXTENSION_PLAN_FINANCIAL_PLANNING.md) | Phase 6-8: Lifetime planning + cash management extensions |

### Operations

| Document | Covers |
|----------|--------|
| [GOOGLE_CLOUD_SETUP.md](GOOGLE_CLOUD_SETUP.md) | OAuth client IDs, Cloud Console configuration |
| [STORE_DISTRIBUTION.md](STORE_DISTRIBUTION.md) | App Store / Play Store account setup and publishing |
| [MIGRATION.md](MIGRATION.md) | Migrating data from the legacy PostgreSQL app |

### Health

| Document | Covers |
|----------|--------|
| [GAP_ANALYSIS.md](GAP_ANALYSIS.md) | Current gaps between design docs and implementation |
| [DOCS_CLEANUP_REPORT.md](DOCS_CLEANUP_REPORT.md) | Documentation audit and cleanup tracking |

### Archived

| Document | Why archived |
|----------|-------------|
| [archived/BUSINESS_LOGIC_PORTING.md](archived/BUSINESS_LOGIC_PORTING.md) | Java-to-Dart porting guide (Phase 1-2 work complete) |
