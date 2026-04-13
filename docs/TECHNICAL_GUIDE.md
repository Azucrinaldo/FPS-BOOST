# 🛠️ Guia de Arquitetura Técnica — BOOST FPS

Este documento descreve o funcionamento interno do **BOOST FPS**, detalhando a pilha de tecnologias escolhida, o fluxo de comunicação entre os processos e os mecanismos de execução de scripts de baixo nível.

---

## 🏗️ Stack Tecnológica

O sistema é construído sobre uma arquitetura híbrida de **Web de Alto Nível** com **Scripting de Baixo Nível**:

1. **Frontend**: Electron (Vite/Node.js) utilizando HTML5, CSS3 e JavaScript.
   - **Estética**: Design modular construído sob variáveis de CSS (design tokens), oferecendo suporte nativo e fluido a temas estéticos (Cyberpunk Dark/Neon).
2. **Backend (App)**: Node.js (Electron Main Process) voltado para o gerenciamento soberano do ciclo de vida das janelas e chamadas de sistema.
3. **Execution Engine**: Windows PowerShell 5.1/7.0+.
   - Os scripts rodam utilizando contorno de políticas de execução (`-ExecutionPolicy Bypass`), garantindo a operabilidade integral sem bloqueios de permissões locais.

---

## 📡 Fluxo de Comunicação (IPC)

O **BOOST FPS** utiliza o `ipcMain` e `ipcRenderer` do Electron para uma comunicação assíncrona bidirecional segura:

### Handlers Principais (`main.js`)
- `run-script`: Executa um arquivo `.ps1` individual.
- `run-scripts-batch`: Gerencia uma fila de execução sequencial para módulos completos.
- `check-restore-point`: Consulta o sistema Windows via PowerShell para verificar backups existentes.
- `get-process-list`: Wrapper para o comando `Get-Process` do PowerShell para o Task Killer.

---

## 📜 Motor de Execução de Scripts (`script-runner.js`)

O arquivo `script-runner.js` é o coração das operações do sistema. Ele gerencia o ciclo de vida dos processos PowerShell de forma isolada:

### Funcionamento do `spawn`
Os scripts não são executados via `exec()` simples para evitar travamentos da UI. Utilizamos `spawn()` para streaming de dados em tempo real:
```javascript
activeProcess = spawn('powershell.exe', [
  '-ExecutionPolicy', 'Bypass',
  '-File', scriptPath
]);
```

### Parsing de Status em Tempo Real
O app "escuta" a saída do PowerShell em busca de tags específicas formatadas nos scripts:
- `[PROGRESS] X/Y`: Atualiza a barra de progresso visual.
- `[INFO] / [OK] / [ERROR]`: Formata as mensagens no log de auditoria com cores variadas.

### Cancelamento Seguro
O app suporta o término forçado de scripts via `taskkill` do PID do processo pai e seus filhos (`/T /F`), garantindo que nenhuma otimização pare pela metade deixando o sistema instável.

---

## 📂 Organização de Recursos

Para garantir a portabilidade do executável, os scripts são mapeados dinamicamente:
- **Desenvolvimento**: Diretório `./scripts` na raiz.
- **Produção (Packaged)**: Diretório `process.resourcesPath/scripts`.

Os scripts são incluídos no pacote Final através da configuração `extraResources` no `package.json`.

---

## 🛡️ Segurança de Execução

- **Admin Check**: O app executa o comando `net session` no início. Se o erro for retornado, a UI bloqueia as funcionalidades, pois quase todas as otimizações escrevem em `HKEY_LOCAL_MACHINE` ou modificam serviços protegidos.
- **Rollback System**: O sistema armazena o ID do ponto de restauração criado para permitir a reversão exata via `SystemRestore.ps1`.

---
*Documentação Técnica baseada na Versão 1.0.0*
