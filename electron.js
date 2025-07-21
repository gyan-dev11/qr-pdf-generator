const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const { spawn } = require('child_process');

let pyProc = null;
let mainWindow = null;

const USE_PYINSTALLER_BINARY = false;

function createWindow() {
    console.log('[Electron] Creating main window...');
    mainWindow = new BrowserWindow({
        width: 800,
        height: 600,
        webPreferences: {
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js'),
        },
    });

    mainWindow.loadFile(path.join(__dirname, 'frontend/index.html'))
        .then(() => {
            console.log('[Electron] Frontend loaded successfully.');
            mainWindow.webContents.openDevTools();
        })
        .catch(err => {
            console.error('[Electron] Failed to load frontend:', err);
        });

    mainWindow.on('closed', () => {
        console.log('[Electron] Main window closed.');
    });
}

function getPythonPath() {
    const isWindows = process.platform === 'win32';
    const pythonPath = isWindows
        ? path.join(__dirname, 'venv', 'Scripts', 'python.exe')
        : path.join(__dirname, 'venv', 'bin', 'python3');
    console.log(`[Electron] Detected Python path: ${pythonPath}`);
    return pythonPath;
}

function startFlask() {
    console.log('[Electron] Starting Flask backend...');

    if (USE_PYINSTALLER_BINARY) {
        const flaskBinary = path.join(__dirname, 'backend', 'flask_server');
        console.log(`[Electron] Using PyInstaller binary: ${flaskBinary}`);
        pyProc = spawn(flaskBinary, {
            cwd: __dirname,
            shell: false,
        });
    } else {
        const script = path.join(__dirname, 'backend', 'app.py');
        const python = getPythonPath();
        console.log(`[Electron] Using Python script: ${python} ${script}`);
        pyProc = spawn(python, [script], {
            cwd: __dirname,
            shell: false,
        });
    }

    pyProc.stdout.on('data', (data) => {
        console.log(`[Flask STDOUT]: ${data.toString().trim()}`);
    });

    pyProc.stderr.on('data', (data) => {
        console.error(`[Flask STDERR]: ${data.toString().trim()}`);
    });

    pyProc.on('error', (err) => {
        console.error('[Electron] ❌ Failed to start Flask process:', err);
    });

    pyProc.on('spawn', () => {
        console.log('[Electron] ✅ Flask process spawned successfully.');
    });

    pyProc.on('exit', (code, signal) => {
        console.log(`[Electron] Flask process exited with code ${code}, signal ${signal}`);
    });

    pyProc.on('close', (code) => {
        console.log(`[Electron] Flask process closed with code ${code}`);
    });
}

ipcMain.handle('dialog:selectFolder', async () => {
    console.log('[IPC] 📂 Folder dialog triggered');
    const result = await dialog.showOpenDialog({ properties: ['openDirectory'] });
    if (result.canceled) {
        console.log('[IPC] Folder selection canceled.');
        return null;
    } else {
        console.log(`[IPC] Folder selected: ${result.filePaths[0]}`);
        return result.filePaths[0];
    }
});

ipcMain.handle('dialog:selectFile', async () => {
    console.log('[IPC] 📄 File dialog triggered');
    const result = await dialog.showOpenDialog({
        properties: ['openFile'],
        filters: [{ name: 'Images', extensions: ['png', 'jpg', 'jpeg'] }],
    });
    if (result.canceled) {
        console.log('[IPC] File selection canceled.');
        return null;
    } else {
        console.log(`[IPC] File selected: ${result.filePaths[0]}`);
        return result.filePaths[0];
    }
});

app.whenReady().then(() => {
    console.log('[Electron] ✅ App is ready');
    startFlask();
    createWindow();
});

app.on('window-all-closed', () => {
    console.log('[Electron] All windows closed.');
    if (pyProc) {
        console.log('[Electron] 🔻 Terminating Flask process...');
        pyProc.kill();
    }
    if (process.platform !== 'darwin') {
        console.log('[Electron] Quitting app...');
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        console.log('[Electron] App re-activated. Re-creating main window...');
        createWindow();
    }
});
