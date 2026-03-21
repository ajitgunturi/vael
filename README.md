# Vael

Private, local-first family finance app. No servers, no subscriptions, no data leaves your device unencrypted.

## What It Does

- **Unified family finances** — accounts, transactions, budgets, goals, and loans in one place
- **End-to-end encrypted sync** — AES-256-GCM encryption with a family passphrase; Google Drive is blind storage
- **Zero cost to operate** — no backend, no recurring fees, works fully offline
- **Selective visibility** — each family member controls what they share

## Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter (iOS, Android, macOS) |
| Database | drift + SQLCipher (encrypted SQLite) |
| State | Riverpod |
| Encryption | pointycastle (AES-256-GCM, PBKDF2) |
| Sync | Google Drive API v3 (encrypted transport) |
| Charts | fl_chart |

## Architecture

```
Passphrase → PBKDF2 → KEK → unwraps FEK → encrypts everything
                                  ↓
                         Local SQLCipher DB
                                  ↓
                    Encrypted changesets → Google Drive
```

All financial data is encrypted client-side before leaving the device. Google Drive stores only ciphertext — file names are opaque, folder structures leak no financial semantics. If a cloud provider scans the entire folder, contents are indistinguishable from random data.

## Development

```bash
cp .env.example .env             # Fill in Google OAuth client IDs (get from maintainer)
make setup                       # Install deps + bootstrap credentials + activate git hooks
make build-runner                # Generate drift code
make check                       # Format + lint + test in one step
make run-macos                   # Run on macOS (client IDs injected from .env)
```

Credentials setup details in [CONTRIBUTING.md](CONTRIBUTING.md). Google Cloud project setup in [docs/GOOGLE_CLOUD_SETUP.md](docs/GOOGLE_CLOUD_SETUP.md).

**517 tests** covering financial math, encryption round-trips, sync push/pull, conflict resolution, and UI.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Key points:

- TDD is mandatory — tests before implementation
- All changes must pass the [Decision Framework](docs/INTENT.md)
- Security-sensitive PRs require extra review (see [SECURITY.md](SECURITY.md))
- Conventional Commits for commit messages

## Privacy Model

- No telemetry, analytics, or crash reporting
- No bank API connections — data enters via manual entry or statement import
- No AI/ML — all calculations are deterministic (PMT, FV, amortization)
- Passphrase is never stored; if lost and no device has the cached key, data is unrecoverable

## Security

For vulnerability reports, see [SECURITY.md](SECURITY.md). Do not open public issues for security concerns.

## License

[AGPL-3.0](LICENSE) — you can use, modify, and distribute Vael, but derivative works must remain open-source under the same license.
