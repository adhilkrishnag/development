#!/bin/bash

# Update version in pubspec.yaml (increment only the patch version)
file="pubspec.yaml"
version=$(grep -E '^version:' "$file" | awk '{print $2}')

if [[ $version =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)(\+[0-9]+)?$ ]]; then
  major=${BASH_REMATCH[1]}
  minor=${BASH_REMATCH[2]}
  patch=${BASH_REMATCH[3]}
  build=${BASH_REMATCH[4]:+${BASH_REMATCH[4]}}  # Preserve build number if it exists

  new_patch=$((patch + 1))
  new_version="$major.$minor.$new_patch"

  sed -i -E "s/^version: [0-9]+\.[0-9]+\.[0-9]+/version: $new_version/" "$file"
  echo "✅ Updated version to $new_version"
else
  echo "❌ Error: Could not parse version number correctly."
  exit 1
fi

# Update service worker cache version
sw_file="web/service_worker.js"

# Extract the current cache version (Fixing multi-line issue)
ver=$(grep -oE "cryptocache-v[0-9]+" "$sw_file" | grep -oE "[0-9]+" | tail -n 1 || echo "")

if [[ -n "$ver" && "$ver" =~ ^[0-9]+$ ]]; then
  new_version=$((ver + 1))
  sed -i "s/cryptocache-v$ver/cryptocache-v$new_version/g" "$sw_file"
  echo "✅ Cache version updated from $ver to $new_version in $sw_file"
else
  echo "⚠️ Could not find a valid cache version in $sw_file"
fi

# Run Flutter clean & pub get
flutter clean
flutter pub get

# Build your Flutter web project
flutter build web --release --pwa-strategy=none

# Path to flutter_bootstrap.js
BOOTSTRAP_FILE="build/web/flutter_bootstrap.js"

# Check if the file exists and modify service worker reference
if [ -f "$BOOTSTRAP_FILE" ]; then
  sed -i "s/flutter_service_worker.js/service_worker.js/g" "$BOOTSTRAP_FILE"
  echo "✅ Replaced flutter_service_worker.js with service_worker.js"
else
  echo "⚠️ flutter_bootstrap.js not found!"
fi

echo "🚀 Build process completed successfully!"
