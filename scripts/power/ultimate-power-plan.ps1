# Azucrinaldo BOOST FPS - Plano de Energia Ultimate Performance
$ErrorActionPreference = "SilentlyContinue"
$total = 4
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Desbloqueando plano Ultimate Performance..."
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null

Report-Progress "Listando planos disponiveis..."
$plans = powercfg -list 2>&1
Write-Output "[INFO] Planos:`n$plans"

# Tentar ativar Ultimate Performance
Report-Progress "Ativando plano de alta performance..."
$ultimateGuid = $null
$planLines = powercfg -list 2>&1
foreach ($line in $planLines) {
    if ($line -match "Ultimate Performance|Desempenho M.ximo") {
        if ($line -match "([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})") {
            $ultimateGuid = $Matches[1]
        }
    }
}

if ($ultimateGuid) {
    powercfg -setactive $ultimateGuid
    Write-Output "[OK] Plano Ultimate Performance ativado! GUID: $ultimateGuid"
} else {
    # Fallback: ativar High Performance
    $highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    powercfg -setactive $highPerfGuid
    Write-Output "[INFO] Ultimate nao encontrado. High Performance ativado."
}

Report-Progress "Desativando hibernacao (libera espaco)..."
powercfg -h off

Write-Output "[DONE] Plano de energia otimizado."
exit 0
