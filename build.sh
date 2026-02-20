#!/bin/bash
set -e

APP_NAME="cave"
APP_BUNDLE="build/${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"

echo "🔨 Building..."
swift build -c release 2>&1

echo "📦 Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "${CONTENTS}/MacOS"
mkdir -p "${CONTENTS}/Resources"

cp ".build/release/${APP_NAME}" "${CONTENTS}/MacOS/${APP_NAME}"
cp "Info.plist" "${CONTENTS}/"
cp "Resources/cave.icns" "${CONTENTS}/Resources/"

echo -n "APPL????" > "${CONTENTS}/PkgInfo"

echo "✅ Build complete: ${APP_BUNDLE}"
echo "   Run: open \"${APP_BUNDLE}\""
