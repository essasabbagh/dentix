#!/bin/bash

# sh inc.sh

# fvm flutter build apk --split-per-abi

# set -euo pipefail
# ============================================
# 🚨 Exit immediately on any error
set -e

# ============================================
# 🔧 Pre-build: increment version/build number, format, fix lint
# Run pre-build script
sh inc.sh

# ============================================
# Build Flutter APKs
fvm flutter build apk --release --split-per-abi

# Paths to APKs
APK_DIR="build/app/outputs/flutter-apk"
APKS=(
	"$APK_DIR/app-armeabi-v7a-release.apk"
	"$APK_DIR/app-arm64-v8a-release.apk"
	"$APK_DIR/app-x86_64-release.apk"
)

# Google Drive remote folder
REMOTE="gdrive:folder-name"

echo "=== Cleaning old files from Google Drive folder: $REMOTE ==="
rclone delete "$REMOTE" --drive-use-trash=false --progress

echo "=== Uploading new APKs to $REMOTE ==="
for apk in "${APKS[@]}"; do
	echo "Uploading: $apk"
	rclone copy "$apk" "$REMOTE" --progress
done

echo "=== Done! All APKs uploaded successfully to $REMOTE ==="
