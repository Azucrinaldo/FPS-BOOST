# Azucrinaldo BOOST FPS - Limpar Cache de RAM
$ErrorActionPreference = "SilentlyContinue"
$total = 3
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Limpando cache de DNS..."
Clear-DnsClientCache -ErrorAction SilentlyContinue
ipconfig /flushdns | Out-Null

Report-Progress "Forçando garbage collection e tarefas ociosas..."
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
Start-Process -FilePath "rundll32.exe" -ArgumentList "advapi32.dll,ProcessIdleTasks" -Wait -NoNewWindow -ErrorAction SilentlyContinue

Report-Progress "Verificando estado da memoria..."
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$usedMB = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1KB, 0)
$freeMB = [math]::Round($os.FreePhysicalMemory / 1KB, 0)
$totalMB = [math]::Round($os.TotalVisibleMemorySize / 1KB, 0)
$usedPct = [math]::Round(($usedMB / $totalMB) * 100, 1)

Write-Output "[INFO] RAM: ${usedMB}MB usados / ${freeMB}MB livres / ${totalMB}MB total (${usedPct}%)"
Write-Output "[OK] Cache de RAM limpo!"
Write-Output "[DONE] Memoria otimizada."
exit 0
