# Azucrinaldo BOOST FPS - Otimização de Disco
$ErrorActionPreference = "SilentlyContinue"
$total = 3
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Verificando integridade dos arquivos do sistema (SFC)..."
$sfcResult = sfc /scannow 2>&1 | Out-String
if ($sfcResult -match "did not find any integrity violations|nao encontrou nenhuma violacao") {
    Write-Output "[OK] SFC: Sistema integro"
} else {
    Write-Output "[INFO] SFC: Verificacao concluida. Veja o log para detalhes."
}

Report-Progress "Limpando cache de componentes (DISM)..."
Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Cleanup-Image /StartComponentCleanup" -Wait -NoNewWindow -ErrorAction SilentlyContinue
Write-Output "[INFO] DISM cleanup concluido"

Report-Progress "Executando Disk Cleanup silencioso..."
# Configurar chaves de limpeza automática
$cleanupKeys = @(
    "Active Setup Temp Folders",
    "Downloaded Program Files",
    "Internet Cache Files",
    "Old ChkDsk Files",
    "Recycle Bin",
    "Setup Log Files",
    "System error memory dump files",
    "System error minidump files",
    "Temporary Files",
    "Temporary Setup Files",
    "Thumbnail Cache",
    "Update Cleanup",
    "Windows Upgrade Log Files"
)
$cleanPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
foreach ($key in $cleanupKeys) {
    $kp = "$cleanPath\$key"
    if (Test-Path $kp) {
        Set-ItemProperty -Path $kp -Name "StateFlags0100" -Value 2 -Type DWord -Force
    }
}
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:100" -Wait -NoNewWindow -ErrorAction SilentlyContinue

Write-Output "[OK] Disco otimizado!"
Write-Output "[DONE] Limpeza de disco concluida."
exit 0
