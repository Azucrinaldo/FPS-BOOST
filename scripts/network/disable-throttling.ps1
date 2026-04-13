# Azucrinaldo BOOST FPS - Desativar Network Throttling
$ErrorActionPreference = "SilentlyContinue"
$total = 3
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Desativando NetworkThrottlingIndex (MMCSS)..."
$mmcssPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
Set-ItemProperty -Path $mmcssPath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force

Report-Progress "Desativando Interrupt Moderation nos adaptadores..."
Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*InterruptModeration" -RegistryValue 0 -ErrorAction SilentlyContinue
    Write-Output "[INFO] Interrupt Moderation OFF: $($_.Name)"
}

Report-Progress "Configurando QoS para priorizar gaming..."
$qosPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
if (-not (Test-Path $qosPath)) { New-Item -Path $qosPath -Force | Out-Null }
Set-ItemProperty -Path $qosPath -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force

Write-Output "[OK] Network throttling desativado!"
Write-Output "[INFO] NetworkThrottlingIndex=FFFFFFFF, InterruptModeration=OFF, QoS=0%% reservado"
Write-Output "[DONE] Rede desbloqueada para maximo desempenho."
exit 0
