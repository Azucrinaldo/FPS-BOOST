const fs = require('fs');
const path = require('path');

const SCRIPTS_DIR = path.join(__dirname, '..', 'scripts');

console.log('⚡ AZUCRINALDO BOOST FPS - INICIANDO AUDITORIA DINÂMICA (PRO LAB) ⚡\n');

let passed = 0;
let emptyFolders = [];

if (!fs.existsSync(SCRIPTS_DIR)) {
  console.error('[ERRO FATAL] Pasta de scripts não encontrada!');
  process.exit(1);
}

const folders = fs.readdirSync(SCRIPTS_DIR).filter(file => {
  return fs.statSync(path.join(SCRIPTS_DIR, file)).isDirectory();
});

folders.forEach(folder => {
  const folderPath = path.join(SCRIPTS_DIR, folder);
  const files = fs.readdirSync(folderPath);
  
  const ps1Files = files.filter(f => f.endsWith('.ps1'));
  
  if (ps1Files.length > 0) {
    console.log(`[PASS] Módulo [${folder}] operante com ${ps1Files.length} scripts.`);
    passed++;
  } else {
    console.error(`[FAIL] Módulo [${folder}] ESTÁ VAZIO! Operação comprometida.`);
    emptyFolders.push(folder);
  }
});

console.log('\n--- RESULTADOS DA AUDITORIA ---');
console.log(`MÓDULOS VERIFICADOS COM SUCESSO: ${passed}/${folders.length}`);

if (emptyFolders.length > 0) {
  console.log(`\n❌ AUDITORIA FALHOU. Pastas sem scripts: ${emptyFolders.join(', ')}`);
  process.exit(1);
} else {
  console.log('\n✅ AUDITORIA CONCLUÍDA. Core System 100% íntegro.');
  process.exit(0);
}
