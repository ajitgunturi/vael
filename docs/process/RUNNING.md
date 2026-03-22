# Running Vael

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter | 3.41+ (stable) | [flutter.dev/get-started](https://flutter.dev/docs/get-started/install) or FVM |
| Xcode | 16+ | Mac App Store (required for iOS simulator) |
| Android Studio | Latest | [developer.android.com](https://developer.android.com/studio) (required for Android emulator) |
| CocoaPods | 1.15+ | `brew install cocoapods` |

### Flutter path (this repo)

This project uses FVM. The Flutter binary is at:

```
/Users/ajitg/fvm/versions/stable/bin/flutter
```

If you have FVM installed globally, `fvm flutter` also works. **Do not** use a bare `flutter` command unless it resolves to the same SDK.

## Quick Start — iOS Simulator

### 1. Boot a simulator

```bash
# List available simulators
xcrun simctl list devices available

# Boot one (iPhone recommended)
open -a Simulator
# Or boot a specific device:
xcrun simctl boot "iPhone 17 Pro"
```

### 2. Get dependencies

```bash
cd /Users/ajitg/workspace/vael
flutter pub get
```

### 3. Run the app

```bash
# Auto-detect booted simulator
flutter run

# Target a specific device (use device ID from `flutter devices`)
flutter run -d D117ED50
```

The app launches in **debug mode** with dev bootstrap enabled:
- A "Dev Family" and "Dev User" are auto-seeded
- Session is pre-set so you land on the **Dashboard** (skipping onboarding)
- The database is file-backed in Application Support with an opaque filename

### 4. Hot reload / restart

While the app is running:

| Key | Action |
|-----|--------|
| `r` | Hot reload (preserves state) |
| `R` | Hot restart (resets state) |
| `q` | Quit |

## Quick Start — Android Emulator

### 1. Create and boot an emulator

```bash
# List available emulators
flutter emulators

# Launch one
flutter emulators --launch <emulator_id>
```

Or open Android Studio → Device Manager → Create/Start a device.

### 2. Run the app

```bash
flutter run -d <emulator-id>
```

## Quick Start — macOS Desktop

```bash
flutter run -d macos
```

## Quick Start — Chrome (Web)

```bash
flutter run -d chrome
```

> Note: Web is not a primary target. SQLite (drift) uses sql.js in-browser which has limitations.

## Running on iPad Simulator

```bash
xcrun simctl boot "iPad Pro 13-inch (M5)"
flutter run -d 5C59119C   # use the device UUID
```

The app uses **AdaptiveScaffold** which switches layout:
- **Phone** (compact): Bottom navigation bar
- **Tablet** (medium): Navigation rail
- **Desktop/Large tablet** (expanded): Sidebar with labels

## Running Tests

### Unit + Widget tests (fast, no device needed)

```bash
flutter test
```

Current count: **760 tests**

### Integration tests (requires simulator/emulator)

```bash
# All integration tests
flutter test integration_test/

# Single file
flutter test integration_test/navigation_flow_test.dart
```

Current count: **131 tests**

### Full validation (what the pre-commit hook runs)

```bash
dart format --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test
```

## Debug Mode Behavior

In `kDebugMode` (any debug build), `main.dart` automatically:

1. Seeds a family row (`dev_family` / "Dev Family")
2. Seeds a user row (`dev_user` / "Dev User", role: admin)
3. Sets session providers so you skip onboarding and land on Dashboard

To test the **onboarding flow**, do a release build or modify `main.dart` to skip the seed:

```bash
flutter run --release   # no dev seed, starts at onboarding
```

## Release Builds

### iOS (no codesign, for local testing)

```bash
flutter build ios --release --no-codesign
```

### Android APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

## Fastlane (Distribution)

Fastlane configs are in `ios/fastlane/Fastfile` and `android/fastlane/Fastfile`.

```bash
# iOS
cd ios && fastlane build     # Build IPA
cd ios && fastlane beta      # Upload to TestFlight

# Android
cd android && fastlane build   # Build AAB
cd android && fastlane beta    # Upload to Play Store internal track
```

> Requires signing credentials and store accounts to be configured first.

## CI/CD

GitHub Actions (`.github/workflows/ci.yml`) runs on every push/PR to `main`:

1. **Analyze** — format check + static analysis
2. **Test** — full test suite with coverage
3. **Build Android** — release APK (uploaded as artifact)
4. **Build iOS** — release build (no codesign)

## Troubleshooting

### `CocoaPods not installed` or pod errors

```bash
cd ios && pod install --repo-update && cd ..
```

### Simulator not found

```bash
# Ensure Xcode CLI tools are set
sudo xcode-select -s /Applications/Xcode.app
# List devices again
xcrun simctl list devices available
```

### `flutter pub get` fails

```bash
flutter clean
flutter pub get
```

### Tests hang on `pumpAndSettle`

Likely an infinite animation (e.g., `CircularProgressIndicator`). Use the `settle()` helper from `integration_test/helpers/e2e_helpers.dart` which has a bounded timeout.

### Database errors after schema change

```bash
# Delete the app from simulator and re-run
xcrun simctl uninstall booted com.vael.vael
flutter run
```
