const { app, BrowserWindow } = require('electron')
const path = require('path')
const { spawn } = require('child_process')

let pyProc = null

function createWindow () {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  })

  win.loadURL('http://127.0.0.1:5000') // Load Flask UI
}

function startFlaskApp () {
  const script = path.join(__dirname, 'venv/bin/python3')
  const appPath = path.join(__dirname, 'backend/app.py')

  pyProc = spawn(script, [appPath])

  pyProc.stdout.on('data', (data) => {
    console.log(`Flask: ${data}`)
  })

  pyProc.stderr.on('data', (data) => {
    console.error(`Flask Error: ${data}`)
  })
}

app.whenReady().then(() => {
  startFlaskApp()
  setTimeout(createWindow, 2000) // Wait for Flask to boot
})

app.on('will-quit', () => {
  if (pyProc) pyProc.kill()
})
