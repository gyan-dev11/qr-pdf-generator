#!/bin/bash
set -e

# Enable debug mode
set -x

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
rm -rf "$PROJECT_ROOT/${APP_NAME}-darwin-universal"
echo "[DEBUG] Cleaned previous build artifacts."

echo "[2] 🛠 Building Flask backend with PyInstaller..."
cd "$BACKEND_DIR"
echo "[DEBUG] Running in: $(pwd)"
pyinstaller --onefile app.py --name flask_server
echo "[DEBUG] Flask server binary created at $BACKEND_DIR/dist/flask_server"

echo "[3] 🔐 Fixing Electron sandbox permissions..."
cd "$PROJECT_ROOT"
echo "[DEBUG] Running in: $(pwd)"
sudo chown root node_modules/electron/dist/chrome-sandbox
sudo chmod 4755 node_modules/electron/dist/chrome-sandbox
echo "[DEBUG] Set SUID sandbox permissions."

echo "[4] 📦 Packaging Electron app for macOS..."
npx electron-packager "$PROJECT_ROOT" "$APP_NAME" \
  --platform=darwin \
  --arch=universal \
  --out="$DIST_DIR" \
  --overwrite \
  --prune=true \
  --ignore="build_mac_app.sh" \
  --ignore="requirements.txt" \
  --ignore="app.spec" \
  --ignore="flask_server.spec" \
  --ignore="README.md" \
  --ignore="frontend"
echo "[DEBUG] Electron app packaged."

echo "[5] ✅ Done. App available at: $DIST_DIR/${APP_NAME}-darwin-universal/${APP_NAME}.app"
