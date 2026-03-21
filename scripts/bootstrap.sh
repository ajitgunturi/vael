#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# bootstrap.sh — Generate platform config files from .env
#
# Reads OAuth client IDs from .env and produces:
#   1. ios/Runner/GoogleService-Info.plist
#   2. android/app/key.properties  (if signing values present)
#   3. Injects CFBundleURLTypes into ios/Runner/Info.plist (if not already present)
#
# Usage:
#   make bootstrap        (recommended)
#   ./scripts/bootstrap.sh
#
# Prerequisites:
#   1. Copy .env.example to .env
#   2. Fill in real values from Google Cloud Console
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"

# ─── Preflight ────────────────────────────────────────────────────────────────

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env file not found."
  echo ""
  echo "  cp .env.example .env"
  echo "  # Then fill in your Google Cloud Console values"
  echo "  # See docs/GOOGLE_CLOUD_SETUP.md"
  echo ""
  exit 1
fi

# Source .env (handles values with or without quotes)
set -a
# shellcheck source=/dev/null
source "$ENV_FILE"
set +a

# ─── Validate required values ────────────────────────────────────────────────

MISSING=()

check_var() {
  local var_name="$1"
  local val="${!var_name:-}"
  if [[ -z "$val" || "$val" == your-* ]]; then
    MISSING+=("$var_name")
  fi
}

check_var "GOOGLE_CLIENT_ID_IOS"
check_var "GOOGLE_REVERSED_CLIENT_ID_IOS"
check_var "GOOGLE_CLIENT_ID_MACOS"

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "ERROR: Missing or placeholder values in .env:"
  for v in "${MISSING[@]}"; do
    echo "  - $v"
  done
  echo ""
  echo "Fill these in from Google Cloud Console → APIs & Services → Credentials"
  exit 1
fi

# ─── 1. Generate iOS GoogleService-Info.plist ─────────────────────────────────

IOS_PLIST="$ROOT/ios/Runner/GoogleService-Info.plist"

# Extract project-level values from client ID
# Format: <random>-<hash>.apps.googleusercontent.com
# We don't have all Firebase fields, but google_sign_in only needs CLIENT_ID and REVERSED_CLIENT_ID

cat > "$IOS_PLIST" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CLIENT_ID</key>
	<string>${GOOGLE_CLIENT_ID_IOS}</string>
	<key>REVERSED_CLIENT_ID</key>
	<string>${GOOGLE_REVERSED_CLIENT_ID_IOS}</string>
	<key>BUNDLE_ID</key>
	<string>com.vael.vael</string>
</dict>
</plist>
PLIST

echo "  [OK] ios/Runner/GoogleService-Info.plist"

# ─── 2. Inject URL scheme into Info.plist (idempotent) ────────────────────────

INFO_PLIST="$ROOT/ios/Runner/Info.plist"

if grep -q "CFBundleURLTypes" "$INFO_PLIST" 2>/dev/null; then
  echo "  [SKIP] Info.plist already has CFBundleURLTypes"
else
  # Insert CFBundleURLTypes before the closing </dict></plist>
  # Using sed to insert before the last </dict>
  sed -i '' '/<\/dict>/{
    N
    /<\/plist>/i\
\	<key>CFBundleURLTypes</key>\
\	<array>\
\		<dict>\
\			<key>CFBundleTypeRole</key>\
\			<string>Editor</string>\
\			<key>CFBundleURLSchemes</key>\
\			<array>\
\				<string>'"${GOOGLE_REVERSED_CLIENT_ID_IOS}"'</string>\
\			</array>\
\		</dict>\
\	</array>
  }' "$INFO_PLIST"
  echo "  [OK] ios/Runner/Info.plist — added CFBundleURLTypes"
fi

# ─── 3. Generate Android key.properties (if signing values present) ───────────

ANDROID_KEY_PROPS="$ROOT/android/key.properties"

if [[ -n "${ANDROID_KEYSTORE_PASSWORD:-}" && "${ANDROID_KEYSTORE_PASSWORD}" != "" ]]; then
  cat > "$ANDROID_KEY_PROPS" << PROPS
storePassword=${ANDROID_KEYSTORE_PASSWORD}
keyPassword=${ANDROID_KEY_PASSWORD}
keyAlias=${ANDROID_KEY_ALIAS}
storeFile=${ANDROID_KEYSTORE_PATH}
PROPS
  echo "  [OK] android/key.properties"
else
  echo "  [SKIP] android/key.properties — no keystore password set (not needed for debug)"
fi

# ─── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "Bootstrap complete. Generated config files are gitignored."
echo ""
echo "macOS client ID is passed at build time:"
echo "  make run-macos"
echo "  # or: flutter run -d macos --dart-define=GOOGLE_CLIENT_ID_MACOS=\$GOOGLE_CLIENT_ID_MACOS"
