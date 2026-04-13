const { spawn, execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

function getScriptsPath() {
  // In production (packaged), scripts are in resources/scripts
  // In development, scripts are in project root/scripts
  const devPath = path.join(__dirname, '..', 'scripts');
  const prodPath = path.join(process.resourcesPath, 'scripts');
  return fs.existsSync(prodPath) ? prodPath : devPath;
}

let activeProcess = null;
let isCancelled = false;

function cancelActiveScripts() {
  isCancelled = true;
  if (activeProcess && activeProcess.pid) {
    try {
      execSync(`taskkill /PID ${activeProcess.pid} /T /F`, { encoding: 'utf8', stdio: 'ignore' });
    } catch (e) {
      console.error("Failed to kill powershell process: ", e.message);
    }
  }
}


function runScript(scriptPath, onProgress) {
  return new Promise((resolve) => {
    isCancelled = false;
    if (!fs.existsSync(scriptPath)) {
      resolve({ success: false, output: '', error: `Script not found: ${scriptPath}` });
      return;
    }

    const output = [];
    const errors = [];
    let progressLines = 0;
    let totalLines = 0;

    activeProcess = spawn('powershell.exe', [
      '-ExecutionPolicy', 'Bypass',
      '-NoProfile',
      '-NonInteractive',
      '-File', scriptPath
    ], {
      windowsHide: true
    });

    activeProcess.stdout.on('data', (data) => {
      const text = data.toString('utf8');
      const lines = text.split('\n').filter(l => l.trim());

      lines.forEach((line) => {
        output.push(line.trim());

        // Parse progress markers: [PROGRESS] 3/10
        const progressMatch = line.match(/\[PROGRESS\]\s*(\d+)\/(\d+)/);
        if (progressMatch) {
          progressLines = parseInt(progressMatch[1]);
          totalLines = parseInt(progressMatch[2]);
          if (onProgress) {
            onProgress({
              current: progressLines,
              total: totalLines,
              percent: Math.round((progressLines / totalLines) * 100),
              message: line.replace(/\[PROGRESS\]\s*\d+\/\d+\s*/, '').trim()
            });
          }
        }

        // Parse status messages: [INFO], [OK], [WARNING], [ERROR]
        const statusMatch = line.match(/\[(INFO|OK|WARNING|ERROR|DONE)\]\s*(.*)/);
        if (statusMatch && onProgress) {
          onProgress({
            current: progressLines,
            total: totalLines || 1,
            percent: totalLines ? Math.round((progressLines / totalLines) * 100) : -1,
            status: statusMatch[1],
            message: statusMatch[2].trim()
          });
        }
      });
    });

    activeProcess.stderr.on('data', (data) => {
      errors.push(data.toString('utf8'));
    });

    activeProcess.on('close', (code) => {
      activeProcess = null;
      if (isCancelled) {
        resolve({ success: false, output: output.join('\n') + '\n[❌ OPERAÇÃO CANCELADA PELO USUÁRIO]', error: '', exitCode: -1 });
      } else {
        resolve({
          success: code === 0,
          output: output.join('\n'),
          error: errors.join('\n'),
          exitCode: code
        });
      }
    });

    activeProcess.on('error', (err) => {
      activeProcess = null;
      resolve({
        success: false,
        output: output.join('\n'),
        error: err.message,
        exitCode: -1
      });
    });
  });
}

function checkIsCancelled() {
  return isCancelled;
}


module.exports = { runScript, getScriptsPath, cancelActiveScripts, checkIsCancelled };
