#!/bin/bash
set -e

# Resolve paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
DIST_DIR="$PROJECT_ROOT/dist"
APP_NAME="QRPDFApp"

echo "[1] Cleaning previous builds..."
rm -rf "$BACKEND_DIR/dist"
rm -rf "$PROJECT_ROOT/build"
rm -rf "$DIST_DIR"
rm -rf "$PROJECT_ROOT/${APP_NAME}-darwin-universal"

echo "[2] Building Flask backend with PyInstaller..."
cd "$BACKEND_DIR"
pyinstaller --onefile app.py --name flask_server

echo "[3] Fixing Electron sandbox permissions..."
cd "$PROJECT_ROOT"
sudo chown root node_modules/electron/dist/chrome-sandbox
sudo chmod 4755 node_modules/electron/dist/chrome-sandbox

echo "[4] Packaging Electron app for macOS..."
npx electron-packager . $APP_NAME \
  --platform=darwin \
  --arch=universal \
  --out=dist \
  --overwrite \
  --prune=true \
  --ignore="build_mac_app.sh" \
  --ignore="requirements.txt" \
  --ignore="app.spec" \
  --ignore="flask_server.spec" \
  --ignore="README.md" \
  --ignore="frontend"

echo "[5] Done. App available at: dist/${APP_NAME}-darwin-universal/${APP_NAME}.app"
