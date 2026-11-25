#!/bin/bash
# Local testing package. Ad-hoc signing does not replace Apple notarization.
set -euo pipefail
cd "$(dirname "$0")/.."
root=$PWD
[[ "$(uname -s)" == Darwin ]] || { echo 'Build on macOS with Xcode installed.' >&2; exit 1; }
command -v flutter >/dev/null || {
  echo 'Flutter 3.50.1 is required. See docs/MACOS.md.' >&2; exit 1;
}
xcodebuild -version
xcrun --find lipo >/dev/null
export FLUTTER_SUPPRESS_ANALYTICS=true
flutter --version
flutter pub get
flutter analyze
flutter test
dart run tool/check.dart
flutter build macos --release
app="$root/build/macos/Build/Products/Release/M&T.app"
[[ -d "$app" ]] || { echo "Build did not produce $app" >&2; exit 1; }
# Re-sign after all build and copy operations. This needs no paid account.
codesign --force --deep --sign - \
  --entitlements macos/Runner/Release.entitlements "$app"
bash scripts/verify-macos.sh "$app"
mkdir -p dist
stage=$(mktemp -d "${TMPDIR:-/tmp}/mt-dmg.XXXXXX")
trap 'rm -rf "$stage"' EXIT
ditto "$app" "$stage/M&T.app"
ln -s /Applications "$stage/Applications"
cp docs/INSTALL-MACOS.txt "$stage/Установка.txt"
# Never replace the previous successful installer until creation succeeds.
temporary="$root/dist/MT-macOS-universal.new.dmg"
rm -f "$temporary"
hdiutil create -volname 'M&T' -srcfolder "$stage" -ov -format UDZO "$temporary"
hdiutil verify "$temporary"
mv -f "$temporary" "$root/dist/MT-macOS-universal.dmg"
(cd dist && shasum -a 256 MT-macOS-universal.dmg > MT-macOS-universal.dmg.sha256)
echo 'Ready: dist/MT-macOS-universal.dmg (Intel + Apple Silicon).'
echo 'Local testing build: ad-hoc signed, NOT notarized by Apple.'
echo 'Next: mount the DMG, install the app, and test with the network disconnected.'
