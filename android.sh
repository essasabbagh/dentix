#!/bin/bash

# Exit on any error
set -e

# inc version and build number , format code , fix lint issues
sh inc.sh

# Configuration
FIREBASE_APP_ID="1:63239:android:da88352"

# Build school flavor
DEBUG_DIR="build/debug-info"
mkdir -p $DEBUG_DIR

echo "Building..."
fvm flutter build appbundle \
	--release \
	--obfuscate \
	--split-debug-info=$DEBUG_DIR

echo "✅ Flutter builds completed."

echo "Uploading symbols..."

# Install Firebase CLI
# npm install -g firebase-tools

# Upload symbols to Firebase Crashlytics
firebase crashlytics:symbols:upload \
	--app=$FIREBASE_APP_ID \
	build/app/intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib

echo "🚀 Native symbols uploaded to Firebase Crashlytics."

# Deploy to Play Store and handle git operations
# cd android && fastlane deploy
# cd ..

# Path to the pubspec.yaml file
pubspec_file="pubspec.yaml"

# Get the version string from pubspec.yaml using grep and sed
version_string=$(grep -E "^\s*version:" "$pubspec_file" | sed -E 's/^\s*version:\s*(.+)\s*$/\1/')

# Split the version string into version name and build number
IFS='+' read -ra version_parts <<<"$version_string"
version_name="${version_parts[0]}"
build_number="${version_parts[1]}"

# Set your commit message
COMMIT_MESSAGE="Update Android Version:$version_name | Build number: $build_number"

echo "$COMMIT_MESSAGE"
# Add and commit changes
# git add $pubspec_file
git add .
git commit -m "$COMMIT_MESSAGE"

# Push changes to GitHub
git push
git push origin main

echo "✅ All done! Your app is deployed to the Play Store and git operations are completed."
