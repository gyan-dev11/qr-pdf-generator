## 📦 Build Instructions

### 🧠 Prerequisites

Install the following:

- Node.js and npm
- Python 3.10+
- PyInstaller (`pip install pyinstaller`)
- Electron Packager (`npm install -g electron-packager`)

---

### 🍏 macOS Build

```bash
cd qr-pdf-generator

chmod +x build_mac.sh
./build_mac.sh
````

If the `.app` is blocked on launch, run:

```bash
xattr -dr com.apple.quarantine dist/QRPDFApp-darwin-universal/QRPDFApp.app
```

Output:

```
dist/QRPDFApp-darwin-universal/QRPDFApp.app
```

---

### 🐧 Linux Build

```bash
cd qr-pdf-generator

chmod +x build_linux.sh
./build_linux.sh
```

To run the built app:

```bash
chmod +x dist/QRPDFApp-linux-x64/QRPDFApp
./dist/QRPDFApp-linux-x64/QRPDFApp
```

Output:

```
dist/QRPDFApp-linux-x64/
```

---

### 🪟 Windows Build

```bash
cd qr-pdf-generator

chmod +x build_windows.sh
./build_windows.sh
```

Run:

```
dist/QRPDFApp-win32-x64/QRPDFApp.exe
```

Note: For Windows builds, run the script on Windows (or WSL with Wine setup).

---

## 🛠️ Notes

* Electron communicates with the Flask backend, which is bundled using PyInstaller.
* Linux users may need to fix Electron's sandbox permissions:

```bash
sudo chown root node_modules/electron/dist/chrome-sandbox
sudo chmod 4755 node_modules/electron/dist/chrome-sandbox
```

---

## 📁 Output Summary

| Platform | Output                                        |
| -------- | --------------------------------------------- |
| macOS    | `dist/QRPDFApp-darwin-universal/QRPDFApp.app` |
| Linux    | `dist/QRPDFApp-linux-x64/QRPDFApp`            |
| Windows  | `dist/QRPDFApp-win32-x64/QRPDFApp.exe`        |

---


