const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('azucri', {
  // Window controls
  minimize: () => ipcRenderer.send('window-minimize'),
  maximize: () => ipcRenderer.send('window-maximize'),
  close: () => ipcRenderer.send('window-close'),

  // Intro
  introFinished: () => ipcRenderer.send('intro-finished'),

  // License
  checkLicense: () => ipcRenderer.invoke('check-license'),
  activateLicense: (key) => ipcRenderer.invoke('activate-license', key),
  getTrialRemaining: () => ipcRenderer.invoke('get-trial-remaining'),
  getHwId: () => ipcRenderer.invoke('get-hwid'),
  continueTrial: () => ipcRenderer.send('continue-trial'),

  // Script execution
  runScript: (scriptPath) => ipcRenderer.invoke('run-script', scriptPath),
  runScriptsBatch: (scriptPaths) => ipcRenderer.invoke('run-scripts-batch', scriptPaths),
  cancelScripts: () => ipcRenderer.invoke('cancel-scripts'),

  // Logging & Auditing
  saveAuditLog: (content) => ipcRenderer.invoke('save-audit-log', content),

  // Backup
  checkRestorePoint: () => ipcRenderer.invoke('check-restore-point'),

  // Task Killer
  getProcessList: () => ipcRenderer.invoke('get-process-list'),
  killProcess: (pid) => ipcRenderer.invoke('kill-process', pid),

  // RollBack
  confirmRollback: () => ipcRenderer.invoke('confirm-rollback'),

  // Security
  isAdmin: () => ipcRenderer.invoke('is-admin'),

  // Scanner
  runScanner: () => ipcRenderer.invoke('run-scanner'),

  // Progress listeners
  onScriptProgress: (callback) => ipcRenderer.on('script-progress', (_, data) => callback(data)),
  onBatchProgress: (callback) => ipcRenderer.on('batch-progress', (_, data) => callback(data)),

  // Remove listeners
  removeAllListeners: (channel) => ipcRenderer.removeAllListeners(channel)
});

