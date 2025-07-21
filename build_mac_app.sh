#!/bin/bash

set -e

# App name and paths
APP_NAME="QRPDFApp"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/bundle_app"
BACKEND_DIR="$APP_DIR/backend"
DIST_DIR="$APP_DIR/dist"
FINAL_APP_PATH="$DIST_DIR/$APP_NAME-darwin-universal/$APP_NAME.app"

echo "📦 Cleaning previous builds..."
rm -rf "$DIST_DIR" "$BACKEND_DIR"/{flask_server,build,dist,__pycache__}

echo "🐍 Building Flask backend binary with PyInstaller..."
cd "$BACKEND_DIR"
pyinstaller app.py --name flask_server --onefile --noconsole
cd "$ROOT_DIR"

echo "🚀 Packaging Electron app without icon..."
cd "$APP_DIR"
npm install
npx electron-packager . "$APP_NAME" \
  --platform=darwin \
  --arch=universal \
  --overwrite \
  --out=dist \
  --prune=true \
  --ignore="^/backend/app.py$" \
  --ignore="^/venv" \
  --ignore="^/build_app" \
  --ignore="^/build_mac_app.sh"

echo "🔓 Removing macOS quarantine metadata..."
xattr -dr com.apple.quarantine "$FINAL_APP_PATH"

echo "🗜️ Zipping the final .app..."
cd "$DIST_DIR/$APP_NAME-darwin-universal"
zip -r "${APP_NAME}.zip" "$APP_NAME.app"

echo "✅ Done!"
echo "📦 Final ZIP located at: $DIST_DIR/$APP_NAME-darwin-universal/${APP_NAME}.zip"
