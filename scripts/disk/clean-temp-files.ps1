# Azucrinaldo BOOST FPS - Limpar Arquivos Temporários
$ErrorActionPreference = "SilentlyContinue"
$total = 5
$current = 0
$totalFreed = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }
function Get-FolderSizeMB { param([string]$path); if (Test-Path $path) { [math]::Round((Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB, 1) } else { 0 } }

Report-Progress "Limpando pasta TEMP do usuario..."
$tempPath = $env:TEMP
$sizeBefore = Get-FolderSizeMB $tempPath
Remove-Item -Path "$tempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
$sizeAfter = Get-FolderSizeMB $tempPath
$freed = $sizeBefore - $sizeAfter
$totalFreed += $freed
Write-Output "[INFO] TEMP: ${freed}MB liberados"

Report-Progress "Limpando pasta TEMP do sistema..."
$winTemp = "$env:SystemRoot\Temp"
$sizeBefore = Get-FolderSizeMB $winTemp
Remove-Item -Path "$winTemp\*" -Recurse -Force -ErrorAction SilentlyContinue
$sizeAfter = Get-FolderSizeMB $winTemp
$freed = $sizeBefore - $sizeAfter
$totalFreed += $freed
Write-Output "[INFO] Windows TEMP: ${freed}MB liberados"

Report-Progress "Limpando cache de thumbnails..."
$thumbPath = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
Remove-Item -Path "$thumbPath\thumbcache_*.db" -Force -ErrorAction SilentlyContinue

Report-Progress "Limpando cache de atualizacoes antigas..."
$wuPath = "$env:SystemRoot\SoftwareDistribution\Download"
$sizeBefore = Get-FolderSizeMB $wuPath
Remove-Item -Path "$wuPath\*" -Recurse -Force -ErrorAction SilentlyContinue
$sizeAfter = Get-FolderSizeMB $wuPath
$freed = $sizeBefore - $sizeAfter
$totalFreed += $freed
Write-Output "[INFO] Windows Update cache: ${freed}MB liberados"

Report-Progress "Limpando Lixeira..."
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

Write-Output "[OK] Limpeza concluida! Total liberado: ~${totalFreed}MB"
Write-Output "[DONE] Arquivos temporarios removidos."
exit 0
