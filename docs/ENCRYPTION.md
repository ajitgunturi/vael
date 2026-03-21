# Vael — Encryption Architecture

## Key Hierarchy

```
User Google Sign-In
        │
        ▼
Family Passphrase (entered once per device)
        │
        ▼ PBKDF2 (100k iterations, SHA-256, random salt)
        │
  ┌─────┴─────┐
  │    KEK    │  Key Encryption Key — wraps the FEK
  └─────┬─────┘
        │
        ▼ AES-256-GCM unwrap
        │
  ┌─────┴─────┐
  │    FEK    │  Family Encryption Key — encrypts all data
  └─────┬─────┘
        │
        ├── Encrypts SQLCipher DB passphrase
        ├── Encrypts sync changesets before Drive upload
        └── Stored wrapped (encrypted by KEK) on Google Drive
```

## Flows

### First Device Setup
1. User signs in with Google (for Drive access)
2. User enters a family passphrase
3. App derives KEK from passphrase via PBKDF2 (100k iterations, SHA-256, random 32-byte salt)
4. App generates random 256-bit FEK
5. App wraps FEK with KEK using AES-256-GCM (random 12-byte IV)
6. Wrapped FEK + PBKDF2 salt uploaded to Google Drive (`.meta/manifest.json`)
7. FEK stored in platform secure storage (iOS Keychain / Android KeyStore / macOS Keychain)
8. Passphrase is NOT stored anywhere

### Additional Device
1. User signs in with Google
2. User enters same family passphrase
3. App downloads wrapped FEK + salt from Drive
4. App derives KEK from passphrase + salt via PBKDF2
5. App unwraps FEK using KEK
6. FEK stored in platform secure storage
7. Device is now operational

### Family Member Onboarding
1. Existing member shares passphrase out-of-band (verbally, in person)
2. New member signs in with Google
3. Same flow as "Additional Device" above
4. Existing member grants new member access to the shared Drive folder

### Passphrase Change
1. User enters current passphrase → derives old KEK → unwraps FEK
2. User enters new passphrase → derives new KEK (new random salt)
3. App wraps FEK with new KEK
4. Uploads new wrapped FEK + new salt to Drive (replaces old)
5. All other family devices must re-enter the new passphrase on next sync

## What's Encrypted

| Data | Encryption Method | Where |
|------|------------------|-------|
| SQLite database | SQLCipher (AES-256-CBC, PBKDF2 key from FEK) | On-device |
| Sync changesets | AES-256-GCM with FEK, random IV per changeset | Google Drive |
| Full DB snapshots | AES-256-GCM with FEK | Google Drive |
| Drive file names | Opaque hashes (no financial data in filenames) | Google Drive |

## What's NOT Encrypted

| Data | Why |
|------|-----|
| Family member emails | Needed for Drive folder sharing |
| Sync metadata (timestamps, sequence numbers) | No financial content, needed for ordering |
| App preferences (theme, locale) | Non-sensitive, stored in SharedPreferences |

## Dart Libraries

| Purpose | Library |
|---------|---------|
| AES-256-GCM, PBKDF2 | `pointycastle` (pure Dart crypto) |
| Platform secure storage | `flutter_secure_storage` (Keychain/KeyStore/Keychain) |
| SQLCipher | `sqlcipher_flutter_libs` (native SQLCipher bindings for drift) |
| Random bytes | `dart:math` SecureRandom or `pointycastle` FortunaRandom |

## Security Properties

- **Zero-knowledge**: server (Google Drive) stores only ciphertext. No plaintext financial data leaves the device.
- **Forward secrecy**: not applicable (symmetric key, not session-based). If FEK is compromised, all data is exposed.
- **Key rotation**: change passphrase re-wraps FEK. FEK itself does not change (avoids re-encrypting all data). To rotate FEK: re-encrypt entire DB + all Drive changesets (expensive, manual).
- **Brute-force resistance**: PBKDF2 with 100k iterations. Consider upgrading to Argon2id if `argon2_ffi` stabilizes for all platforms.
- **Recovery**: if passphrase is lost and no device has FEK cached in secure storage, data is unrecoverable. Recommend generating a printable recovery key during setup (FEK encrypted with a high-entropy random key, stored offline by user).
