const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const fs = require('fs');
const { runScript, getScriptsPath, cancelActiveScripts, checkIsCancelled } = require('./script-runner');

let mainWindow;
let introWindow;

function createIntroWindow() {
  introWindow = new BrowserWindow({
    width: 900,
    height: 600,
    frame: false,
    transparent: false,
    resizable: false,
    backgroundColor: '#0a0a0f',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true
    }
  });
  introWindow.loadFile(path.join(__dirname, '..', 'src', 'intro.html'));
  introWindow.setMenuBarVisibility(false);
}

function createMainWindow() {
  mainWindow = new BrowserWindow({
    width: 1280,
    height: 820,
    minWidth: 1024,
    minHeight: 700,
    frame: false,
    backgroundColor: '#0a0a0f',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true
    }
  });
  mainWindow.loadFile(path.join(__dirname, '..', 'src', 'index.html'));
  mainWindow.setMenuBarVisibility(false);
}

app.whenReady().then(() => {
  createIntroWindow();
});

app.on('window-all-closed', () => {
  app.quit();
});

// IPC: Intro finished, open main window
ipcMain.on('intro-finished', () => {
  if (introWindow) {
    introWindow.close();
    introWindow = null;
  }
  createMainWindow();
});

// IPC: Window controls
ipcMain.on('window-minimize', () => {
  if (mainWindow) mainWindow.minimize();
});
ipcMain.on('window-maximize', () => {
  if (mainWindow) {
    mainWindow.isMaximized() ? mainWindow.unmaximize() : mainWindow.maximize();
  }
});
ipcMain.on('window-close', () => {
  if (mainWindow) mainWindow.close();
});

// IPC: Run a PowerShell script
ipcMain.handle('run-script', async (event, scriptRelPath) => {
  const scriptPath = path.join(getScriptsPath(), scriptRelPath);
  return runScript(scriptPath, (progress) => {
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('script-progress', progress);
    }
  });
});

// IPC: Run multiple scripts sequentially
ipcMain.handle('run-scripts-batch', async (event, scriptPaths) => {
  const results = [];
  for (let i = 0; i < scriptPaths.length; i++) {
    if (checkIsCancelled()) break; // Break loop if cancelled midway
    const scriptPath = path.join(getScriptsPath(), scriptPaths[i]);
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('batch-progress', {
        current: i + 1,
        total: scriptPaths.length,
        scriptName: path.basename(scriptPaths[i], '.ps1')
      });
    }
    const result = await runScript(scriptPath, (progress) => {
      if (mainWindow && !mainWindow.isDestroyed()) {
        mainWindow.webContents.send('script-progress', progress);
      }
    });
    results.push(result);
  }
  return results;
});

// IPC: Check if restore point exists
ipcMain.handle('check-restore-point', async () => {
  const scriptPath = path.join(getScriptsPath(), 'backup', 'check-restore-point.ps1');
  const result = await runScript(scriptPath);
  return result.success;
});

// IPC: Get process list for Task Killer
ipcMain.handle('get-process-list', async () => {
  const scriptPath = path.join(getScriptsPath(), 'memory', 'task-killer.ps1');
  return runScript(scriptPath);
});

// IPC: Kill a process by PID
ipcMain.handle('kill-process', async (event, pid) => {
  return new Promise((resolve) => {
    const { execSync } = require('child_process');
    try {
      execSync(`taskkill /PID ${parseInt(pid)} /F`, { encoding: 'utf8' });
      resolve({ success: true });
    } catch (e) {
      resolve({ success: false, error: e.message });
    }
  });
});

// IPC: RollBack confirmation dialog
ipcMain.handle('confirm-rollback', async () => {
  const result = await dialog.showMessageBox(mainWindow, {
    type: 'warning',
    buttons: ['Cancelar', 'SIM, RESTAURAR'],
    defaultId: 0,
    cancelId: 0,
    title: 'Azucri-RollBack',
    message: 'TEM CERTEZA que deseja restaurar o sistema?',
    detail: 'O computador sera REINICIADO e todas as otimizacoes feitas pelo Azucrinaldo serao DESFEITAS. Esta acao nao pode ser interrompida apos iniciada.'
  });
  return result.response === 1;
});

// IPC: Check if running as Administrator
ipcMain.handle('is-admin', async () => {
  return new Promise((resolve) => {
    const { exec } = require('child_process');
    exec('net session', (err) => {
        resolve(!err);
    });
  });
});

// IPC: Cancel scripts
ipcMain.handle('cancel-scripts', () => {
  cancelActiveScripts();
  return true;
});

// IPC: Save Audit Log
ipcMain.handle('save-audit-log', async (event, logContent) => {
  try {
    const defaultPath = path.join(app.getPath('desktop'), 'Azucrinaldo_Auditoria.txt');
    const { filePath } = await dialog.showSaveDialog(mainWindow, {
      title: 'Salvar Arquivo de Auditoria',
      defaultPath: defaultPath,
      filters: [
        { name: 'Arquivos de Texto', extensions: ['txt'] }
      ]
    });
    
    if (filePath) {
      fs.writeFileSync(filePath, logContent, 'utf8');
      return { success: true, path: filePath };
    }
    return { success: false, cancelled: true };
  } catch (e) {
    return { success: false, error: e.message };
  }
});

// IPC: Run Native System Scanner
ipcMain.handle('run-scanner', async () => {
  const scriptPath = path.join(getScriptsPath(), 'scanner', 'system-scanner.ps1');
  return runScript(scriptPath);
});
