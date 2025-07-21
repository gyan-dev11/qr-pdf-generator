const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const { spawn } = require('child_process');

let pyProc = null;
let mainWindow = null;

// Toggle this to switch between Python script and PyInstaller binary
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
            console.log('[Electron] Frontend loaded.');
            mainWindow.webContents.openDevTools(); // Moved here
        })
        .catch(err => {
            console.error('[Electron] Failed to load frontend:', err);
        });
}

// Cross-platform Python path detection for virtual environment
function getPythonPath() {
    const isWindows = process.platform === 'win32';
    const pythonPath = isWindows
        ? path.join(__dirname, 'venv', 'Scripts', 'python.exe')
        : path.join(__dirname, 'venv', 'bin', 'python3');
    console.log(`[Electron] Detected Python path: ${pythonPath}`);
    return pythonPath;
}

function startFlask() {
    if (USE_PYINSTALLER_BINARY) {
        const pythonExecutable = path.join(__dirname, 'backend', 'flask_server');
        console.log(`[Electron] Starting Flask backend from binary: ${pythonExecutable}`);

        pyProc = spawn(pythonExecutable, {
            cwd: __dirname,
            shell: false,
        });
    } else {
        const script = path.join(__dirname, 'backend', 'app.py');
        const python = getPythonPath();
        console.log(`[Electron] Starting Flask backend from script: ${python} ${script}`);

        pyProc = spawn(python, [script], {
            cwd: __dirname,
            shell: false,
        });
    }

    pyProc.stdout.on('data', (data) => {
        console.log(`[Flask STDOUT]: ${data.toString()}`);
    });

    pyProc.stderr.on('data', (data) => {
        console.error(`[Flask STDERR]: ${data.toString()}`);
    });

    pyProc.on('error', (err) => {
        console.error('[Electron] Failed to start Flask process:', err);
    });

    pyProc.on('close', (code) => {
        console.log(`[Electron] Flask process exited with code ${code}`);
    });
}

// IPC: Folder selection
ipcMain.handle('dialog:selectFolder', async () => {
    console.log('[IPC] Folder dialog triggered');
    const result = await dialog.showOpenDialog({ properties: ['openDirectory'] });
    return result.canceled ? null : result.filePaths[0];
});

// IPC: File selection
ipcMain.handle('dialog:selectFile', async () => {
    console.log('[IPC] File dialog triggered');
    const result = await dialog.showOpenDialog({
        properties: ['openFile'],
        filters: [{ name: 'Images', extensions: ['png', 'jpg', 'jpeg'] }],
    });
    return result.canceled ? null : result.filePaths[0];
});

// App lifecycle
app.whenReady().then(() => {
    console.log('[Electron] App is ready');
    startFlask();
    createWindow();
});

app.on('window-all-closed', () => {
    if (pyProc) {
        console.log('[Electron] Killing Flask process...');
        pyProc.kill();
    }
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        console.log('[Electron] Re-creating window on activate');
        createWindow();
    }
});
