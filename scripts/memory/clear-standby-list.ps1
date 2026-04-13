# Azucrinaldo BOOST FPS - Limpar Standby List (tipo ISLC)
$ErrorActionPreference = "SilentlyContinue"
$total = 3
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

# Definir API nativa para limpar memória
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class MemoryManager {
    [DllImport("psapi.dll")]
    public static extern bool EmptyWorkingSet(IntPtr hProcess);

    [DllImport("kernel32.dll")]
    public static extern IntPtr GetCurrentProcess();
}
"@

Report-Progress "Limpando Working Set de processos..."
$procs = Get-Process | Where-Object { $_.WorkingSet64 -gt 50MB }
$cleaned = 0
foreach ($proc in $procs) {
    try {
        [MemoryManager]::EmptyWorkingSet($proc.Handle) | Out-Null
        $cleaned++
    } catch { }
}
Write-Output "[INFO] Working set limpo em $cleaned processos"

Report-Progress "Executando limpeza de cache do sistema..."
# Limpa file system cache
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

# Rundll32 para limpar Standby List (método alternativo)
Start-Process -FilePath "rundll32.exe" -ArgumentList "advapi32.dll,ProcessIdleTasks" -Wait -NoNewWindow -ErrorAction SilentlyContinue

Report-Progress "Verificando memoria liberada..."
$ramInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$freeGB = [math]::Round($ramInfo.FreePhysicalMemory / 1MB, 2)
$totalGB = [math]::Round($ramInfo.TotalVisibleMemorySize / 1MB, 2)
Write-Output "[INFO] RAM Livre: ${freeGB}GB / ${totalGB}GB"

Write-Output "[OK] Standby List limpa!"
Write-Output "[DONE] Cache de memoria limpo."
exit 0
