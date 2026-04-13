# Azucrinaldo BOOST FPS - Desativar Recall / Snapshots
$ErrorActionPreference = "SilentlyContinue"
$total = 4
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Desativando Recall via GPO (registro)..."
$recallPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Recall"
if (-not (Test-Path $recallPath)) { New-Item -Path $recallPath -Force | Out-Null }
Set-ItemProperty -Path $recallPath -Name "AllowRecall" -Value 0 -Type DWord -Force

Report-Progress "Desativando snapshots do Recall..."
$aiPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
if (-not (Test-Path $aiPath)) { New-Item -Path $aiPath -Force | Out-Null }
Set-ItemProperty -Path $aiPath -Name "DisableAIDataAnalysis" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $aiPath -Name "TurnOffSavingSnapshots" -Value 1 -Type DWord -Force

Report-Progress "Removendo pacotes Recall Appx..."
Get-AppxPackage -Name "*Recall*" | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -Name "*WindowsAI*" | Remove-AppxPackage -ErrorAction SilentlyContinue

Report-Progress "Desativando recursos opcionais de IA..."
$featPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing"
# Disable optional AI features
Get-WindowsOptionalFeature -Online -FeatureName "*Recall*" -ErrorAction SilentlyContinue | Disable-WindowsOptionalFeature -Online -NoRestart -ErrorAction SilentlyContinue

Write-Output "[OK] Recall e Snapshots desativados com sucesso!"
Write-Output "[DONE] IA de captura de tela eliminada."
exit 0
