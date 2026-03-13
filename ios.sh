#!/bin/bash

# ============================================
# 🚨 Exit immediately on any error
set -e

# ============================================
# 🔧 Pre-build: increment version/build number, format, fix lint
if [ -f "inc.sh" ]; then
	echo "🔧 Running pre-build script..."
	sh inc.sh
fi

# ============================================
# 📂 Setup build directories
IOS_DEBUG_DIR="build/ios_debug_info"
mkdir -p "$IOS_DEBUG_DIR"

ARCHIVE_PATH="build/ios/archive/Runner.xcarchive"
APP_PATH="$ARCHIVE_PATH/Products/Applications/Runner.app"
DSYM_PATH="$ARCHIVE_PATH/dSYMs"
IPA_PATH="build/ios/ipa/Runner.ipa"

# ============================================
# 🧱 Build iOS release (no flavor)
echo "🚧 Building iOS release..."

fvm flutter build ipa \
	--release \
	--obfuscate \
	--split-debug-info="$IOS_DEBUG_DIR" \
	-t lib/main.dart

echo "✅ iOS release build completed."

# ============================================
# ☁️ Upload dSYMs to Firebase Crashlytics
if [ -f "ios/Pods/FirebaseCrashlytics/upload-symbols" ]; then
	echo "☁️ Uploading dSYMs to Firebase Crashlytics..."
	ios/Pods/FirebaseCrashlytics/upload-symbols \
		-gsp ios/Runner/GoogleService-Info.plist \
		-p ios \
		"$DSYM_PATH" \
		--skip-dsym-validation

	echo "🔍 Verifying dSYM UUIDs..."
	find "$DSYM_PATH" -name "*.dSYM" | while read -r dsym; do
		echo "  → Checking $(basename "$dsym")"
		dwarfdump --uuid "$dsym" || echo "⚠️ No symbols found in $(basename "$dsym")"
	done

	echo "✅ dSYM upload to Firebase Crashlytics completed."
else
	echo "⚠️ FirebaseCrashlytics upload-symbols tool not found — skipping symbol upload."
fi

# ============================================
# 🚀 Upload to App Store / TestFlight via App Store Connect
echo "🚀 Uploading .ipa to App Store Connect..."

# Replace these with your actual credentials
API_KEY=""
API_ISSUER="efc3-1fca-4479-90ba-0dfc8"

xcrun altool --upload-app \
	--type ios \
	-f "$IPA_PATH" \
	--apiKey "$API_KEY" \
	--apiIssuer "$API_ISSUER"

echo "✅ Upload to App Store Connect completed."

# ============================================
# 🧩 Git commit & push version update (inline, replaces git_push.sh)
echo "📦 Preparing Git commit for version update..."

# Path to the pubspec.yaml file
pubspec_file="pubspec.yaml"

# Get the version string from pubspec.yaml using grep and sed
version_string=$(grep -E "^\s*version:" "$pubspec_file" | sed -E 's/^\s*version:\s*(.+)\s*$/\1/')

# Split the version string into version name and build number
IFS='+' read -ra version_parts <<<"$version_string"
version_name="${version_parts[0]}"
build_number="${version_parts[1]}"

# Commit message
COMMIT_MESSAGE="Update iOS Version: $version_name | Build number: $build_number"

echo "$COMMIT_MESSAGE"

# Add all modified files and commit
git add .
git commit -m "$COMMIT_MESSAGE" || echo "⚠️ No changes to commit."

# Push to main branch
echo "📤 Pushing to GitHub..."
git push
git push origin main

echo "✅ Git push completed."

# ============================================
echo "🎉 All done! iOS build, symbol upload, App Store deploy, and git push completed successfully."
