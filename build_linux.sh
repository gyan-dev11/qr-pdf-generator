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
rm -rf "$PROJECT_ROOT/${APP_NAME}-linux-x64"

echo "[2] Building Flask backend with PyInstaller..."
cd "$BACKEND_DIR"
pyinstaller --onefile app.py --name flask_server

echo "[3] Packaging Electron app for Linux..."
cd "$PROJECT_ROOT"

npx electron-packager . $APP_NAME \
  --platform=linux \
  --arch=x64 \
  --out=dist \
  --overwrite \
  --prune=true \
  --ignore="build_mac_app.sh" \
  --ignore="build_linux.sh" \
  --ignore="requirements.txt" \
  --ignore="app.spec" \
  --ignore="flask_server.spec" \
  --ignore="README.md" \
  --ignore="frontend"

echo "[4] Done. App available at: dist/${APP_NAME}-linux-x64/${APP_NAME}"
