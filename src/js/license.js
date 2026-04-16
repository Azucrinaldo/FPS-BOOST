document.addEventListener('DOMContentLoaded', async () => {
    // UI Elements
    const minimizeBtn = document.getElementById('minimizeBtn');
    const closeBtn = document.getElementById('closeBtn');
    const statusBadge = document.getElementById('statusBadge');
    const statusMessage = document.getElementById('statusMessage');
    const trialTimerContainer = document.getElementById('trialTimerContainer');
    const trialTimer = document.getElementById('trialTimer');
    const continueTrialBtn = document.getElementById('continueTrialBtn');
    const hwidDisplay = document.getElementById('hwidDisplay');
    const licenseInput = document.getElementById('licenseInput');
    const activateBtn = document.getElementById('activateBtn');
    const feedbackMessage = document.getElementById('feedbackMessage');

    let timerInterval;

    // Window controls
    minimizeBtn.addEventListener('click', () => window.azucri.minimize());
    closeBtn.addEventListener('click', () => window.azucri.close());

    // Auto-format input
    licenseInput.addEventListener('input', (e) => {
        let val = e.target.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();
        let formatted = '';
        if (val.startsWith('AZFPS')) {
            val = val.substring(5);
            formatted = 'AZFPS-';
        } else if (val.length > 0) {
            formatted = 'AZFPS-';
        }
        
        for (let i = 0; i < val.length && i < 20; i++) {
            if (i > 0 && i % 5 === 0) formatted += '-';
            formatted += val[i];
        }
        
        e.target.value = formatted;
    });

    // Handle Activation
    activateBtn.addEventListener('click', async () => {
        const key = licenseInput.value;
        if (key.length < 29) { // AZFPS-XXXXX-XXXXX-XXXXX-XXXXX
            showFeedback('Por favor, insira uma chave completa no formato correto.', 'error');
            return;
        }

        activateBtn.disabled = true;
        activateBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Validando...';
        
        const result = await window.azucri.activateLicense(key);
        
        if (result.success) {
            showFeedback('Sucesso! Redirecionando...', 'success');
            setTimeout(() => {
                // IPC já cuida de fechar e ir pro app principal
            }, 1000);
        } else {
            showFeedback(result.message || 'Chave inválida.', 'error');
            activateBtn.disabled = false;
            activateBtn.innerHTML = '<i class="fas fa-unlock-alt"></i> Ativar Agora';
        }
    });

    // Continue Trial
    continueTrialBtn.addEventListener('click', () => {
        window.azucri.continueTrial();
    });

    function showFeedback(msg, type) {
        feedbackMessage.textContent = msg;
        feedbackMessage.className = `feedback ${type}`;
        feedbackMessage.classList.remove('hidden');
    }

    function formatTime(ms) {
        const totalSeconds = Math.floor(ms / 1000);
        const minutes = Math.floor(totalSeconds / 60);
        const seconds = totalSeconds % 60;
        return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    }

    function updateTimerDisplay(remaining) {
        if (remaining <= 0) {
            clearInterval(timerInterval);
            trialTimer.textContent = '00:00';
            trialTimerContainer.classList.add('hidden');
            continueTrialBtn.classList.add('hidden');
            
            statusBadge.className = 'status-badge expired';
            statusBadge.textContent = 'Trial Expirado';
            statusMessage.textContent = 'O período de 30 minutos de avaliação chegou ao fim. Por favor, ative a versão Premium para continuar.';
            return;
        }
        trialTimer.textContent = formatTime(remaining);
    }

    // Initialize state
    async function initState() {
        const hwid = await window.azucri.getHwId();
        hwidDisplay.textContent = hwid;

        const status = await window.azucri.checkLicense();
        
        if (status.status === 'expired') {
            statusBadge.className = 'status-badge expired';
            statusBadge.textContent = 'Trial Expirado';
            statusMessage.textContent = 'O período de 30 minutos de avaliação chegou ao fim. Por favor, ative a versão Premium para continuar utilizando o app.';
        } else if (status.status === 'invalid' || status.status === 'revoked') {
            statusBadge.className = 'status-badge expired';
            statusBadge.textContent = 'Licença Bloqueada';
            statusMessage.textContent = status.message || 'Houve um problema com sua licença. Ela pode ter sido revogada ou é inválida.';
        } else if (status.status === 'trial') {
            statusBadge.className = 'status-badge trial';
            statusBadge.textContent = 'Modo Avaliação';
            statusMessage.textContent = 'Você está usando a versão de demonstração. Os recursos serão bloqueados após o tempo esgotar.';
            
            trialTimerContainer.classList.remove('hidden');
            updateTimerDisplay(status.remainingMs);
            
            timerInterval = setInterval(async () => {
                const remaining = await window.azucri.getTrialRemaining();
                updateTimerDisplay(remaining);
                if (remaining <= 0) { // Bloqueia botões dinamicamente
                    window.location.reload(); 
                }
            }, 1000);
        } else if (status.status === 'premium') {
            // Em tese não deve cair aqui, pois o main.js já redireciona
            statusBadge.className = 'status-badge premium';
            statusBadge.textContent = 'Premium Ativado';
            statusMessage.textContent = 'Obrigado por apoiar o projeto!';
            activateBtn.classList.add('hidden');
            licenseInput.classList.add('hidden');
        }
    }

    initState();
});
