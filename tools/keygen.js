const crypto = require('crypto');
const fs = require('fs');

const SECRET_KEY = 'azucrinaldo-boost-fps-secret-key-2026'; // Deve ser IGUAL ao do license-manager.js

function randomBase36(length) {
  let result = '';
  const characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return result;
}

function generateKeyHashSequence(body) {
  const hmac = crypto.createHmac('sha256', SECRET_KEY);
  hmac.update(body);
  return hmac.digest('hex').substring(0, 5).toUpperCase();
}

function generateKey() {
  const p1 = randomBase36(5);
  const p2 = randomBase36(5);
  const p3 = randomBase36(5);
  const p4 = randomBase36(5);
  
  const body = `${p1}-${p2}-${p3}-${p4}`;
  const hash = generateKeyHashSequence(body);
  
  return `AZFPS-${body}-${hash}`;
}

const amount = parseInt(process.argv[2]) || 1;

console.log(`Gerando ${amount} chaves do Azucrinaldo BOOST FPS...\n`);

let output = '';
for (let i = 0; i < amount; i++) {
  const key = generateKey();
  console.log(key);
  output += key + '\n';
}

fs.appendFileSync('keys_geradas.txt', output);
console.log('\nAs chaves foram salvas no arquivo keys_geradas.txt');
