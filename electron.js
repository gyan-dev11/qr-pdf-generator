const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const { spawn } = require('child_process');

let pyProc = null;
let mainWindow = null;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  mainWindow.loadFile(path.join(__dirname, 'frontend/index.html'));
}

// Detect correct python binary inside venv (cross-platform)
function getPythonPath() {
  const isWindows = process.platform === 'win32';
  return isWindows
    ? path.join(__dirname, 'venv', 'Scripts', 'python.exe')
    : path.join(__dirname, 'venv', 'bin', 'python3');
}

function startFlask() {
  const script = path.join(__dirname, 'backend', 'app.py');
  const python = getPythonPath();

  console.log('Starting Flask:', python, script);

  pyProc = spawn(python, [script], {
    cwd: __dirname,
    shell: false,
  });

  pyProc.stdout.on('data', (data) => {
    console.log(`Flask: ${data}`);
  });

  pyProc.stderr.on('data', (data) => {
    console.error(`Flask Error: ${data}`);
  });

  pyProc.on('error', (err) => {
    console.error('Failed to start Flask process:', err);
  });

  pyProc.on('close', (code) => {
    console.log(`Flask exited with code ${code}`);
  });
}

// Handle file/folder selection using IPC
ipcMain.handle('dialog:selectFolder', async () => {
  const result = await dialog.showOpenDialog({ properties: ['openDirectory'] });
  return result.canceled ? null : result.filePaths[0];
});

ipcMain.handle('dialog:selectFile', async () => {
  const result = await dialog.showOpenDialog({
    properties: ['openFile'],
    filters: [{ name: 'Images', extensions: ['png', 'jpg', 'jpeg'] }],
  });
  return result.canceled ? null : result.filePaths[0];
});

app.whenReady().then(() => {
  startFlask();
  createWindow();
});

app.on('window-all-closed', () => {
  if (pyProc) pyProc.kill();
  if (process.platform !== 'darwin') app.quit();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});
