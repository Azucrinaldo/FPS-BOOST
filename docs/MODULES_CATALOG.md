# 📖 Catálogo de Módulos e Tweaks — BOOST FPS

Este documento detalha o que cada módulo de otimização faz, quais scripts PowerShell são invocados e o impacto esperado no sistema Windows.

---

## 1. 🗑️ Azucri-Bloatware Killer
**Objetivo**: Remover o "lixo" acumulado do Windows (Apps pré-instalados) que consomem ciclos de CPU e espaço em disco.
- **Scripts**: `bloatware/remove-bloatware.ps1`.
- **Tweaks**: 
  - Utiliza `Get-AppxPackage` para remover apps como Solitaire, People, Weather, Skype, Zune e Xbox.
  - Remove as tarefas agendadas de "Consumer Features" do Windows.

## 2. 🤖 Azucri-AI Exterminator
**Objetivo**: Desativar componentes de IA intrusivos que monitoram o uso do PC (Recall) ou ocupam a barra de tarefas (Copilot).
- **Scripts**: `ai-removal/remove-copilot.ps1`, `ai-removal/remove-recall.ps1`, `ai-removal/disable-ai-telemetry.ps1`.
- **Tweaks**: 
  - Define `TurnOffWindowsCopilot` como `1` via GPO/Registry.
  - Bloqueia `DisableAIDataAnalysis` para impedir o Recall de capturar telas.
  - Desativa o serviço de análise local de arquivos via IA.

## 3. ⚙️ Azucri-Service Slayer
**Objetivo**: Desativar serviços de background que priorizam atividades de servidor ou escritório em vez de baixa latência de I/O.
- **Scripts**: `services/disable-services.ps1`.
- **Tweaks**: 
  - Desativa **SysMain** (Superfetch), **Windows Search** (Indexação de disco), **Print Spooler** (se não usado) e Telemetria Conectada.
  - Ajusta o tempo de resposta de serviços críticos.

## 4. 📝 Azucri-Registry Hack
**Objetivo**: Tweaks de registro focados em "snappiness" do mouse e prioridade de hardware.
- **Scripts**: `registry/gaming-registry.ps1`, `registry/input-lag-fix.ps1`.
- **Tweaks**: 
  - **Win32PrioritySeparation**: Definido para `0x26` (38) para prioridade absoluta de janelas em primeiro plano.
  - **FSO**: Desativa Fullscreen Optimizations globais.
  - **MouseDataQueueSize**: Reduzido para diminuir o buffer e aumentar a velocidade de resposta do cursor.

## 5. 🧠 Azucri-RAM Cleaner
**Objetivo**: Resolver o problema de "micro-stuttering" causado pela Standby List cheia do Windows.
- **Scripts**: `memory/clear-ram-cache.ps1`, `memory/clear-standby-list.ps1`.
- **Tweaks**: 
  - Invocação forçada de limpeza de memória de sistema via API do Kernel.
  - Esvaziamento de páginas de memória não utilizadas para garantir RAM livre para o jogo.

## 6. 🌐 Azucri-Net Booster
**Objetivo**: Otimizar a "Network Stack" para menor Ping e estabilidade de pacotes.
- **Scripts**: `network/network-optimization.ps1`.
- **Tweaks**: 
  - **TCP No Delay (Nagle's Algorithm)**: Desativado para enviar pacotes imediatamente.
  - **NetworkThrottlingIndex**: Definido como `0xFFFFFFFF` para remover o limitador de rede multimídia do Windows.

## 7. ☢️ BIOHAZARD (Danger Zone)
**Objetivo**: Ganhos extremos de FPS bruto sacrificando segurança e isolamento.
- **Scripts**: `extreme/danger-boost.ps1`.
- **Tweaks**: 
  - **Desativa Mitigações de CPU**: Desliga proteções contra Spectre V2 e Meltdown. Reduz o overhead do processador em chamadas de sistema.
  - **Desativa DMA Protection**: Melhora a velocidade de comunicação PCIe.
  - **Ajustes de Timer Resolution**: Tenta forçar o timer do Windows para 0.5ms.

## 8. 🛡️ Segurança e Backup
- **Scripts**: `backup/create-restore-point.ps1`, `backup/restore-system.ps1`.
- **O que faz**: Cria e gerencia os pontos de retorno do Windows (VSS) para garantir que qualquer alteração seja reversível.

---
*Todos os scripts podem ser encontrados na pasta `scripts/` do código fonte.*
