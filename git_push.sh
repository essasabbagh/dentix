#!/bin/bash

# Exit on any error
set -e

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
