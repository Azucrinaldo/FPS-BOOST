document.addEventListener('DOMContentLoaded', () => {
  const skipBtn = document.getElementById('skip-btn');
  const loadingBar = document.getElementById('intro-loading-bar');
  const loadingPercent = document.getElementById('intro-loading-percent');
  const terminalText = document.getElementById('terminal-text');
  const glitchFlash = document.getElementById('glitch-flash');
  const audio = document.getElementById('intro-audio');

  // ==========================================
  // CONFIG
  // ==========================================
  const TOTAL_DURATION = 7000; // Total intro time in ms
  const TERMINAL_MESSAGES = [
    '> Inicializando kernel de otimização...',
    '> Verificando integridade do sistema...',
    '> Carregando módulos de performance...',
    '> Desativando limitadores de FPS...',
    '> Injetando tweaks de baixa latência...',
    '> Sistema pronto. Iniciando interface...'
  ];

  // ==========================================
  // AUDIO
  // ==========================================
  if (audio) {
    audio.volume = 0.4;
    audio.play().catch(() => {
      // Autoplay blocked, ignore silently
    });
  }

  // ==========================================
  // TERMINAL TEXT TYPEWRITER
  // ==========================================
  let msgIndex = 0;
  let charIndex = 0;
  let currentMsg = '';
  const MSG_INTERVAL = TOTAL_DURATION / TERMINAL_MESSAGES.length;

  function typeNextMessage() {
    if (msgIndex >= TERMINAL_MESSAGES.length) return;

    currentMsg = TERMINAL_MESSAGES[msgIndex];
    charIndex = 0;
    terminalText.textContent = '';

    const typeInterval = setInterval(() => {
      if (charIndex < currentMsg.length) {
        terminalText.textContent = currentMsg.substring(0, charIndex + 1);
        charIndex++;
      } else {
        clearInterval(typeInterval);
        msgIndex++;
        if (msgIndex < TERMINAL_MESSAGES.length) {
          setTimeout(typeNextMessage, 200);
        }
      }
    }, 25);
  }

  // Start typing after content reveals (2s delay)
  setTimeout(typeNextMessage, 2200);

  // ==========================================
  // LOADING BAR PROGRESS
  // ==========================================
  const loadStartDelay = 2400;
  const loadDuration = TOTAL_DURATION - loadStartDelay - 800; // Leave 800ms for final fade
  let loadStart = null;

  function animateLoading(timestamp) {
    if (!loadStart) loadStart = timestamp;
    const elapsed = timestamp - loadStart;
    const progress = Math.min(elapsed / loadDuration, 1);

    // Non-linear progress (starts slow, accelerates)
    const eased = progress < 0.8
      ? progress * 0.9
      : 0.72 + (progress - 0.8) * 1.4;

    const percent = Math.min(Math.round(eased * 100), 100);
    loadingBar.style.width = percent + '%';
    loadingPercent.textContent = percent + '%';

    if (progress < 1) {
      requestAnimationFrame(animateLoading);
    } else {
      loadingBar.style.width = '100%';
      loadingPercent.textContent = '100%';
    }
  }

  setTimeout(() => {
    requestAnimationFrame(animateLoading);
  }, loadStartDelay);

  // ==========================================
  // RANDOM GLITCH FLASHES
  // ==========================================
  function triggerGlitch() {
    glitchFlash.style.transition = 'none';
    glitchFlash.style.opacity = (Math.random() * 0.12 + 0.03).toString();
    glitchFlash.style.background = Math.random() > 0.5 ? '#00f0ff' : '#fff';

    setTimeout(() => {
      glitchFlash.style.transition = 'opacity 0.05s';
      glitchFlash.style.opacity = '0';
    }, 30 + Math.random() * 50);
  }

  // Random glitches every 0.5-2s
  function scheduleGlitch() {
    const delay = 500 + Math.random() * 1500;
    setTimeout(() => {
      triggerGlitch();
      // Sometimes double-glitch
      if (Math.random() > 0.6) {
        setTimeout(triggerGlitch, 60);
      }
      scheduleGlitch();
    }, delay);
  }
  setTimeout(scheduleGlitch, 1500);

  // ==========================================
  // AUTO-TRANSITION
  // ==========================================
  setTimeout(() => {
    goToMain();
  }, TOTAL_DURATION);

  // ==========================================
  // SKIP
  // ==========================================
  skipBtn.addEventListener('click', goToMain);

  document.addEventListener('keydown', (e) => {
    if (e.key === ' ' || e.key === 'Enter' || e.key === 'Escape') {
      goToMain();
    }
  });

  // ==========================================
  // TRANSITION TO MAIN
  // ==========================================
  let transitioned = false;

  function goToMain() {
    if (transitioned) return;
    transitioned = true;

    // Stop audio
    if (audio) {
      audio.pause();
      audio.currentTime = 0;
    }

    // Final glitch burst
    glitchFlash.style.transition = 'none';
    glitchFlash.style.opacity = '0.25';
    glitchFlash.style.background = '#fff';

    setTimeout(() => {
      // Fade to black
      document.body.style.transition = 'opacity 0.4s ease';
      document.body.style.opacity = '0';

      setTimeout(() => {
        if (window.azucri && window.azucri.introFinished) {
          window.azucri.introFinished();
        }
      }, 450);
    }, 80);
  }
});
