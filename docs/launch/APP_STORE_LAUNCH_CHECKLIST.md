# Vael — App Store Launch Checklist

Complete guide: private testing, developer registration, app submission, and in-app support infrastructure.

---

## Phase 0: Private Distribution (Select Users)

Start here. Get the app into the hands of select users before committing to store registration. No recurring cost for Android; Apple Developer fee required only if you have iOS testers.

### Android — Free, No Registration

- [ ] **Build release APK:** `flutter build apk --release`
- [ ] **Share directly** — Send the APK via WhatsApp, email, or Google Drive. Users enable "Install from unknown sources" on their device and install.
- [ ] **Alternative: Firebase App Distribution** — Free. Upload APK at [firebase.google.com/products/app-distribution](https://firebase.google.com/products/app-distribution). Invite testers by email. They get a link to install + automatic update notifications.

No Play Console account, no fees, no review process. Works immediately.

### iOS — Requires Apple Developer (₹8,700/year)

There is no free path to distribute to non-developer iOS users. Apple requires a paid developer account for any form of distribution.

- [ ] **Enroll in Apple Developer Program** (see Phase 2 below) — ₹8,700/year
- [ ] **Upload build to TestFlight** — `flutter build ipa --release`, then upload via Xcode or Transporter
- [ ] **Add internal testers** (up to 100) — No Apple review needed. Testers get the app within minutes.
- [ ] **Add external testers** (up to 10,000) — Requires a lightweight Apple review (usually <24 hours). Testers get an invite link.

TestFlight is excellent — automatic updates, crash reports, 90-day build expiry (forces you to keep shipping).

### Which Path to Choose

| Scenario | Cost | Timeline |
|----------|------|----------|
| Android testers only | **₹0** | Same day |
| Android (Firebase) + iOS (TestFlight) | **₹8,700/year** | 1-2 days (Apple approval) |
| Full public launch (both stores) | **~₹13,100 year 1** | 3-4 weeks (see below) |

**Recommendation:** Start with Android APK sharing + TestFlight for iOS testers. Defer Play Store and App Store public listing until you've collected feedback from your private group.

---

## Phase 1: Online Presence

Set up your developer identity before public store registration. No company registration needed — publish as an independent developer.

### Domain and Email

- [ ] **Register domain** — vaelith.com (or similar). Cost: ~₹800/year. Use Cloudflare, Namecheap, or Google Domains.
- [ ] **Set up email** — support@vaelith.com and privacy@vaelith.com. Use Google Workspace (~₹1,500/yr) or Zoho Mail (free tier for 1 domain, 5 users).
- [ ] **Verify email works** — Send/receive test emails. Apple and Google will contact you here.

### Website (Minimal)

- [ ] **Landing page** — Host on GitHub Pages (free) or Cloudflare Pages. Needs:
  - One-paragraph app description
  - Privacy policy page (use `docs/legal/privacy-policy.md`)
  - Terms of service page
  - Support contact (support@vaelith.com)
- [ ] **Privacy policy URL live** at https://vaelith.com/privacy — both stores require this before submission
- [ ] **Terms of service URL live** at https://vaelith.com/terms

---

## Phase 2: Apple Developer Program

### Enrollment

- [ ] **Apple ID** — Use a dedicated Apple ID (e.g., developer@vaelith.com). Enable 2FA.
- [ ] **Enroll as Individual** at [developer.apple.com/programs/enroll](https://developer.apple.com/programs/enroll)
  - Cost: ₹8,700/year (~$99)
  - Payment: International credit/debit card
  - Your legal name appears as the developer ("Ajit Gunturi" on the App Store)
  - Requires government-issued photo ID for verification
  - Approval timeline: **24-48 hours**
- [ ] **Accept agreements** — In App Store Connect, accept the Paid Applications agreement (even for free apps — needed for future in-app purchases)

> **Later upgrade path:** If you register an LLP/company later, you can convert your Individual account to an Organization account without losing your app or reviews. No rush.

### Certificates and Profiles

- [ ] **Create iOS Distribution Certificate** — Keychain Access > Certificate Assistant > Request from CA, upload to developer portal
- [ ] **Create App ID** — Bundle ID: `com.vaelith.vael`
- [ ] **Create Provisioning Profile** — Distribution > App Store
- [ ] **Configure in Xcode** — Open `ios/Runner.xcworkspace`, set Team and Bundle ID

### App Store Connect Setup

- [ ] **Create app listing** in App Store Connect
- [ ] **App name:** "Vael — Family Finance"
- [ ] **Subtitle:** "Private. Local. Yours." (max 30 chars)
- [ ] **Category:** Primary: Finance. Secondary: Productivity.
- [ ] **Content rating:** Complete the questionnaire (no objectionable content, no data collection)
- [ ] **App Privacy — Nutrition Labels:**
  - Data Not Collected (for everything except optional crash logs)
  - Data Not Linked to You: Crash Logs (only if user opts in)
  - Data Used to Track You: **None**

### Screenshots (Required Sizes)

- [ ] **iPhone 6.7"** (1290 x 2796) — iPhone 15 Pro Max / 16 Pro Max. **Minimum 3, maximum 10.**
- [ ] **iPhone 6.5"** (1242 x 2688) — Required if supporting older phones
- [ ] **iPad 12.9"** (2048 x 2732) — If submitting iPad build
- [ ] **Mac** — If submitting macOS build

Screenshot suggestions for Vael:
1. Dashboard with net worth hero card and savings rate
2. Account list with grouped sections
3. Budget screen with progress bars
4. Planning dashboard with health metrics
5. FI Calculator with sliders
6. Transaction list with filters
7. Statement import flow
8. Settings with Financial Planning section

### Build and Submit

- [ ] **Build archive:** `flutter build ipa --release`
- [ ] **Upload via Xcode** or Transporter app
- [ ] **Submit for review** — Include review notes:
  - "Vael is a local-first family finance app. All data is stored on-device. No server account needed. To test: launch app > tap Get Started > create a family name > add an account."
  - If the app uses Google Sign-In: explain it's only for optional Drive backup
- [ ] **Export compliance:** Vael uses AES-256 encryption. You must declare this:
  - "Does your app use encryption?" → **Yes**
  - "Is it exempt under ECCN 5D002?" → **Yes** (standard encryption for data protection, not custom crypto)
  - Consider filing a **self-classification report** with BIS annually — Apple may ask for this

### Review Timeline

- First submission: **1-3 days** typically, up to 7 days
- Finance apps may get extra scrutiny — respond to reviewer questions promptly
- Common rejection reasons for finance apps:
  - Missing privacy policy link
  - Unclear what the app does on first launch
  - App appears "too empty" without data — consider adding demo/sample data option

---

## Phase 3: Google Play Developer Account

### Enrollment

- [ ] **Google account** — Use a dedicated account (developer@vaelith.com or your personal Google account)
- [ ] **Enroll at** [play.google.com/console/signup](https://play.google.com/console/signup)
  - Cost: $25 one-time (₹~2,100)
  - Payment: Any card
- [ ] **Identity verification** — Government ID + address proof. Timeline: 5-7 business days.
- [ ] **Developer profile:**
  - Developer name: Your name or "Vaelith" (this is what appears on Play Store — you can use a trade name)
  - Contact email: support@vaelith.com
  - Website: https://vaelith.com
  - Physical address: Required and **publicly visible** on your listing. Use your home address or a virtual office address if you prefer privacy.

### App Listing

- [ ] **Create application** in Play Console
- [ ] **Default language:** English (India)
- [ ] **App name:** "Vael — Family Finance"
- [ ] **Short description:** (max 80 chars) "Private family finance manager. All data stays on your device."
- [ ] **Full description:** (max 4000 chars) Detailed feature list + privacy commitment
- [ ] **Category:** Finance
- [ ] **Content rating:** Complete IARC questionnaire
- [ ] **Target audience:** 18+ (financial planning content)

### Data Safety Form

- [ ] **Data collected:**
  - Financial info: Yes → Collected, not shared, not transferred off device
  - Crash logs: Optional → Collected only with user consent, used for app stability
- [ ] **Security practices:**
  - Data is encrypted in transit: Yes (AES-256-GCM + TLS)
  - Data is encrypted at rest: Yes (AES-256 via SQLCipher)
  - Users can request data deletion: Yes (delete app = delete data)
- [ ] **Data not shared with third parties:** Confirm for all categories

### Mandatory Closed Testing (New Developer Accounts)

Google requires new developers to run a **closed test** before production release. **Start this immediately after account approval — it's a 14-day calendar gate.**

- [ ] **Recruit 12+ testers now** — friends, family, ISB network, colleagues. Collect their Gmail addresses.
- [ ] **Create a closed testing track** in Play Console
- [ ] **Upload a signed AAB** — `flutter build appbundle --release`
- [ ] **Send testing link** to all testers — they must opt-in and install
- [ ] **Run for 14 consecutive days** with the app actively installed by testers
- [ ] **After 14 days:** Apply for production access

### Signing

- [ ] **Generate upload key:** `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
- [ ] **Configure in `android/key.properties`** (do NOT commit this file — add to .gitignore)
- [ ] **Enroll in Play App Signing** — Google manages the app signing key; you keep the upload key
- [ ] **Store keystore backup securely** — Losing this means you can never update the app. Back up to an encrypted USB drive or password manager.

### Build and Submit

- [ ] **Build release:** `flutter build appbundle --release`
- [ ] **Upload AAB** to the closed testing track first
- [ ] **Promote to production** after 14-day testing period
- [ ] **Review timeline:** 1-3 days for first review, sometimes up to 7

---

## Phase 4: In-App Support Infrastructure

Build these features before submission. They're what makes an indie app feel professional.

### 3a. Help & Feedback Screen (Settings > Help & Feedback)

- [ ] **Bug Report form:**
  - Text field: "Describe the issue"
  - Toggle: "Include crash log" (off by default)
  - Preview screen showing exactly what will be sent (transparency builds trust)
  - Send button → composes email to support@vaelith.com via `url_launcher` (mailto:) or platform share sheet
  - **No automatic data collection** — user controls every byte sent

- [ ] **Feature Request form:**
  - Text field: "What would you like to see?"
  - Send button → same email mechanism

- [ ] **FAQ / Help section:**
  - "Is my data private?" → Yes, explain architecture
  - "What does cloud sync do?" → Explain encrypted Drive backup
  - "How do I delete my data?" → Delete app + remove Drive folder
  - "How do I report a bug?" → This screen
  - "Who can see my finances?" → Nobody, not even us

### 3b. Crash Log Collection (User-Controlled)

- [ ] **Implement crash log capture:**
  - Use `FlutterError.onError` and `PlatformDispatcher.instance.onError` to capture stack traces to a local ring buffer
  - Store last 5 crash logs in app-local storage (NOT in the encrypted financial DB)
  - Crash logs contain ONLY: timestamp, stack trace (function names + line numbers), Flutter version, OS version, device model
  - Crash logs NEVER contain: account names, balances, transactions, user email, or any financial data

- [ ] **Review-before-send UX:**
  - User taps "Send Bug Report" → sees full crash log text in a scrollable preview
  - User can edit/redact anything before sending
  - Explicit consent: "This will send the above information to support@vaelith.com"
  - Send via platform share sheet or mailto link

- [ ] **Retention:**
  - Local crash logs auto-purge after 7 days
  - No logs sent without user action
  - No background reporting, no silent uploads

### 3c. App Version and Legal Links

- [ ] **Settings screen footer:**
  - App version and build number
  - "Privacy Policy" → opens https://vaelith.com/privacy
  - "Terms of Service" → opens https://vaelith.com/terms
  - "Open Source Licenses" → Flutter's built-in `LicensePage`

### 3d. Support Contact Visibility

- [ ] **In-app:** Settings > Help & Feedback > "Contact Us" → support@vaelith.com
- [ ] **App Store listing:** support@vaelith.com
- [ ] **Play Store listing:** support@vaelith.com + https://vaelith.com/support
- [ ] **Privacy Policy:** privacy@vaelith.com

---

## Phase 5: Pre-Submission Checklist

### Legal

- [ ] Privacy policy published at https://vaelith.com/privacy
- [ ] Terms of service published at https://vaelith.com/terms
- [ ] Export compliance documentation (encryption self-classification)

### App Quality

- [ ] All unit tests pass (`make test`)
- [ ] All integration tests pass on simulator
- [ ] Test on physical iPhone
- [ ] Test on physical Android device
- [ ] Test on iPad (if submitting iPad build)
- [ ] Test offline mode — airplane mode for 24h, verify all features work
- [ ] Test Google Drive sync end-to-end with real Google account
- [ ] Test fresh install → onboarding → first account → first transaction
- [ ] Accessibility: VoiceOver (iOS) and TalkBack (Android) basic pass
- [ ] Dark mode renders correctly
- [ ] Landscape mode doesn't crash (even if not optimized)

### Assets

- [ ] **App icon:** 1024x1024 PNG, no transparency, no rounded corners (stores add them)
- [ ] **Feature graphic (Play Store):** 1024x500 PNG
- [ ] **Screenshots:** See sizes above. Use a tool like `screenshots` package or Fastlane
- [ ] **App description:** Written, proofread, keyword-optimized
- [ ] **What's New text:** For v1.0 — "Initial release"

### Configuration

- [ ] Bundle ID set: `com.vaelith.vael`
- [ ] Version: `1.0.0+1` in pubspec.yaml
- [ ] Android `minSdkVersion`: 21+ (or 23 for biometric APIs)
- [ ] iOS deployment target: 15.0+
- [ ] ProGuard/R8 rules configured (Android release builds)
- [ ] Bitcode disabled (Flutter doesn't support it)
- [ ] NSAppTransportSecurity configured (iOS — Google Sign-In may need exceptions)
- [ ] Google Sign-In OAuth client IDs configured for production (not just debug)
- [ ] `--dart-define` build flags for prod Google Client IDs

---

## Phase 6: Post-Launch

- [ ] **Monitor reviews** — Respond to every 1-star and 2-star review within 24 hours
- [ ] **Monitor crash reports** — User-submitted reports via in-app feedback are your signal
- [ ] **App Store Optimization (ASO):**
  - Keywords: family finance, budget tracker, expense manager, investment tracker, net worth, India, private, offline
  - Update screenshots if UI changes
- [ ] **Iterate on feedback** — Prioritize usability issues over features
- [ ] **File annual export compliance** (Apple) — Self-classification report for encryption

---

## Timeline Summary

### Private Distribution (Select Users)

| Step | Duration | Dependency |
|------|----------|------------|
| Android APK build + share | Same day | None |
| Apple Developer enrollment | 1-2 days | Apple ID + 2FA + ₹8,700 |
| TestFlight upload + internal testers | Same day after enrollment | Apple Developer |

**Fastest path to select users: Android same day, iOS 1-2 days.**

### Full Public Launch

| Step | Duration | Dependency |
|------|----------|------------|
| Domain + Email + Website | 1-2 days | None |
| Apple Developer (Individual) | 1-2 days approval | Apple ID + 2FA |
| Google Play Developer | 5-7 days (ID verification) | Google account |
| In-app support features | 3-5 days dev work | None |
| Screenshots + Store assets | 2-3 days | App feature-complete |
| Google closed testing | 14 days (hard gate) | Play account approved |
| Apple first review | 1-7 days | Build uploaded |
| Google first review | 1-3 days | 14-day testing done |

**Fastest path to App Store: ~2 weeks from today.**
**Fastest path to Play Store: ~3-4 weeks** (14-day testing gate is the bottleneck).

Start both registrations on Day 1. The Google 14-day clock should begin ticking while you work on screenshots and final polish.

---

## Costs Summary

### Private Distribution Only

| Item | Cost | Frequency |
|------|------|-----------|
| Android (APK / Firebase) | ₹0 | — |
| Apple Developer (for TestFlight) | ₹8,700 | Annual |
| **Total if Android-only testers** | **₹0** | |
| **Total if iOS testers needed** | **₹8,700/year** | |

### Full Public Launch

| Item | Cost | Frequency |
|------|------|-----------|
| Apple Developer Program | ₹8,700 | Annual |
| Google Play Developer | ₹2,100 | One-time |
| Domain (vaelith.com) | ₹800 | Annual |
| Email (Google Workspace) | ₹1,500 | Annual |
| **Total Year 1** | **~₹13,100** | |
| **Total Recurring** | **~₹11,000/year** | |

---

## Future: Upgrading to Organization (Optional)

If Vael gains traction and you want to formalize, you can upgrade without losing your app or reviews.

**When it makes sense:**
- Taking on a co-founder or splitting revenue
- Investors or grants require a legal entity
- You want "Vaelith Technologies" instead of your personal name on the stores

**What you'd need:**
- Register LLP or Private Limited (2-4 weeks, ₹5-8K)
- Obtain D-U-N-S Number (free, 5-14 days)
- Apple: Request Organization account conversion in developer portal
- Google: Update developer profile name (instant)

This can happen at any time — months or years after launch. Ship first.
