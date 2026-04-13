# Azucrinaldo BOOST FPS - Full Optimization (PRO MAX)
# Executa TODOS os scripts em sequência
$ErrorActionPreference = "SilentlyContinue"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir

Write-Output "[INFO] ========================================="
Write-Output "[INFO] AZUCRI-BOOST FPS PRO MAX - MODO COMPLETO"
Write-Output "[INFO] ========================================="
Write-Output ""

$scripts = @(
    "bloatware\remove-bloatware.ps1",
    "ai-removal\remove-copilot.ps1",
    "ai-removal\remove-recall.ps1",
    "ai-removal\disable-ai-telemetry.ps1",
    "services\disable-services.ps1",
    "registry\gaming-registry.ps1",
    "registry\input-lag-fix.ps1",
    "registry\privacy-registry.ps1",
    "memory\clear-standby-list.ps1",
    "memory\clear-ram-cache.ps1",
    "disk\clean-temp-files.ps1",
    "disk\clean-prefetch.ps1",
    "disk\disk-optimization.ps1",
    "power\ultimate-power-plan.ps1",
    "power\disable-usb-suspend.ps1",
    "network\network-optimization.ps1",
    "network\disable-throttling.ps1"
)

$total = $scripts.Count
$current = 0
$failed = 0

foreach ($script in $scripts) {
    $current++
    $scriptPath = Join-Path $rootDir $script
    $scriptName = Split-Path -Leaf $script
    Write-Output ""
    Write-Output "[PROGRESS] $current/$total Executando: $scriptName"
    Write-Output "--------------------------------------------"

    if (Test-Path $scriptPath) {
        try {
            & $scriptPath
            if ($LASTEXITCODE -ne 0) { $failed++ }
        } catch {
            Write-Output "[ERROR] Falha em ${scriptName}: $($_.Exception.Message)"
            $failed++
        }
    } else {
        Write-Output "[WARNING] Script nao encontrado: $scriptPath"
        $failed++
    }
}

Write-Output ""
Write-Output "[INFO] ========================================="
if ($failed -eq 0) {
    Write-Output "[OK] TODOS os $total scripts executados com SUCESSO!"
} else {
    Write-Output "[WARNING] $($total - $failed)/$total scripts OK, $failed falharam"
}
Write-Output "[INFO] ========================================="
Write-Output "[DONE] AZUCRI-BOOST FPS PRO MAX concluido!"
Write-Output "[INFO] Reinicie o computador para aplicar todas as mudancas."
exit 0
