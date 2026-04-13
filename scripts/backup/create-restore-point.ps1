# Azucrinaldo BOOST FPS - Criar Ponto de Restauração
# Requer execução como Administrador

$ErrorActionPreference = "Stop"
$total = 3
$current = 0

function Report-Progress {
    param([string]$msg)
    $script:current++
    Write-Output "[PROGRESS] $script:current/$total $msg"
}

try {
    Report-Progress "Habilitando proteção do sistema..."
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue

    Report-Progress "Bypass no limite de 24h do Windows..."
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f | Out-Null

    Report-Progress "Criando ponto de restauração..."
    Checkpoint-Computer -Description "Azucrinaldo BOOST FPS - Backup de Seguranca" -RestorePointType "MODIFY_SETTINGS"

    Report-Progress "Verificando ponto criado..."
    $rp = Get-ComputerRestorePoint | Sort-Object -Property SequenceNumber -Descending | Select-Object -First 1
    Write-Output "[OK] Ponto de restauracao criado: $($rp.Description)"
    Write-Output "[INFO] Numero sequencial: $($rp.SequenceNumber)"
    Write-Output "[DONE] Backup concluido com sucesso!"
    exit 0
} catch {
    Write-Output "[ERROR] Falha ao criar ponto de restauracao: $($_.Exception.Message)"
    Write-Output "[INFO] Certifique-se de executar como Administrador."
    exit 1
}
