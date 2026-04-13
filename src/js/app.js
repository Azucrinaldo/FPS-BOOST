/**
 * Azucrinaldo BOOST FPS — Main Application Controller
 */
document.addEventListener('DOMContentLoaded', () => {
  // ========================================
  // ELEMENTS
  // ========================================
  const backupStatus = document.getElementById('backup-status');
  const backupText = document.getElementById('backup-text');
  const btnCreateBackup = document.getElementById('btn-create-backup');
  const progressOverlay = document.getElementById('progress-overlay');
  const progressTitle = document.getElementById('progress-title');
  const progressPercent = document.getElementById('progress-percent');
  const progressBarFill = document.getElementById('progress-bar-fill');
  const progressMessage = document.getElementById('progress-message');
  const progressBatchInfo = document.getElementById('progress-batch-info');
  const resultLog = document.getElementById('result-log');
  const taskKillerOverlay = document.getElementById('task-killer-overlay');
  const taskKillerClose = document.getElementById('task-killer-close');
  const processTbody = document.getElementById('process-tbody');

  // Danger Modal Elements
  const dangerModalOverlay = document.getElementById('danger-modal-overlay');
  const btnDangerCancel = document.getElementById('btn-danger-cancel');
  const btnDangerExecute = document.getElementById('btn-danger-execute');
  const dangerAcceptChk = document.getElementById('danger-accept-chk');

  // Selection Modal Elements
  const selectionModalOverlay = document.getElementById('selection-modal-overlay');
  const selectionModalTitle = document.getElementById('selection-modal-title');
  const selectionModalClose = document.getElementById('selection-modal-close');
  const btnSelectAll = document.getElementById('btn-select-all');
  const btnSelectNone = document.getElementById('btn-select-none');
  const selectionList = document.getElementById('selection-list');
  const btnExecuteSelection = document.getElementById('btn-execute-selection');

  // Cancel & Logs Elements
  const btnCancelProgress = document.getElementById('btn-cancel-progress');
  const btnSaveAudit = document.getElementById('btn-save-audit');
  const resultLogContent = document.getElementById('result-log-content');
  const btnThemeToggle = document.getElementById('btn-theme-toggle');

  let backupExists = false;
  let isRunning = false;
  let accumulatedLogs = "";

  // ========================================
  // WINDOW CONTROLS & THEME
  // ========================================
  document.getElementById('btn-minimize').addEventListener('click', () => window.azucri.minimize());
  document.getElementById('btn-maximize').addEventListener('click', () => window.azucri.maximize());
  document.getElementById('btn-close').addEventListener('click', () => window.azucri.close());

  btnThemeToggle.addEventListener('click', () => {
    document.body.classList.toggle('light-theme');
    const isLight = document.body.classList.contains('light-theme');
    btnThemeToggle.textContent = isLight ? '☾' : '❂';
  });

  // ========================================
  // MODULE DEFINITIONS
  // ========================================
  const modules = {
    'pro-max': {
      scripts: [
        'backup/create-restore-point.ps1',
        'bloatware/remove-bloatware.ps1',
        'ai-removal/remove-copilot.ps1',
        'ai-removal/remove-recall.ps1',
        'ai-removal/disable-ai-telemetry.ps1',
        'services/disable-services.ps1',
        'registry/gaming-registry.ps1',
        'registry/input-lag-fix.ps1',
        'registry/privacy-registry.ps1',
        'memory/clear-standby-list.ps1',
        'memory/clear-ram-cache.ps1',
        'disk/clean-temp-files.ps1',
        'disk/clean-prefetch.ps1',
        'disk/disk-optimization.ps1',
        'power/ultimate-power-plan.ps1',
        'power/disable-usb-suspend.ps1',
        'network/network-optimization.ps1',
        'network/disable-throttling.ps1'
      ]
    },
    'danger-boost': {
      scripts: ['extreme/danger-boost.ps1']
    },
    'bloatware': {
      scripts: ['bloatware/remove-bloatware.ps1']
    },
    'ai-removal': {
      scripts: [
        'ai-removal/remove-copilot.ps1',
        'ai-removal/remove-recall.ps1',
        'ai-removal/disable-ai-telemetry.ps1'
      ]
    },
    'services': {
      scripts: ['services/disable-services.ps1']
    },
    'registry': {
      scripts: [
        'registry/gaming-registry.ps1',
        'registry/input-lag-fix.ps1',
        'registry/privacy-registry.ps1'
      ]
    },
    'memory': {
      scripts: [
        'memory/clear-standby-list.ps1',
        'memory/clear-ram-cache.ps1'
      ]
    },
    'disk': {
      scripts: [
        'disk/clean-temp-files.ps1',
        'disk/clean-prefetch.ps1',
        'disk/disk-optimization.ps1'
      ]
    },
    'power': {
      scripts: [
        'power/ultimate-power-plan.ps1',
        'power/disable-usb-suspend.ps1'
      ]
    },
    'network': {
      scripts: [
        'network/network-optimization.ps1',
        'network/disable-throttling.ps1'
      ]
    }
  };

  const scriptMeta = {
    'backup/create-restore-point.ps1': { name: 'Criar Ponto de Restauração', desc: 'Gera um backup de segurança do sistema.' },
    'bloatware/remove-bloatware.ps1': { name: 'Remover Apps Pré-Instalados', desc: 'Desinstala aplicativos inúteis do Windows como Xbox, Solitaire, Weather, Clipchamp, etc.' },
    'ai-removal/remove-copilot.ps1': { name: 'Exterminar Copilot', desc: 'Remove o Microsoft Copilot profundamente do sistema.' },
    'ai-removal/remove-recall.ps1': { name: 'Exterminar Windows Recall', desc: 'Desativa o recurso de espionagem fotográfica Recall.' },
    'ai-removal/disable-ai-telemetry.ps1': { name: 'Desativar Telemetria de IA', desc: 'Bloqueia relatórios de rastreamento enviados silenciosamente aos servidores da IA.' },
    'services/disable-services.ps1': { name: 'Otimização de Serviços', desc: 'Desabilita dezenas de serviços que rodam em segundo plano consumindo CPU e RAM.' },
    'registry/gaming-registry.ps1': { name: 'Injeção de Registro Gaming', desc: 'Aplica prioridade máxima de processamento e GPU exclusivamente para jogos.' },
    'registry/input-lag-fix.ps1': { name: 'Mitigação de Input Lag', desc: 'Ajusta propriedades na fila do Mouse e Teclado para tempo de resposta nulo (1ms).' },
    'registry/privacy-registry.ps1': { name: 'Privacidade Extrema', desc: 'Desliga coleta de dados por hard-code, telemetria e o irritante Game DVR.' },
    'memory/clear-standby-list.ps1': { name: 'Limpeza de Standby List', desc: 'Libera espaço "preso" na memória cache para não gargalar aplicações novas.' },
    'memory/clear-ram-cache.ps1': { name: 'Desfragmentação de Memória RAM', desc: 'Reduz o uso da memória alocada vazia melhorando estabilidade do SO.' },
    'disk/clean-temp-files.ps1': { name: 'Limpar Arquivos Temporários', desc: 'Varre e destrói lixo digital no AppData e Windows/Temp.' },
    'disk/clean-prefetch.ps1': { name: 'Limpar Prefetch', desc: 'Apaga histórico de abertura de programas que o sistema guarda desnecessariamente.' },
    'disk/disk-optimization.ps1': { name: 'Forçar TRIM no Disco', desc: 'Habilita recursos de otimização nativos para SSD e NVMe.' },
    'power/ultimate-power-plan.ps1': { name: 'Plano E-Sports Force', desc: 'Desbloqueia e ativa o limite oculto de performance de energia do núcleo do CPU.' },
    'power/disable-usb-suspend.ps1': { name: 'Desativar Suspensão de USB', desc: 'Impede a placa-mãe de desligar as portas USB, evitando que o mouse desligue do nada.' },
    'network/network-optimization.ps1': { name: 'Otimização de Pacotes Ethernet', desc: 'Desativa algoritmos de Nagle para ter hit-reg instantâneo nos multiplayers.' },
    'network/disable-throttling.ps1': { name: 'Remover Throttling do Roteador', desc: 'Força o sistema a puxar 100% livremente da banda disponível sem limitar picos.' },
    'extreme/danger-boost.ps1': { name: 'Danger: Kernel Modifications', desc: 'Desliga defesas cruciais e proteção DMA focando brutalmente na performance.' }
  };

  // ========================================
  // BACKUP CHECK
  // ========================================
  async function checkBackup() {
    try {
      const exists = await window.azucri.checkRestorePoint();
      backupExists = exists;
      if (exists) {
        backupStatus.className = 'backup-status ok';
        backupText.textContent = '✅ Ponto de restauração encontrado. Todos os módulos desbloqueados.';
        btnCreateBackup.style.display = 'none';
        enableAllCards();
      } else {
        backupStatus.className = 'backup-status warning';
        backupText.textContent = '⚠️ Nenhum ponto de restauração encontrado. Crie um backup antes de otimizar.';
        btnCreateBackup.style.display = 'inline-flex';
        disableAllCards();
      }
    } catch (e) {
      // Assume no backup in dev/error
      backupStatus.className = 'backup-status warning';
      backupText.textContent = '⚠️ Crie um ponto de restauração antes de usar os módulos.';
      btnCreateBackup.style.display = 'inline-flex';
      disableAllCards();
    }
  }

  function enableAllCards() {
    document.querySelectorAll('.module-card').forEach(card => {
      if (!card.classList.contains('optimized')) {
        card.classList.remove('disabled');
      }
    });
  }

  function disableAllCards() {
    document.querySelectorAll('.module-card').forEach(card => {
      if (card.id !== 'card-rollback') {
        card.classList.add('disabled');
      }
    });
    // Rollback is always enabled if backup exists
    const rollback = document.getElementById('card-rollback');
    if (rollback) rollback.classList.add('disabled');
  }

  // ========================================
  // CREATE BACKUP
  // ========================================
  btnCreateBackup.addEventListener('click', async () => {
    if (isRunning) return;
    isRunning = true;
    btnCreateBackup.disabled = true;
    btnCreateBackup.textContent = '⏳ Criando backup...';

    showProgress('CRIANDO PONTO DE RESTAURAÇÃO', 'Isso pode levar alguns segundos...');

    const result = await window.azucri.runScript('backup/create-restore-point.ps1');

    hideProgress();
    isRunning = false;

    if (result.success) {
      backupExists = true;
      backupStatus.className = 'backup-status ok';
      backupText.textContent = '✅ Backup criado com sucesso! Módulos desbloqueados.';
      btnCreateBackup.style.display = 'none';
      enableAllCards();
      showLog(result.output, 'ok');
    } else {
      backupStatus.className = 'backup-status error';
      backupText.textContent = '❌ Erro ao criar backup. Execute o app como Administrador.';
      btnCreateBackup.disabled = false;
      btnCreateBackup.textContent = '🛡️ CRIAR BACKUP AGORA';
      showLog(result.error || result.output, 'error');
    }
  });

  // ========================================
  // SCANNER PRO LAB
  // ========================================
  const btnScanner = document.getElementById('btn-scanner');
  if (btnScanner) {
    btnScanner.addEventListener('click', async () => {
      if (isRunning) return;
      isRunning = true;
      btnScanner.classList.add('scanning');
      btnScanner.innerHTML = `<span class="btn-icon">📡</span> VARRENDO O SISTEMA...`;
      
      showProgress('SCANNER PRO LAB', 'Analisando chaves de registro e estado do Kernel...');
      
      const result = await window.azucri.runScanner();
      
      let payload = null;
      try {
        // Strip everything from output that is not the JSON string starting with {
        const jsonMatch = result.output.match(/\{[\s\S]*\}/);
        if (jsonMatch) payload = JSON.parse(jsonMatch[0]);
      } catch (e) {
        showLog('Ocorreu um erro ao interpretar o Scanner Pro Lab: ' + (result.error || e.message), 'error');
      }

      if (payload) {
        // Parse and lock cards
        Object.keys(payload).forEach(key => {
          const isOptimized = payload[key];
          const card = document.querySelector(`.module-card[data-module="${key}"]`);
          if (card) {
             if (isOptimized) {
                card.classList.add('optimized', 'disabled');
             } else {
                card.classList.remove('optimized');
                if (backupExists && card.id !== 'card-rollback') card.classList.remove('disabled');
             }
          }
        });
        showLog('Varredura Pro Lab concluída com sucesso. Os módulos que já estão Otimizados foram bloqueados na Interface.', 'info');
      } else if (!result.success) {
         showLog(result.error || result.output, 'error');
      }
      
      hideProgress();
      btnScanner.classList.remove('scanning');
      btnScanner.innerHTML = `<span class="btn-icon">📡</span> SCANNER PRO LAB`;
      isRunning = false;
    });
  }

  // ========================================
  // MODULE CLICK HANDLERS
  // ========================================
  document.querySelectorAll('.module-card').forEach(card => {
    card.addEventListener('click', async () => {
      if (card.classList.contains('disabled') || isRunning) return;

      const moduleId = card.dataset.module;

      // Special: Task Killer
      if (moduleId === 'task-killer') {
        openTaskKiller();
        return;
      }

      // Special: RollBack
      if (moduleId === 'rollback') {
        handleRollback();
        return;
      }

      // Special: Danger Boost
      if (moduleId === 'danger-boost') {
        openDangerModal();
        return;
      }

      // Open Selection Modal for regular modules
      openSelectionModal(moduleId, card.querySelector('.card-title').textContent);
    });
  });

  // ========================================
  // SELECTION MODAL LOGIC
  // ========================================
  let currentSelectionModule = null;

  function openSelectionModal(moduleId, title) {
    const mod = modules[moduleId];
    if (!mod) return;

    currentSelectionModule = { title, scripts: mod.scripts };
    selectionModalTitle.textContent = title;
    selectionList.innerHTML = '';

    mod.scripts.forEach((scriptPath, index) => {
      const meta = scriptMeta[scriptPath] || { name: scriptPath.split('/').pop(), desc: 'Nenhuma descrição fornecida.' };
      
      const div = document.createElement('label');
      div.className = 'selection-item';
      div.innerHTML = `
        <div class="checkbox-wrapper">
          <input type="checkbox" value="${index}" checked>
        </div>
        <div class="selection-item-info">
          <div class="selection-item-name">${meta.name}</div>
          <div class="selection-item-desc">${meta.desc}</div>
        </div>
      `;
      selectionList.appendChild(div);
    });

    selectionModalOverlay.classList.add('active');
  }

  selectionModalClose.addEventListener('click', () => {
    selectionModalOverlay.classList.remove('active');
  });

  btnSelectAll.addEventListener('click', () => {
    selectionList.querySelectorAll('input[type="checkbox"]').forEach(c => c.checked = true);
  });

  btnSelectNone.addEventListener('click', () => {
    selectionList.querySelectorAll('input[type="checkbox"]').forEach(c => c.checked = false);
  });

  btnExecuteSelection.addEventListener('click', () => {
    const checkboxes = Array.from(selectionList.querySelectorAll('input[type="checkbox"]'));
    const selectedScripts = checkboxes
      .filter(c => c.checked)
      .map(c => currentSelectionModule.scripts[parseInt(c.value)]);

    if (selectedScripts.length === 0) {
      alert("Selecione pelo menos um script para iniciar.");
      return;
    }

    selectionModalOverlay.classList.remove('active');
    accumulatedLogs = `--- AUDITORIA: ${currentSelectionModule.title} ---\nData: ${new Date().toLocaleString()}\n`;
    executeSelectedScripts(selectedScripts, currentSelectionModule.title);
  });

  // ========================================
  // EXECUTION CORE
  // ========================================
  async function executeSelectedScripts(scriptsToRun, title) {
    isRunning = true;

    if (scriptsToRun.length === 1) {
      showProgress(title, 'Iniciando...');
      const result = await window.azucri.runScript(scriptsToRun[0]);
      hideProgress();
      const logLine = result.output + (result.error ? '\n' + result.error : '');
      accumulatedLogs += logLine;
      showLog(logLine, result.success ? 'ok' : 'error');
    } else {
      showProgress(title, 'Executando múltiplos scripts...');
      const results = await window.azucri.runScriptsBatch(scriptsToRun);
      hideProgress();
      const allOutput = results.map((r, i) => {
        const name = scriptsToRun[i].split('/').pop();
        const status = r.success ? '✅' : '❌';
        return `${status} ${name}\n${r.output}${r.error ? '\n' + r.error : ''}`;
      }).join('\n─────────────────────\n');
      const allSuccess = results.every(r => r.success);
      accumulatedLogs += allOutput;
      showLog(allOutput, allSuccess ? 'ok' : 'error');
    }

    isRunning = false;
  }

  // ========================================
  // DANGER MODAL LOGIC
  // ========================================
  function openDangerModal() {
    dangerAcceptChk.checked = false;
    btnDangerExecute.disabled = true;
    dangerModalOverlay.classList.add('active');
  }

  dangerAcceptChk.addEventListener('change', (e) => {
    btnDangerExecute.disabled = !e.target.checked;
  });

  btnDangerCancel.addEventListener('click', () => {
    dangerModalOverlay.classList.remove('active');
  });

  btnDangerExecute.addEventListener('click', () => {
    dangerModalOverlay.classList.remove('active');
    accumulatedLogs = `--- AUDITORIA: BIOHAZARD ---\nData: ${new Date().toLocaleString()}\n`;
    executeSelectedScripts(modules['danger-boost'].scripts, 'Azucri-BIOHAZARD');
  });

  // ========================================
  // PROGRESS OVERLAY
  // ========================================
  function showProgress(title, message) {
    progressTitle.textContent = title;
    progressMessage.textContent = message;
    progressPercent.textContent = '0%';
    progressBarFill.style.width = '0%';
    progressBatchInfo.textContent = '';
    progressOverlay.classList.add('active');
  }

  function hideProgress() {
    progressOverlay.classList.remove('active');
  }

  // Listen for progress updates from main process
  window.azucri.onScriptProgress((data) => {
    if (data.percent >= 0) {
      progressPercent.textContent = data.percent + '%';
      progressBarFill.style.width = data.percent + '%';
    }
    if (data.message) {
      progressMessage.textContent = data.message;
    }
  });

  window.azucri.onBatchProgress((data) => {
    progressBatchInfo.textContent = `Script ${data.current} de ${data.total} — ${data.scriptName}`;
    // Reset bar for each new script in batch
    progressBarFill.style.width = '0%';
    progressPercent.textContent = '0%';
  });

  // Cancel Progress
  btnCancelProgress.addEventListener('click', () => {
    if (!isRunning) return;
    btnCancelProgress.textContent = "CANCELANDO...";
    btnCancelProgress.style.opacity = "0.5";
    window.azucri.cancelScripts();
  });

  // ========================================
  // RESULT LOG & AUDIT
  // ========================================
  function showLog(text, type) {
    resultLog.style.display = 'block';
    const colorClass = type === 'ok' ? 'log-ok' : type === 'error' ? 'log-error' : 'log-info';
    
    // Create new entry
    const entry = document.createElement('div');
    entry.innerHTML = `<span class="${colorClass}">${escapeHtml(text)}</span>\n`;
    resultLogContent.appendChild(entry);
    
    // Auto-scroll inside log
    resultLogContent.scrollTop = resultLogContent.scrollHeight;

    // Auto-scroll to log container
    const mainContent = document.getElementById('main-content');
    mainContent.scrollTop = mainContent.scrollHeight;
    
    // Reset cancel button
    btnCancelProgress.textContent = "🚫 CANCELAR OPERAÇÃO";
    btnCancelProgress.style.opacity = "1";
  }

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  btnSaveAudit.addEventListener('click', async () => {
    if (!accumulatedLogs) {
      alert("Nenhum log para salvar ainda.");
      return;
    }
    const result = await window.azucri.saveAuditLog(accumulatedLogs);
    if (result.success) {
      alert(`Arquivo salvo com sucesso em:\n${result.path}`);
    } else if (result.error) {
      alert(`Erro ao salvar arquivo:\n${result.error}`);
    }
  });

  // ========================================
  // ROLLBACK
  // ========================================
  async function handleRollback() {
    const confirmed = await window.azucri.confirmRollback();
    if (!confirmed) return;

    isRunning = true;
    showProgress('AZUCRI-ROLLBACK', 'Restaurando sistema... O PC vai reiniciar!');

    const result = await window.azucri.runScript('backup/restore-system.ps1');

    hideProgress();
    isRunning = false;

    if (result.success) {
      showLog('Sistema será restaurado. Aguarde o reinício...', 'ok');
    } else {
      showLog('Erro no rollback: ' + (result.error || result.output), 'error');
    }
  }

  // ========================================
  // TASK KILLER
  // ========================================
  function openTaskKiller() {
    taskKillerOverlay.classList.add('active');
    loadProcessList();
  }

  taskKillerClose.addEventListener('click', () => {
    taskKillerOverlay.classList.remove('active');
  });

  async function loadProcessList() {
    processTbody.innerHTML = '<tr><td colspan="5" style="text-align:center;color:var(--text-dim);">Carregando processos...</td></tr>';

    const result = await window.azucri.getProcessList();

    if (!result.success) {
      processTbody.innerHTML = '<tr><td colspan="5" style="color:var(--neon-red);">Erro ao listar processos</td></tr>';
      return;
    }

    // Parse process list from script output (JSON format)
    try {
      const processes = JSON.parse(result.output);
      processTbody.innerHTML = '';

      processes.forEach(proc => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td>${escapeHtml(proc.Name)}</td>
          <td>${proc.PID}</td>
          <td>${proc.RAM}</td>
          <td>${proc.CPU || '-'}</td>
          <td><button class="kill-btn" data-pid="${proc.PID}">KILL</button></td>
        `;
        processTbody.appendChild(tr);
      });

      // Kill buttons
      processTbody.querySelectorAll('.kill-btn').forEach(btn => {
        btn.addEventListener('click', async () => {
          const pid = btn.dataset.pid;
          btn.textContent = '...';
          btn.disabled = true;
          const result = await window.azucri.killProcess(pid);
          if (result.success) {
            btn.closest('tr').style.opacity = '0.3';
            btn.textContent = 'DONE';
          } else {
            btn.textContent = 'FAIL';
            btn.style.color = 'var(--neon-red)';
          }
        });
      });
    } catch (e) {
      // Fallback: show raw output
      processTbody.innerHTML = `<tr><td colspan="5" style="font-family:monospace;font-size:11px;white-space:pre-wrap;">${escapeHtml(result.output)}</td></tr>`;
    }
  }

  // ========================================
  // INIT
  // ========================================
  async function init() {
    const isAdmin = await window.azucri.isAdmin();
    if (!isAdmin) {
      const banner = document.getElementById('admin-warning');
      if (banner) banner.style.display = 'block';
      document.body.classList.add('no-admin');
      disableAllCards();
      btnCreateBackup.disabled = true;
      return;
    }
    checkBackup();
  }

  init();
});
