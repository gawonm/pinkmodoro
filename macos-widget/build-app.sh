#!/bin/bash
# Builds PinkmodoroWidget without Xcode: `swift build` via Swift Package Manager,
# then wraps the resulting binary in a minimal .app bundle (Info.plist + ad-hoc
# codesign). A bare `swift run` binary has no bundle identifier, which makes
# UNUserNotificationCenter unreliable - an .app bundle (even unsigned beyond
# ad-hoc) is what actually gets notifications working.
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="PinkmodoroWidget"
BUILD_DIR=".build/release"
APP_DIR=".build/${APP_NAME}.app"
BUNDLE_ID="com.pinkmodoro.widget"

echo "==> swift build -c release"
swift build -c release

echo "==> assembling ${APP_DIR}"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

cp "$BUILD_DIR/$APP_NAME" "$APP_DIR/Contents/MacOS/$APP_NAME"

if command -v sips >/dev/null 2>&1 && [ -f "Assets/AppIcon-1024.png" ]; then
  ICONSET="$APP_DIR/Contents/Resources/AppIcon.iconset"
  mkdir -p "$ICONSET"
  for size in 16 32 128 256 512; do
    sips -z "$size" "$size" Assets/AppIcon-1024.png --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
    double=$((size * 2))
    sips -z "$double" "$double" Assets/AppIcon-1024.png --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
  done
  iconutil -c icns "$ICONSET" -o "$APP_DIR/Contents/Resources/AppIcon.icns"
  rm -rf "$ICONSET"
fi

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>핑크모도로</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string></string>
</dict>
</plist>
PLIST

echo "==> ad-hoc codesign (needed for notifications to work reliably)"
codesign --force --deep --sign - "$APP_DIR"

echo "==> done: $APP_DIR"
echo "    open \"$APP_DIR\""
