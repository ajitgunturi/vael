# Privacy Policy

**Vael — Family Finance Manager**
**Effective Date:** April 1, 2026
**Last Updated:** March 25, 2026

Vael is built by Vaelith Technologies ("we", "us", "our"). This policy explains what data Vael handles, where it lives, and what we can and cannot see.

**The short version:** Your financial data never leaves your device unencrypted. We cannot read it. We do not collect it. We have no servers that store it.

---

## 1. Data That Stays on Your Device

All financial data you enter into Vael is stored **exclusively on your device** in an encrypted local database. This includes:

- Account names and balances
- Transactions, budgets, and goals
- Investment holdings and loan details
- Life profile and planning parameters
- Recurring rules and allocation settings
- Net worth milestones and financial decisions

**We have zero access to this data.** There is no server, no analytics pipeline, and no telemetry that transmits your financial information to us or any third party.

---

## 2. Optional Cloud Backup (Google Drive)

If you choose to enable cloud sync, Vael uses **your own Google Drive** as an encrypted storage transport.

### What happens:
- All data is encrypted **on your device** using AES-256-GCM before upload
- Encryption uses a Family Encryption Key (FEK) derived from your passphrase via PBKDF2 (100,000 iterations)
- Files uploaded to Drive are indistinguishable from random data — file names are opaque hashes, not human-readable
- Google acts only as storage — it cannot read, infer, or profile your financial data

### What we can see: **Nothing.**
- We do not have access to your Google Drive
- We do not store your passphrase, encryption keys, or Google credentials
- We do not operate any server that participates in the sync process

### What Google can see:
- That you use a Google Drive app (Vael) to store encrypted files
- File sizes and timestamps of encrypted blobs
- Google **cannot** read the contents of these files

You can disable cloud sync at any time. Vael works fully offline.

---

## 3. Google Sign-In

Vael uses Google Sign-In solely to authenticate your identity for Google Drive access. We receive:

- Your Google email address
- Your display name
- A Drive-scoped OAuth token (limited to the Vael app folder)

We do **not** receive or store your Google password. The OAuth token is stored locally on your device and is never transmitted to our servers (we have none).

---

## 4. Data We Do Not Collect

Vael does **not** collect, transmit, or store:

- Usage analytics or telemetry
- Crash reports (unless you explicitly choose to send one via the in-app feedback tool)
- Device identifiers, advertising IDs, or fingerprints
- Location data
- Contacts, photos, or any data outside of what you manually enter
- Financial data in any form accessible to us

---

## 5. Crash Reports and Feedback

Vael includes an in-app feedback tool that lets you report bugs or request features.

### When you submit feedback:
- You choose what to include — description text you write, and optionally a sanitized crash log
- Crash logs contain **only technical stack traces** (function names, line numbers, error messages) — never your financial data, account names, balances, or transaction details
- You review the exact content before sending
- Feedback is sent to our support email and stored only for the purpose of fixing bugs

### When you do not submit feedback:
- No crash data, diagnostic data, or usage data is collected or transmitted — ever

---

## 6. Data Sharing

We do not share your data with anyone. Specifically:

- **No advertising partners.** Vael has no ads.
- **No analytics providers.** No Firebase Analytics, Mixpanel, Amplitude, or equivalent.
- **No data brokers.** Your financial data has zero commercial value to us because we never possess it.
- **No government disclosure.** We cannot comply with data requests for data we do not have.

---

## 7. Data Stored on Your Device

| Data | Storage Location | Encrypted | Accessible to Us |
|------|-----------------|-----------|-------------------|
| Financial data (accounts, transactions, budgets, goals) | Device SQLite database | Yes (AES-256) | No |
| Passphrase-derived keys | Device secure storage (Keychain/Keystore) | Yes | No |
| Google OAuth token | Device secure storage | Yes | No |
| Cloud backup data | Your Google Drive | Yes (AES-256-GCM) | No |
| App preferences (theme, display settings) | Device local storage | No | No |

---

## 8. Children's Privacy

Vael is a family finance tool designed for use by adults. We do not knowingly collect data from children under 13. Since we do not collect any user data, this concern is structurally eliminated.

---

## 9. Data Retention and Deletion

- **Your data, your control.** All data lives on your device. Delete the app and the data is gone.
- **Cloud backups:** Delete the Vael folder from your Google Drive to remove all cloud copies. Since files are encrypted with your passphrase, they are permanently unreadable without it.
- **No server-side retention.** We have no servers storing your data, so there is nothing for us to retain or delete.

---

## 10. Security

- **Encryption at rest:** AES-256 via SQLCipher for the local database
- **Encryption in transit:** AES-256-GCM for all cloud sync data, plus TLS for the Google Drive API connection
- **Key derivation:** PBKDF2 with 100,000 iterations, SHA-256, random salt
- **Key storage:** Platform secure storage (iOS Keychain / Android Keystore)
- **No remote attack surface:** Vael has no backend servers, APIs, or network endpoints that could be compromised

---

## 11. Changes to This Policy

We will update this policy if our data practices change. Material changes will be communicated via an in-app notice. The "Last Updated" date at the top reflects the most recent revision.

Since Vael's architecture is fundamentally local-first and zero-knowledge, changes are unlikely to be material.

---

## 12. Contact Us

If you have questions about this privacy policy or Vael's data practices:

- **Email:** privacy@vaelith.com
- **Bug Reports:** Use the in-app feedback tool (Settings > Help & Feedback)
- **Website:** https://vaelith.com/privacy

---

**Summary:** Vael is a zero-knowledge, local-first application. Your financial data is yours alone. We built it this way on purpose.

*Vaelith Technologies*
*Hyderabad, India*
