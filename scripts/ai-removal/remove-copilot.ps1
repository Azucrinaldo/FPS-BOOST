# Azucrinaldo BOOST FPS - Remover Copilot e integracoes
$ErrorActionPreference = "SilentlyContinue"
$total = 6
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Removendo pacotes Copilot..."
Get-AppxPackage -Name "*Copilot*" | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -Name "*Microsoft.Windows.Ai*" | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*Copilot*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

Report-Progress "Desativando Copilot via registro..."
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
Set-ItemProperty -Path $regPath -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force

Report-Progress "Removendo Copilot da barra de tarefas..."
$tbPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $tbPath -Name "ShowCopilotButton" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

Report-Progress "Desativando Edge WebView do Copilot..."
$edgePath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (-not (Test-Path $edgePath)) { New-Item -Path $edgePath -Force | Out-Null }
Set-ItemProperty -Path $edgePath -Name "HubsSidebarEnabled" -Value 0 -Type DWord -Force

Report-Progress "Bloqueando reinstalacao via Windows Update..."
$wuPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator"
if (-not (Test-Path $wuPath)) { New-Item -Path $wuPath -Force | Out-Null }
Set-ItemProperty -Path $wuPath -Name "BlockCopilotInstall" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

Report-Progress "Desativando Copilot no Edge..."
Set-ItemProperty -Path $edgePath -Name "CopilotCDPEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

Write-Output "[OK] Copilot removido e bloqueado!"
Write-Output "[DONE] AI Copilot exterminado com sucesso."
exit 0
