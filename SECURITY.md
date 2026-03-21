# Security Policy

Vael handles encrypted financial data. Security vulnerabilities are treated with the highest priority.

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Email security reports to: **vael-security@proton.me**

Include:
- Description of the vulnerability
- Steps to reproduce
- Affected files/components
- Potential impact

### Response Timeline

| Action | Timeframe |
|--------|-----------|
| Acknowledgment | 48 hours |
| Initial assessment | 5 business days |
| Fix or mitigation | 30 days (critical), 90 days (moderate) |
| Public disclosure | After fix is released |

## Security-Critical Files

Changes to these files require security-focused review:

| File | Handles |
|------|---------|
| `lib/core/crypto/key_derivation.dart` | PBKDF2 key derivation (iteration count, salt) |
| `lib/core/crypto/aes_gcm.dart` | AES-256-GCM encryption/decryption |
| `lib/core/crypto/fek_manager.dart` | FEK generation, wrap/unwrap |
| `lib/core/crypto/key_storage.dart` | Platform keychain/keystore interaction |
| `lib/core/crypto/crypto_orchestrator.dart` | Key lifecycle (setup, join, passphrase change) |
| `lib/core/sync/sync_push.dart` | Encrypts data before Drive upload |
| `lib/core/sync/sync_pull.dart` | Decrypts data after Drive download |
| `lib/core/sync/snapshot_manager.dart` | Full DB snapshot encryption |
| `lib/core/sync/drive_client.dart` | Drive API interaction (file naming) |
| `lib/core/database/database.dart` | SQLCipher configuration |

## Security Invariants

These properties must **never** be violated:

1. **No plaintext financial data leaves the device** — every byte written to Google Drive is encrypted with the FEK using AES-256-GCM
2. **Drive file names are opaque** — no file or folder name contains financial terms, account names, or amounts
3. **Passphrases are never stored** — only the derived KEK is used transiently; the FEK is stored in platform secure storage
4. **Random IVs on every encryption** — the same plaintext must produce different ciphertext each time
5. **Key material is never logged** — no FEK, KEK, passphrase, or salt in console output, crash reports, or analytics
6. **SQLCipher protects data at rest** — the local database is unreadable without the FEK

## Contributor Security Checklist

Before submitting a PR that touches crypto or sync code:

- [ ] All encryption paths have round-trip tests (encrypt → decrypt → assert equality)
- [ ] Ciphertext is non-deterministic (random IV verified in tests)
- [ ] No key material appears in logs, error messages, or exceptions
- [ ] Drive file names use opaque identifiers, not descriptive names
- [ ] New dependencies do not transmit data to external services
- [ ] `flutter analyze` passes with zero warnings on crypto/sync files

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest  | Yes       |
| Older   | No — update to latest |
