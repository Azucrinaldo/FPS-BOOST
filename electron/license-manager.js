const Store = require('electron-store');
const { machineIdSync } = require('node-machine-id');
const crypto = require('crypto');
const os = require('os');
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

// A URL DO SEU GIST (Usuário deve colocar a URL Raw do gist JSON aqui)
// Exemplo: https://gist.githubusercontent.com/SeuUser/ID_DO_GIST/raw/license.json
const GIST_URL = 'https://gist.githubusercontent.com/AZU-DUMMY-URL/raw'; 

// Chave secreta interna para gerar/validar as licenças locais (NÃO COMPARTILHAR)
const SECRET_KEY = 'azucrinaldo-boost-fps-secret-key-2026';

// Configuração do armazenamento local criptografado
const store = new Store({
  name: 'azucrinaldo-license',
  encryptionKey: 'azu-fps-enc-key-local-protect'
});

const TRIAL_DURATION_MS = 30 * 60 * 1000; // 30 minutos

class LicenseManager {
  constructor() {
    this.hardwareId = this.generateHardwareId();
    this.initTrial();
  }

  generateHardwareId() {
    try {
      // Usa node-machine-id (mais estável no Windows) + hostname para dificultar spoofing local
      let id = machineIdSync();
      const hash = crypto.createHash('sha256').update(id + os.hostname()).digest('hex');
      return hash.substring(0, 16).toUpperCase();
    } catch (e) {
      console.error('Erro ao gerar HWID', e);
      return 'UNKNOWN-HWID-0000';
    }
  }

  initTrial() {
    if (!store.has('trialStart')) {
      store.set('trialStart', Date.now());
    }
  }

  getTrialRemaining() {
    const trialStart = store.get('trialStart', 0);
    const elapsed = Date.now() - trialStart;
    const remaining = TRIAL_DURATION_MS - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  getLocalLicense() {
    return store.get('licenseKey', null);
  }

  verifyKeyHash(key) {
    if (!key || typeof key !== 'string' || !key.startsWith('AZFPS-')) return false;
    
    const parts = key.split('-');
    if (parts.length !== 5) return false;

    // AZFPS-XXXXX-XXXXX-XXXXX-HASHX
    const body = parts.slice(0, 4).join('-');
    const expectedHash = this.generateKeyHashSequence(body);
    
    return parts[4] === expectedHash;
  }

  generateKeyHashSequence(body) {
    const hmac = crypto.createHmac('sha256', SECRET_KEY);
    hmac.update(body);
    // Pega os 5 primeiros caracteres do Base36 do hash
    return hmac.digest('hex').substring(0, 5).toUpperCase();
  }

  async checkRemoteRevocation(key) {
    try {
      if (GIST_URL.includes('AZU-DUMMY-URL')) return false; // Ignora se a URL não foi configurada
      
      const res = await fetch(GIST_URL);
      if (!res.ok) return false;
      
      const data = await res.json();
      if (data.revoked_keys && data.revoked_keys.includes(key)) {
        return true; // Revogada!
      }
      return false;
    } catch (e) {
      console.error('Erro ao verificar servidor de licença. Liberando localmente.', e);
      return false; // Permanece a validação local se estiver offline
    }
  }

  async getLicenseStatus() {
    const localKey = this.getLocalLicense();

    if (localKey) {
      // Verifica integridade da chave
      if (this.verifyKeyHash(localKey)) {
        // Verifica se foi revogada remotamente
        const isRevoked = await this.checkRemoteRevocation(localKey);
        if (isRevoked) {
          store.delete('licenseKey'); // Invalida localmente
          return { status: 'revoked', message: 'Licença revogada pelo servidor.' };
        }
        return { status: 'premium', key: localKey, hwid: this.hardwareId };
      } else {
        store.delete('licenseKey'); // Chave adulterada
        return { status: 'invalid', message: 'Licença inválida ou adulterada.' };
      }
    }

    // Se não tem chave, verifica Trial
    const remaining = this.getTrialRemaining();
    if (remaining > 0) {
      return { status: 'trial', remainingMs: remaining, hwid: this.hardwareId };
    } else {
      return { status: 'expired', message: 'Período de avaliação de 30 minutos esgotado.', hwid: this.hardwareId };
    }
  }

  async activateLicense(key) {
    key = key.trim().toUpperCase();
    
    if (!this.verifyKeyHash(key)) {
      return { success: false, message: 'Chave de ativação inválida.' };
    }

    const isRevoked = await this.checkRemoteRevocation(key);
    if (isRevoked) {
      return { success: false, message: 'Esta chave foi bloqueada/revogada pelo servidor.' };
    }

    store.set('licenseKey', key);
    return { success: true, message: 'App ativado com sucesso!' };
  }
}

module.exports = new LicenseManager();
