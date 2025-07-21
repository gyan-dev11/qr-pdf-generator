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
ARCH="$(uname -m)"  # Will be x86_64 or arm64

echo "[DEBUG] Project root: $PROJECT_ROOT"
echo "[DEBUG] Backend dir: $BACKEND_DIR"
echo "[DEBUG] Frontend dir: $FRONTEND_DIR"
echo "[DEBUG] Dist dir: $DIST_DIR"
echo "[DEBUG] App name: $APP_NAME"
echo "[DEBUG] System architecture: $ARCH"

echo "[1] 🧹 Cleaning previous builds..."
rm -rf "$BACKEND_DIR/dist"
rm -rf "$PROJECT_ROOT/build"
rm -rf "$DIST_DIR"
rm -rf "$PROJECT_ROOT/${APP_NAME}-darwin-$ARCH"
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
echo "[DEBUG] Checking for app.py in: $BACKEND_DIR"
if [ ! -f "$BACKEND_DIR/app.py" ]; then
  echo "[ERROR] app.py not found in $BACKEND_DIR"
  exit 1
fi

cd "$BACKEND_DIR"
ls -l  # Show files to confirm app.py exists
pyinstaller --onefile app.py --name flask_server
echo "[DEBUG] Flask server binary created at $BACKEND_DIR/dist/flask_server"

echo "[5] 🔐 Fixing Electron sandbox permissions..."
cd "$PROJECT_ROOT"
if [ -f "node_modules/electron/dist/chrome-sandbox" ]; then
  sudo chown root node_modules/electron/dist/chrome-sandbox
  sudo chmod 4755 node_modules/electron/dist/chrome-sandbox
  echo "[DEBUG] Set SUID sandbox permissions."
else
  echo "[WARN] chrome-sandbox not found, skipping permission fix."
fi

echo "[6] 📦 Packaging Electron app for macOS..."
npx electron-packager "$PROJECT_ROOT" "$APP_NAME" \
  --platform=darwin \
  --arch="$ARCH" \
  --out="$DIST_DIR" \
  --overwrite \
  --prune=true \
  --ignore="build_mac.sh" \
  --ignore="build_linux.sh" \
  --ignore="build_windows.sh" \
  --ignore="requirements.txt" \
  --ignore="app.spec" \
  --ignore="flask_server.spec" \
  --ignore="backend/dist/flask_server" \
  --ignore="README.md" \
  # --ignore="frontend"

echo "[7] ✅ Done. App available at: $DIST_DIR/${APP_NAME}-darwin-$ARCH/${APP_NAME}.app"
