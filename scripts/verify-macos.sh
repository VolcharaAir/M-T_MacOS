#!/bin/bash
# Verify every bundled native executable, including Flutter and plugin frameworks.
set -euo pipefail
app=${1:?Usage: bash scripts/verify-macos.sh PATH_TO_APP}
[[ -d "$app/Contents/MacOS" ]] || { echo "Not an app bundle: $app" >&2; exit 1; }
count=0
while IFS= read -r -d '' binary; do
  description=$(file -b "$binary")
  case "$description" in
    *Mach-O*)
      xcrun lipo "$binary" -verify_arch x86_64 arm64 || {
        echo "ERROR: missing Intel or Apple Silicon architecture: $binary" >&2
        exit 1
      }
      count=$((count + 1))
      ;;
  esac
done < <(find "$app" -type f -print0)
[[ "$count" -gt 0 ]] || { echo 'No Mach-O binaries found.' >&2; exit 1; }
codesign --verify --deep --strict --verbose=2 "$app"
echo "PASS: $count native binaries contain x86_64 and arm64; bundle signature verified."
