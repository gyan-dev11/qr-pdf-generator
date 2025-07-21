const { app, BrowserWindow, dialog } = require('electron')
const path = require('path')
const { spawn } = require('child_process')
const http = require('http')

let pyProc = null

function startFlaskApp() {
  const script = path.join(__dirname, 'venv/bin/python3') // Adjust if bundled
  const appPath = path.join(__dirname, 'backend/app.py')

  console.log(`[DEBUG] Spawning Flask: ${script} ${appPath}`)

  pyProc = spawn(script, [appPath])

  pyProc.stdout.on('data', (data) => {
    console.log(`[Flask STDOUT]: ${data}`)
  })

  pyProc.stderr.on('data', (data) => {
    console.error(`[Flask STDERR]: ${data}`)
  })

  pyProc.on('error', (err) => {
    console.error('[ERROR] Failed to start Flask process:', err)
  })
}

function waitForFlaskReady(maxRetries = 10, delay = 1000) {
  return new Promise((resolve, reject) => {
    let attempts = 0

    const check = () => {
      http.get('http://127.0.0.1:5000', (res) => {
        if (res.statusCode === 200) {
          console.log('[✅] Flask is up and running.')
          resolve()
        } else {
          retry()
        }
      }).on('error', retry)
    }

    const retry = () => {
      if (++attempts >= maxRetries) {
        console.error('[❌] Flask server did not start in time.')
        reject()
      } else {
        console.log(`[⏳] Waiting for Flask... (${attempts}/${maxRetries})`)
        setTimeout(check, delay)
      }
    }

    check()
  })
}

function createWindow() {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  })

  win.loadURL('http://127.0.0.1:5000')
}

app.whenReady().then(async () => {
  startFlaskApp()

  try {
    await waitForFlaskReady()
    createWindow()
  } catch (err) {
    dialog.showErrorBox('Flask Error', 'Flask backend failed to start. Please try again or check logs.')
    app.quit()
  }
})

app.on('will-quit', () => {
  if (pyProc) pyProc.kill()
})
