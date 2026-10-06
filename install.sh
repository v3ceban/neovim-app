#!/usr/bin/env sh
# Builds NeoVim.app from NeoVim.applescript and installs it into /Applications.
# Usage: ./install.sh (override the target with DEST=~/Applications ./install.sh)
set -eu

cd "$(dirname "$0")"

APP_NAME="NeoVim"
BUNDLE_ID="com.apple.automator.NeoVim" # same ID Automator would use for the app
DEST="${DEST:-/Applications}"
BUILD="build/$APP_NAME.app"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

for bin in /opt/homebrew/bin/tmux /opt/homebrew/bin/nvim; do
  [ -x "$bin" ] || echo "warning: $bin not found (brew install $(basename "$bin"))" >&2
done
[ -d /Applications/iTerm.app ] || echo "warning: iTerm.app not found in /Applications" >&2

rm -rf build && mkdir build
osacompile -o "$BUILD" NeoVim.applescript

plist="$BUILD/Contents/Info.plist"
plutil -replace CFBundleIdentifier -string "$BUNDLE_ID" "$plist"
plutil -replace LSUIElement -bool true "$plist" # no Dock icon while it runs
plutil -replace NSAppleEventsUsageDescription -string "NeoVim needs to control iTerm to open files." "$plist"

# Swap in our icon; without CFBundleIconName macOS uses the .icns instead of the droplet icon in Assets.car
cp icon.icns "$BUILD/Contents/Resources/droplet.icns"
plutil -remove CFBundleIconName "$plist"

# Editing Info.plist invalidates osacompile's ad-hoc signature
codesign --force --sign - "$BUILD"

rm -rf "${DEST:?}/$APP_NAME.app"
ditto "$BUILD" "$DEST/$APP_NAME.app"
"$LSREGISTER" -f "$DEST/$APP_NAME.app"

echo "Installed $DEST/$APP_NAME.app"
