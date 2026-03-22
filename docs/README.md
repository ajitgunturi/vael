# Vael — Native Family Finance App

Vael is the production-grade successor to this repo. It replaces the Docker-based monolith with a native Flutter app that runs on iOS, iPad, Android, and macOS — with all computation local, data encrypted on-device, and sync via encrypted Google Drive changesets.

## Documentation Index

| Document | What it covers |
|----------|---------------|
| [INTENT.md](INTENT.md) | Purpose, governing principles, anti-vision, and decision framework — the constitutional document |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System architecture, tech stack, project structure, form factor strategy |
| [DATA_MODEL.md](DATA_MODEL.md) | SQLite schema (drift), table definitions, sync changelog design |
| [BUSINESS_LOGIC.md](BUSINESS_LOGIC.md) | Full inventory of Java business logic to port to Dart, with source file references |
| [ENCRYPTION.md](ENCRYPTION.md) | Key hierarchy, PBKDF2 derivation, AES-256-GCM, SQLCipher, family key sharing |
| [SYNC.md](SYNC.md) | Google Drive sync protocol, changeset format, conflict resolution, snapshots |
| [MIGRATION.md](MIGRATION.md) | How to migrate data from the current PostgreSQL app into Vael's local SQLite |
| [ROADMAP.md](ROADMAP.md) | 5-phase implementation plan with timeline and verification criteria |
| [RUNNING.md](RUNNING.md) | How to run the app on simulators, emulators, desktop, and web — plus testing and CI |

## Key Decisions

- **Framework**: Flutter 3.x + Dart (single codebase, all platforms)
- **Database**: drift (SQLite) + SQLCipher (AES-256 encryption at rest)
- **State**: Riverpod
- **Sync**: Google Drive API v3 with encrypted JSON changesets — no server
- **Auth**: Google Sign-In (for Drive access only, not a custom auth server)
- **Encryption**: Family Encryption Key (FEK) derived from shared passphrase via PBKDF2
- **Platforms**: iOS 16+, iPadOS, Android 8+, macOS 13+
- **Form factors**: Landscape master-detail (iPad Pro, Mac), portrait stack (phones)

## Repo

The new repo will be created at `~/workspace/vael` when development begins.
