# Developer Account Registration

Developer accounts are required to distribute Vael through the App Store (iOS/macOS) and Google Play (Android). These are one-time registrations independent of the Google Cloud project setup.

## Registration Summary

| Platform | Account | Cost | Renewal | Approval Time |
|----------|---------|------|---------|---------------|
| Apple | Apple Developer Program | $99 USD/year (~₹8,300) | Annual | 24-48 hours |
| Google | Google Play Developer | $25 USD one-time (~₹2,100) | Never | 2-7 days (identity verification) |

## Apple Developer Program

### Prerequisites

- An Apple ID (personal Gmail works — does not need to be an @icloud.com address)
- Two-factor authentication enabled on the Apple ID
- A Mac (enrollment must be completed from macOS or iOS)
- Government-issued photo ID (passport or Aadhaar-linked ID for India)

### Step 1: Create or Verify Apple ID

If you don't have an Apple ID:
1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Click **Create Your Apple ID**
3. Use any email address
4. Enable two-factor authentication (mandatory for developer program)

If you have one, ensure 2FA is enabled:
1. System Settings → Apple ID → Sign-In & Security → Two-Factor Authentication

### Step 2: Enroll in Apple Developer Program

1. Go to [developer.apple.com/programs/enroll](https://developer.apple.com/programs/enroll)
2. Click **Start Your Enrollment**
3. Sign in with your Apple ID

### Step 3: Choose Enrollment Type

| Type | Use Case | Requirements |
|------|----------|--------------|
| **Individual** | Personal apps, sole developer | Government photo ID |
| **Organization** | Company/business apps | D-U-N-S Number + legal entity docs |

For Vael (personal family app): **Individual** is correct. Your name appears as the seller on the App Store.

### Step 4: Identity Verification

Apple verifies your identity before completing enrollment:

1. Upload or present government-issued photo ID
   - In India: Passport, Aadhaar card, or PAN card (passport is fastest)
2. Apple may do a video call or automated ID scan via the Apple Developer app
3. Verification typically completes within **24-48 hours**

### Step 5: Pay Annual Fee

- $99 USD/year (charged annually)
- Payment via credit/debit card
- Auto-renewal can be turned off

### Step 6: Accept Agreements

After enrollment is approved:
1. Sign in to [developer.apple.com](https://developer.apple.com)
2. Go to **Account → Agreements**
3. Accept the **Apple Developer Program License Agreement**
4. For paid apps (if ever): accept the **Paid Applications Schedule** and set up banking/tax info

### What You Get

| Capability | Details |
|-----------|---------|
| App Store distribution | Submit iOS and macOS apps |
| TestFlight | Distribute beta builds to up to 10,000 testers |
| Certificates & Provisioning | Code signing for device deployment |
| App Store Connect | Manage listings, screenshots, pricing, analytics |
| 100 device UDIDs | Ad-hoc distribution for development/testing |
| Xcode cloud | CI/CD (25 compute hours/month free) |

### Post-Enrollment Setup for Vael

After enrollment is approved:

1. **Create App ID (Bundle ID)**
   - Developer portal → Certificates, IDs & Profiles → Identifiers → App IDs
   - Bundle ID: `com.vael.vael`
   - Capabilities: none required beyond defaults

2. **Create Provisioning Profiles**
   - Development profile (for running on your devices)
   - Distribution profile (for App Store submission)
   - Xcode can manage these automatically (Xcode → Settings → Accounts → Manage Certificates)

3. **Register Test Devices**
   - Your iPhone/iPad UDID → Developer portal → Devices
   - Or use Xcode's automatic device registration

4. **Create App in App Store Connect**
   - [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → My Apps → New App
   - Platform: iOS, macOS
   - Bundle ID: select `com.vael.vael`
   - This is where you'll later upload builds, screenshots, and metadata

---

## Google Play Developer Account

### Prerequisites

- A Google account (can be the same one you use for Google Cloud project)
- Government-issued photo ID (for identity verification)
- A phone number for verification
- Credit/debit card for the one-time fee

### Step 1: Register

1. Go to [play.google.com/console/signup](https://play.google.com/console/signup)
2. Sign in with your Google account

### Step 2: Choose Account Type

| Type | Use Case | Requirements |
|------|----------|--------------|
| **Personal** | Individual developer | Photo ID |
| **Organization** | Company/business | D-U-N-S Number + business docs |

For Vael: **Personal** is correct.

### Step 3: Developer Profile

| Field | Value |
|-------|-------|
| Developer name | Your name (displayed on Play Store as the developer) |
| Contact email | Your email (public-facing for app support) |
| Phone number | Your phone (for Google to contact you, not public) |
| Website | Optional — can add later |

### Step 4: Identity Verification

Google requires identity verification before you can publish apps:

1. **Phone number verification** — SMS or voice call
2. **Identity document** — Upload government-issued photo ID
   - In India: Passport, Aadhaar card, Voter ID, or driving license
3. **Address verification** — May require a recent utility bill or bank statement
4. Verification takes **2-7 business days**
   - Google may ask follow-up questions
   - Account stays in "pending verification" until approved

### Step 5: Pay Registration Fee

- $25 USD one-time (no renewal)
- Payment via credit/debit card

### Step 6: Accept Agreements

1. **Google Play Developer Distribution Agreement**
2. **Developer Program Policies** acknowledgment

### What You Get

| Capability | Details |
|-----------|---------|
| Play Store distribution | Publish Android apps (APK/AAB) |
| Internal testing | Up to 100 testers, no review required |
| Closed testing | Invite-only tracks with up to 200+ testers |
| Open testing | Public beta before production |
| Play Console | Manage listings, releases, analytics, crashes |
| Pre-launch reports | Automated testing on Firebase Test Lab devices |

### Post-Registration Setup for Vael

After verification is approved:

1. **Create App in Play Console**
   - Play Console → All apps → Create app
   - App name: `Vael`
   - Default language: English
   - App type: App (not game)
   - Free or paid: Free

2. **App Signing**
   - Google manages your app signing key (recommended — Play App Signing)
   - You upload an upload key (generated locally)
   - Generate upload keystore:
     ```bash
     keytool -genkey -v \
       -keystore ~/vael-upload-keystore.jks \
       -keyalg RSA -keysize 2048 \
       -validity 10000 \
       -alias vael-upload
     ```
   - Store this keystore securely — losing it requires contacting Google support

3. **Store Listing (Draft)**
   - Title, short description, full description
   - Screenshots (phone, tablet, Chromebook)
   - Feature graphic (1024x500)
   - App icon (512x512)
   - Privacy policy URL (required for apps requesting Drive access)
   - Category: Finance

4. **Content Rating**
   - Complete the IARC rating questionnaire
   - Finance app with no user-generated content → typically rated "Everyone"

5. **Data Safety Section**
   - Declare what data the app collects and how it's used
   - Vael collects: email (for Google Sign-In), financial data (stored locally only)
   - Data not shared with third parties
   - Data encrypted in transit and at rest

---

## Order of Operations

The accounts and Google Cloud project are independent — you can do them in any order. But here's the recommended sequence:

```
1. Google Cloud Project setup          ← enables development & testing
   (GOOGLE_CLOUD_SETUP.md)                immediately, no store account needed

2. Apple Developer Program enrollment  ← 24-48h verification wait
   (submit early, develop while waiting)

3. Google Play Developer registration  ← 2-7 day verification wait
   (submit early, develop while waiting)

4. Development & testing               ← uses Google Cloud OAuth in testing mode
   (runs on simulator/emulator + your physical devices via Xcode/ADB)

5. App Store / Play Store submission   ← only needed when ready to distribute
   (Phase 5 in ROADMAP.md)
```

You can develop and test Vael fully without store accounts. The Apple/Google developer accounts are only needed when you want to:
- Run on physical iOS devices (Apple requires provisioning profiles)
- Submit to the App Store or Play Store
- Use TestFlight (Apple) or internal testing tracks (Google)

For macOS development builds, you can run unsigned during development (Xcode handles this). For Android, debug builds work on any device with USB debugging enabled — no Play Console needed.

## Cost Summary

| Item | Cost | Frequency |
|------|------|-----------|
| Google Cloud Project | Free | — |
| Google Play Developer | $25 USD (~₹2,100) | One-time |
| Apple Developer Program | $99 USD (~₹8,300) | Annual |
| **Year 1 total** | **$124 USD (~₹10,400)** | |
| **Year 2+ total** | **$99 USD (~₹8,300)** | Apple renewal only |

No other recurring costs — consistent with Vael's zero operating cost principle (INTENT.md §5). The developer accounts are the only cost, and they're developer-side, not user-side.

## India-Specific Notes

### Apple

- Payment in USD — your card will be charged with forex conversion
- GST may apply on the ₹ equivalent (Apple invoices from Ireland)
- Tax residency: during enrollment, select India and provide PAN if prompted
- App Store pricing: you can set prices in INR tiers (Apple handles currency for buyers)

### Google

- Payment in USD via international card
- Google Play payouts (if app is ever paid): requires Indian bank account + PAN + GST registration
- For a free app (Vael): no payout setup needed
- Address on profile should match your ID document

### Documents to Keep Ready

| Document | Used For |
|----------|----------|
| Passport | Apple identity verification (fastest), Google identity verification |
| PAN card | Apple tax setup, Google payout setup (if needed) |
| Aadhaar | Alternative ID for both platforms |
| Recent utility bill / bank statement | Google address verification (if requested) |
