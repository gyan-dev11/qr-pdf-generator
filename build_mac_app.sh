#!/bin/bash

set -e

# Define paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
DIST_DIR="$PROJECT_ROOT/dist"
APP_NAME="QRPDFApp"
APP_ZIP="$APP_NAME.zip"

echo "[1] Cleaning previous builds..."
rm -rf "$BACKEND_DIR/dist" "$BACKEND_DIR/build" "$BACKEND_DIR/__pycache__"
rm -rf "$DIST_DIR/$APP_NAME-darwin-universal"

echo "[2] Building Flask backend with PyInstaller..."
cd "$BACKEND_DIR"
pyinstaller app.py --name flask_server --onefile --distpath "$BACKEND_DIR/dist" --hidden-import flask

echo "[3] Copying binary to backend directory..."
cp "$BACKEND_DIR/dist/flask_server" "$BACKEND_DIR/flask_server"
chmod +x "$BACKEND_DIR/flask_server"

echo "[4] Packaging Electron app..."
cd "$PROJECT_ROOT"
npx electron-packager . "$APP_NAME" \
  --platform=darwin \
  --arch=universal \
  --out=dist \
  --overwrite \
  --prune=true \
  --ignore="^/venv" \
  --ignore="__pycache__" \
  --ignore=".*\.pyc" \
  --ignore=".*\.spec" \
  --ignore="/build_app" \
  --ignore="/dist"

echo "[5] Removing macOS quarantine attributes..."
xattr -dr com.apple.quarantine "$DIST_DIR/$APP_NAME-darwin-universal/$APP_NAME.app"

echo "[6] Zipping final .app..."
cd "$DIST_DIR/$APP_NAME-darwin-universal"
zip -r "$APP_ZIP" "$APP_NAME.app"

echo "✅ Build complete!"
echo "Final zip: $DIST_DIR/$APP_NAME-darwin-universal/$APP_ZIP"
