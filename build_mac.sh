#!/bin/bash
set -e
set -x  # Enable debug output

# Resolve paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
DIST_DIR="$PROJECT_ROOT/dist"
VENV_DIR="$PROJECT_ROOT/venv"
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
rm -rf "$VENV_DIR"
echo "[DEBUG] Cleaned previous build artifacts."

echo "[2] 🐍 Creating Python virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
echo "[DEBUG] Virtual environment activated."

echo "[3] 📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r "$PROJECT_ROOT/requirements.txt"

echo "[4] 🛠 Building Flask backend with PyInstaller..."
echo "$BACKEND_DIR"
cd "$BACKEND_DIR"
echo "[DEBUG] Running in: $(pwd)"
pyinstaller --onefile app.py --name flask_server
echo "[DEBUG] Flask server binary created at $BACKEND_DIR/dist/flask_server"

echo "[5] 🔐 Fixing Electron sandbox permissions..."
cd "$PROJECT_ROOT"
sudo chown root node_modules/electron/dist/chrome-sandbox
sudo chmod 4755 node_modules/electron/dist/chrome-sandbox
echo "[DEBUG] Set SUID sandbox permissions."

echo "[6] 📦 Packaging Electron app for macOS..."
npx electron-packager "$PROJECT_ROOT" "$APP_NAME" \
  --platform=darwin \
  --arch=universal \
  --out="$DIST_DIR" \
  --overwrite \
  --prune=true \
  --ignore="build_mac.sh" \
  --ignore="requirements.txt" \
  --ignore="app.spec" \
  --ignore="flask_server.spec" \
  --ignore="README.md" \
  --ignore="frontend"

echo "[7] ✅ Done. App available at: $DIST_DIR/${APP_NAME}-darwin-universal/${APP_NAME}.app"
