/**
 * Azucrinaldo BOOST FPS - Revogação de Licenças
 * ==============================================
 * 
 * O sistema de licenças remotas verifica um arquivo JSON em um GitHub Gist.
 * Para bloqueiar uma licença que vazou ou teve pagamento devolvido, você precisa
 * atualizar o JSON manualmente, adicionando a chave gerada no array `revoked_keys`.
 * 
 * PASSO A PASSO
 * -------------
 * 1. Entre no GitHub (https://gist.github.com/) e crie um novo gist secreto ou público.
 * 2. Nome do arquivo: `license.json`
 * 3. O conteúdo deve ser parecido com:
 * 
 * {
 *   "version": 1,
 *   "revoked_keys": [
 *      "AZFPS-XXXXX-XXXXX-XXXXX-XXXXX" 
 *   ],
 *   "valid_range": {
 *     "min_version": "1.0.0",
 *     "max_trial_minutes": 30
 *   }
 * }
 * 
 * 4. Salve o Gist.
 * 5. Clique no botão "Raw" para ver o JSON puro.
 * 6. Copie a URL do Raw (ela começa com https://gist.githubusercontent.com/...)
 * 7. Cole essa URL lá no arquivo `electron/license-manager.js` na variável GIST_URL.
 * 8. Sempre que quiser bloquear uma chave, edite o Gist e coloque ela dentro do array "revoked_keys".
 */

console.log("-----------------------------------------");
console.log("Azucrinaldo BOOST FPS - Gui de Revogação");
console.log("-----------------------------------------");
console.log("Este é um script informativo. Siga as instruções");
console.log("no arquivo: tools/revoke-license.js");
console.log("Para revogar uma chave, atualize o JSON no GitHub Gist.");
