# 🔍 Dicionário Técnico de Scripts — BOOST FPS

Este documento fornece uma visão exaustiva de cada script individual contido na pasta `scripts/`, detalhando sua função específica e o comando técnico principal executado no Windows.

---

## 🤖 Módulo: IA & Telemetria (`ai-removal/`)

| Script | Função | Comando Principal |
| :--- | :--- | :--- |
| `disable-ai-telemetry.ps1` | Bloqueia rastreamento de IA. | `Set-ItemProperty ... "AllowTelemetry" -Value 0` |
| `remove-copilot.ps1` | Remove o app e barra do Copilot. | `Get-AppxPackage "*Copilot*" | Remove-AppxPackage` |
| `remove-recall.ps1` | Extermina o Windows Recall. | `Set-ItemProperty ... "AllowRecall" -Value 0` |

## 🛡️ Módulo: Segurança (`backup/`)

| Script | Função | Comando Principal |
| :--- | :--- | :--- |
| `create-restore-point.ps1` | Cria backup total do sistema. | `Checkpoint-Computer -RestorePointType "MODIFY_SETTINGS"` |
| `check-restore-point.ps1` | Valida se há backup existente. | `Get-ComputerRestorePoint | Where-Object ...` |
| `restore-system.ps1` | Restaura o PC ao estado original. | `Restore-Computer -RestorePoint $index` |

## 🗑️ Módulo: Purga de Sistema (`bloatware/`)

| Script | Função | Comando Principal |
| :--- | :--- | :--- |
| `remove-bloatware.ps1` | Remove 39+ apps nativos inúteis. | Loop: `Get-AppxPackage $app | Remove-AppxPackage` |

## 💿 Módulo: Disco (`disk/`)

| Script | Função | Comando Principal |
| :--- | :--- | :--- |
| `clean-prefetch.ps1` | Limpa histórico de apps. | `Remove-Item -Path "$env:SystemRoot\Prefetch\*"` |
| `clean-temp-files.ps1` | Limpa lixo de `/TEMP` e Lixeira. | `Remove-Item -Path "$env:TEMP\*" -Recurse` |
| `disk-optimization.ps1` | Repara arquivos e limpa componentes.| `sfc /scannow` & `cleanmgr.exe /sagerun:100` |

## 🧠 Módulo: Memória (`memory/`)

| Script | Função | Comando Principal |
| :--- | :--- | :--- |
| `clear-ram-cache.ps1` | Limpa cache DNS e Garbage Collection.| `[System.GC]::Collect()` |
| `clear-standby-list.ps1` | Esvazia a Standby List (RAM presa). | `[MemoryManager]::EmptyWorkingSet($proc.Handle)` |
| `task-killer.ps1` | Lista processos pesados (>80MB). | `Get-Process | Where-Object { WS > 80MB }` |

## 🌐 Módulo: Rede (`network/`)

| Script | Função | Comando Principal |
| :--- | :--- | :--- |
| `network-optimization.ps1` | Ajusta latência TCP e DNS. | `TCPNoDelay=1`, `TcpAckFrequency=1` |
| `disable-throttling.ps1` | Remove limitadores de rede MMCSS. | `NetworkThrottlingIndex = 0xFFFFFFFF` |

## ⚡ Módulo: Energia (`power/`)

| Script | Função | Comando Principal |
| :--- | :--- | :--- |
| `ultimate-power-plan.ps1` | Ativa plano de performance oculta. | `powercfg -duplicatescheme e9a42b02...` |
| `disable-usb-suspend.ps1` | Impede USB de "dormir" (Input Lag). | `powercfg -setacvalueindex ... 0` |

## 📝 Módulo: Registro (`registry/`)

| Script | Função | Comando Principal |
| :--- | :--- | :--- |
| `gaming-registry.ps1` | Prioridade de CPU e GPU. | `Win32PrioritySeparation = 38 (0x26)` |
| `input-lag-fix.ps1` | Curva de mouse linear e buffers. | `MouseDataQueueSize = 16` |
| `privacy-registry.ps1` | Desativa Apps em Background. | `GlobalUserDisabled = 1` |

## ⚙️ Módulo: Serviços & Outros

| Script | Função | Comando Principal |
| :--- | :--- | :--- |
| `disable-services.ps1` | Desliga 22 serviços redundantes. | `Set-Service -Name $svc -StartupType Disabled` |
| `system-scanner.ps1` | Audita o estado atual do PC. | Verifica flags de registro e estado de serviços. |
| `full-optimization.ps1` | Modo PRO MAX (Roda tudo). | Wrapper: Execução sequencial de todos os itens acima. |

---
*Nota: Todos os comandos utilizam o flag `-Force` e `-ErrorAction SilentlyContinue` para garantir execução silenciosa e sem interrupções por permissões de arquivos individuais.*
