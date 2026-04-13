# Azucrinaldo BOOST FPS - Limpar Prefetch
$ErrorActionPreference = "SilentlyContinue"
$total = 2
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Limpando pasta Prefetch..."
$prefetchPath = "$env:SystemRoot\Prefetch"
$count = (Get-ChildItem $prefetchPath -Force -ErrorAction SilentlyContinue).Count
Remove-Item -Path "$prefetchPath\*" -Force -ErrorAction SilentlyContinue

Report-Progress "Verificando..."
$remaining = (Get-ChildItem $prefetchPath -Force -ErrorAction SilentlyContinue).Count
$removed = $count - $remaining

Write-Output "[OK] $removed arquivos Prefetch removidos!"
Write-Output "[INFO] O Windows vai recriar o Prefetch otimizado na proxima inicializacao."
Write-Output "[DONE] Prefetch limpo."
exit 0
