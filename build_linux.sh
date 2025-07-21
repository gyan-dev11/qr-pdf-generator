#!/bin/bash

set -e  # Exit on any error
set -x  # Enable debug mode to echo commands

# Resolve paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
DIST_DIR="$PROJECT_ROOT/dist"
APP_NAME="QRPDFApp"

echo "[DEBUG] Project root: $PROJECT_ROOT"
echo "[DEBUG] Backend dir: $BACKEND_DIR"
echo "[DEBUG] Frontend dir: $FRONTEND_DIR"
echo "[DEBUG] Dist dir: $DIST_DIR"
echo "[DEBUG] App name: $APP_NAME"

echo "[1] 🧹 Cleaning previous builds..."
rm -rf "$BACKEND_DIR/dist"
rm -rf "$PROJECT_ROOT/build"
rm -rf "$DIST_DIR"
rm -rf "$PROJECT_ROOT/${APP_NAME}-linux-x64"
echo "[DEBUG] Cleaned old build artifacts."

echo "[2] 🛠 Building Flask backend with PyInstaller..."
cd "$BACKEND_DIR"
echo "[DEBUG] Running in: $(pwd)"
pyinstaller --onefile app.py --name flask_server
echo "[DEBUG] Flask server binary created at $BACKEND_DIR/dist/flask_server"

echo "[3] 📦 Packaging Electron app for Linux..."
cd "$PROJECT_ROOT"
echo "[DEBUG] Running in: $(pwd)"

npx electron-packager "$PROJECT_ROOT" "$APP_NAME" \
  --platform=linux \
  --arch=x64 \
  --out="$DIST_DIR" \
  --overwrite \
  --prune=true \
  --ignore="build_mac_app.sh" \
  --ignore="build_linux.sh" \
  --ignore="requirements.txt" \
  --ignore="app.spec" \
  --ignore="flask_server.spec" \
  --ignore="README.md" \
  --ignore="frontend"
echo "[DEBUG] Electron app packaged at $DIST_DIR/${APP_NAME}-linux-x64"

echo "[4] ✅ Done. App available at: $DIST_DIR/${APP_NAME}-linux-x64/${APP_NAME}"
