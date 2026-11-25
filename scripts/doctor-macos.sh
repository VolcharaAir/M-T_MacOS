#!/bin/bash
# Read-only inventory; intentionally continues when an optional tool is absent.
set -u
echo '=== macOS ==='
sw_vers
uname -m
echo '=== Selected Xcode ==='
xcode-select -p
xcodebuild -version
echo '=== Flutter ==='
if command -v flutter >/dev/null; then
  flutter --version
  flutter doctor -v
else
  echo 'Flutter is not in PATH.'
fi
echo '=== CocoaPods (fallback for plugins without Swift Package Manager) ==='
if command -v pod >/dev/null; then pod --version; else echo 'CocoaPods is not in PATH.'; fi
