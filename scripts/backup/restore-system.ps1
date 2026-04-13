# Azucrinaldo BOOST FPS - RollBack: Restaurar Sistema
$ErrorActionPreference = "Stop"

try {
    $restorePoint = Get-ComputerRestorePoint | Where-Object {
        $_.Description -like "*Azucrinaldo*"
    } | Sort-Object -Property SequenceNumber -Descending | Select-Object -First 1

    if ($restorePoint) {
        Write-Output "[INFO] Restaurando para: $($restorePoint.Description)"
        Write-Output "[INFO] Criado em: $($restorePoint.CreationTime)"
        Write-Output "[WARNING] O computador vai REINICIAR em 10 segundos..."
        Write-Output "[PROGRESS] 1/2 Preparando restauracao..."
        Start-Sleep -Seconds 10
        Write-Output "[PROGRESS] 2/2 Iniciando restauracao do sistema..."
        Restore-Computer -RestorePoint $restorePoint.SequenceNumber -Confirm:$false
        Write-Output "[DONE] Restauracao iniciada. O sistema vai reiniciar."
        exit 0
    } else {
        Write-Output "[ERROR] Nenhum ponto de restauracao do Azucrinaldo encontrado!"
        exit 1
    }
} catch {
    Write-Output "[ERROR] Falha na restauracao: $($_.Exception.Message)"
    exit 1
}
