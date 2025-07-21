# 📄 QR to PDF Generator (macOS Desktop App)

**QRPDFApp** is a simple desktop app that converts a folder of QR code images into formatted PDF documents, with optional logo branding.

## 🖥 Features

- ✅ Select folder containing QR code images (PNG, JPG).
- ✅ Add an optional logo image to be included on each PDF.
- ✅ Choose output folder for saving the generated PDFs.
- ✅ One-click generation of PDFs from decoded QR content.

---

## 📦 How to Install & Run (macOS)

1. **Download the `.app` file**

   Save `QRPDFApp.app` to your Mac (e.g., in `Downloads`).

2. **Remove Security Quarantine**

   On macOS, apps not signed via Apple may show this error:

   > “QRPDFApp.app” is damaged and can’t be opened. You should move it to the Bin.

   **To fix it:**

   Open **Terminal** and run the following command:

   ```bash
   xattr -dr com.apple.quarantine ~/Downloads/QRPDFApp.app
