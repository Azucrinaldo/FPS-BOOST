# Azucrinaldo BOOST FPS - Verificar Ponto de Restauração
$rp = Get-ComputerRestorePoint -ErrorAction SilentlyContinue | Where-Object {
    $_.Description -like "*Azucrinaldo*"
} | Sort-Object -Property SequenceNumber -Descending | Select-Object -First 1

if ($rp) {
    Write-Output "[OK] Ponto encontrado: $($rp.Description)"
    exit 0
} else {
    Write-Output "[WARNING] Nenhum ponto de restauracao Azucrinaldo encontrado."
    exit 1
}
