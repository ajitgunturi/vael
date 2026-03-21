# Google Cloud Project Setup

One-time developer setup that enables Google Sign-In and Drive sync for all Vael users. No user ever interacts with the Google Cloud Console — they see only the standard "Sign in with Google" flow.

## Prerequisites

- A Google account (personal Gmail or Workspace)
- Access to [Google Cloud Console](https://console.cloud.google.com)
- Your app bundle IDs finalized:
  - iOS/macOS: `com.vael.vael` (matches Xcode PRODUCT_BUNDLE_IDENTIFIER)
  - Android: `com.vael.vael` (matches AndroidManifest.xml package)

## Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Click the project dropdown (top-left) → **New Project**
3. Project name: `Vael`
4. Organization: leave as "No organization" (personal account) or select your org
5. Click **Create**
6. Select the new project from the dropdown

No billing account required — Drive API is free within standard quotas.

## Step 2: Enable Google Drive API

1. Navigate to **APIs & Services → Library**
2. Search for **Google Drive API**
3. Click it → **Enable**

This unlocks the `drive.file` endpoint. Without this, all Drive API calls return 403 regardless of user authentication.

## Step 3: Configure OAuth Consent Screen

1. Navigate to **APIs & Services → OAuth consent screen**
2. Select **Get started** (or **Configure consent screen** if it already exists)

### 3a. App Information

| Field | Value |
|-------|-------|
| App name | `Vael` |
| User support email | your email |

### 3b. Audience

| Field | Value |
|-------|-------|
| User type | **External** |

External means any Google account can use the app (once published). During testing, only explicitly listed test users can sign in.

### 3c. Contact Information

| Field | Value |
|-------|-------|
| Developer contact email | your email |

### 3d. Scopes

1. Click **Add or remove scopes**
2. Search for `drive.file`
3. Select: `https://www.googleapis.com/auth/drive.file`
   - Description: "See, edit, create, and delete only the specific Google Drive files you use with this app"
4. Click **Update**

This is the most restrictive Drive scope — it only grants access to files/folders the app itself created, not the user's entire Drive.

### 3e. Finish

Click through remaining steps and **Save**.

## Step 4: Add Test Users

While the app is in **Testing** publishing status (the default):

1. Navigate to **APIs & Services → OAuth consent screen → Audience**
2. Under **Test users**, click **Add users**
3. Add email addresses for each family member who will use the app
4. Click **Save**

Testing mode limits:
- Maximum 100 test users
- Only listed emails can complete Google Sign-In
- No Google verification review required
- Sufficient for family-only use indefinitely

To move to **Production** (any Google user can sign in), you would submit for Google verification. For `drive.file` scope this requires a Limited security assessment (questionnaire only, no external audit). This is only needed if distributing beyond your family.

## Step 5: Create OAuth Client IDs

You need one client ID per platform. Navigate to **APIs & Services → Credentials → Create Credentials → OAuth Client ID** for each.

### 5a. iOS

| Field | Value |
|-------|-------|
| Application type | iOS |
| Name | `Vael iOS` |
| Bundle ID | `com.vael.vael` |

After creation:
1. Download `GoogleService-Info.plist`
2. Place it at `ios/Runner/GoogleService-Info.plist`
3. Add the file to the Xcode project (Runner target → Build Phases → Copy Bundle Resources)
4. Add the reversed client ID as a URL scheme in `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Reversed client ID from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

The `google_sign_in` Flutter plugin reads the client ID from `GoogleService-Info.plist` automatically.

### 5b. Android

| Field | Value |
|-------|-------|
| Application type | Android |
| Name | `Vael Android` |
| Package name | `com.vael.vael` |
| SHA-1 certificate fingerprint | (see below) |

Get your SHA-1 fingerprint:

```bash
# Debug keystore (local development)
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android 2>/dev/null | grep SHA1

# Release keystore (app store builds)
keytool -list -v \
  -keystore /path/to/release.keystore \
  -alias your-alias
```

You may need two Android client IDs — one for the debug SHA-1 and one for the release SHA-1. During development, the debug fingerprint is sufficient.

No file download is needed for Android — the `google_sign_in` plugin uses the SHA-1 fingerprint registered in Cloud Console to verify the app's identity at runtime.

### 5c. macOS

| Field | Value |
|-------|-------|
| Application type | **Desktop application** |
| Name | `Vael macOS` |

After creation, note the **Client ID** and **Client Secret**. Unlike iOS/Android, macOS uses a web-based OAuth redirect flow and requires the client ID passed programmatically.

Store the macOS client ID for use in Step 6. Do not commit the client secret to source control — it should be injected via build-time environment variable or a gitignored config file.

## Step 6: Wire Client IDs Into the App

Vael uses a bootstrap script to generate platform config files from `.env`. This keeps secrets out of git while making setup reproducible for any contributor.

### 6a. Create your `.env` file

```bash
cp .env.example .env
```

Fill in the values from the client IDs you created in Step 5:

```bash
# .env
GOOGLE_CLIENT_ID_IOS=123456789-abc.apps.googleusercontent.com
GOOGLE_REVERSED_CLIENT_ID_IOS=com.googleusercontent.apps.123456789-abc
GOOGLE_CLIENT_ID_ANDROID=123456789-def.apps.googleusercontent.com
GOOGLE_CLIENT_ID_MACOS=123456789-ghi.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET_MACOS=GOCSPX-your-secret-here
```

### 6b. Run bootstrap

```bash
make bootstrap
```

This generates:
- `ios/Runner/GoogleService-Info.plist` — read by `google_sign_in` plugin automatically
- `ios/Runner/Info.plist` — injects `CFBundleURLTypes` with reversed client ID (idempotent)
- `android/key.properties` — only if signing values are present (release builds)

All generated files are already in `.gitignore`.

### 6c. How each platform consumes the config

| Platform | Config source | Mechanism |
|----------|--------------|-----------|
| iOS | `GoogleService-Info.plist` | `google_sign_in` plugin reads it from bundle automatically |
| Android | SHA-1 in Cloud Console | Plugin matches app signature at runtime, no local config file needed |
| macOS | `--dart-define` at build time | Passed via `make run-macos` which reads from `.env` |

### 6d. Run the app

```bash
make run-macos    # reads GOOGLE_CLIENT_ID_MACOS from .env automatically
make run-ios      # uses GoogleService-Info.plist generated by bootstrap
make run-android  # uses SHA-1 registered in Cloud Console
```

## Step 7: Verify the Setup

### Quick Smoke Test

1. Run the app:
   ```bash
   make run-macos
   ```
2. Tap "Sign in with Google"
3. Complete the Google consent flow — should show "Vael wants to access Google Drive files it creates"
4. Verify sign-in completes and Drive operations work

### Drive API Test

After sign-in, verify Drive access by creating a test folder:

```dart
// Temporary test — remove after verification
final headers = await authService.getAuthHeaders();
final response = await http.post(
  Uri.parse('https://www.googleapis.com/drive/v3/files'),
  headers: {...headers, 'Content-Type': 'application/json'},
  body: jsonEncode({
    'name': 'vael-test',
    'mimeType': 'application/vnd.google-apps.folder',
  }),
);
print('Drive folder created: ${response.statusCode}'); // expect 200
```

## Sharing Credentials with Contributors

The `.env` file is gitignored — it never enters version control. To share with a contributor:

### Option A: Direct share (family/trusted contributor)

Share the `.env` file directly via a secure channel (AirDrop, Signal, in-person). The contributor then:

```bash
git clone <repo>
cp /path/to/shared/.env .env
make setup     # runs pub get + bootstrap + git hooks
```

### Option B: Password manager (team)

Store the `.env` contents in a shared password manager vault (1Password, Bitwarden). Contributors retrieve and place it manually.

### Option C: CI/CD (GitHub Actions)

For automated builds, store each value as a GitHub Secret and inject at build time:

```yaml
# .github/workflows/build.yml
env:
  GOOGLE_CLIENT_ID_IOS: ${{ secrets.GOOGLE_CLIENT_ID_IOS }}
  GOOGLE_REVERSED_CLIENT_ID_IOS: ${{ secrets.GOOGLE_REVERSED_CLIENT_ID_IOS }}
  GOOGLE_CLIENT_ID_MACOS: ${{ secrets.GOOGLE_CLIENT_ID_MACOS }}
  GOOGLE_CLIENT_SECRET_MACOS: ${{ secrets.GOOGLE_CLIENT_SECRET_MACOS }}

steps:
  - run: ./scripts/bootstrap.sh
  - run: flutter build macos --dart-define=GOOGLE_CLIENT_ID_MACOS=$GOOGLE_CLIENT_ID_MACOS
```

### What a new contributor needs

| Item | How they get it | One-time? |
|------|----------------|-----------|
| `.env` file | Shared via secure channel or password manager | Yes |
| Google account added as test user | You add their email in Cloud Console → OAuth consent screen | Yes |
| Repo access | Standard git clone | Yes |

After receiving `.env`, the full setup is:

```bash
git clone <repo>
cp /path/to/.env .env
make setup
# Done — ready to develop
```

## File Placement Summary

After `make bootstrap`, these gitignored files exist:

```
.env                              ← your credentials (from .env.example)
ios/Runner/GoogleService-Info.plist  ← generated by bootstrap
android/key.properties              ← generated by bootstrap (release only)
```

These files are committed (templates/scripts):

```
.env.example                      ← template with placeholder values
scripts/bootstrap.sh              ← generates config from .env
```

## Scope Reference

| Scope | Access Level | Verification Required |
|-------|-------------|----------------------|
| `drive.file` (Vael uses this) | Only files/folders the app created | Limited assessment (questionnaire) |
| `drive.appdata` | Hidden app-specific folder only | None (non-sensitive) |
| `drive.readonly` | Read all files | Full CASA Tier 2 audit |
| `drive` | Full read/write to all files | Full CASA Tier 2 audit |

Vael uses `drive.file` — the most restrictive scope that still allows folder sharing between family members. The admin's app creates the Vael folder, and Google Drive's native sharing (via Permissions API within `drive.file` scope) grants other members access.

## Testing vs Production Publishing

| Aspect | Testing (default) | Production |
|--------|-------------------|------------|
| Who can sign in | Only listed test users (max 100) | Any Google account |
| Consent screen | Shows "unverified app" warning | Clean branded consent |
| Google review | Not required | Required — submit verification |
| Token expiry | Refresh tokens expire after 7 days | Refresh tokens are long-lived |
| Use case | Family-only / development | Public distribution |

For a family finance app used by 2 people, **testing mode is sufficient**. Move to production only when distributing via app stores to external users.

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Sign-in shows "This app is blocked" | User not in test users list | Add their email in OAuth consent screen → Test users |
| Sign-in works but Drive returns 403 | Drive API not enabled | Step 2 — enable Google Drive API |
| iOS sign-in does nothing | Missing URL scheme | Add reversed client ID to Info.plist CFBundleURLTypes |
| Android sign-in fails with error 10 | SHA-1 mismatch | Regenerate SHA-1 from current keystore, update in Cloud Console |
| macOS sign-in shows blank browser | Missing client ID | Pass `--dart-define=GOOGLE_CLIENT_ID_MACOS=...` at build time |
| "Access blocked: Authorization Error" | Wrong bundle ID / package name | Verify bundle ID in Cloud Console matches Xcode/AndroidManifest |
| Refresh token expires after 7 days | App in testing mode | Expected behavior in testing — re-sign-in. Move to production for persistent tokens |
