# Azucrinaldo BOOST FPS - Desativar USB Selective Suspend
$ErrorActionPreference = "SilentlyContinue"
$total = 3
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Desativando USB Selective Suspend no plano ativo..."
# Get active power scheme
$activeScheme = powercfg -getactivescheme
if ($activeScheme -match "([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})") {
    $schemeGuid = $Matches[1]
    # USB Selective Suspend: SubGroup=2a737441-1930-4402-8d77-b2bebba308a3, Setting=48e6b7a6-50f5-4782-a5d4-53bb8f07e226
    powercfg -setacvalueindex $schemeGuid 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg -setdcvalueindex $schemeGuid 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg -setactive $schemeGuid
    Write-Output "[OK] USB Selective Suspend desativado no plano $schemeGuid"
}

Report-Progress "Desativando gerenciamento de energia em USB Root Hubs..."
Get-PnpDevice -Class USB -ErrorAction SilentlyContinue | Where-Object {
    $_.FriendlyName -like "*Root Hub*" -or $_.FriendlyName -like "*Hub Raiz*"
} | ForEach-Object {
    $deviceId = $_.InstanceId
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\$deviceId\Device Parameters"
    if (Test-Path $regPath) {
        Set-ItemProperty -Path $regPath -Name "EnhancedPowerManagementEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "SelectiveSuspendEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    }
}

Report-Progress "Desativando PCI Express Link State Power Management..."
if ($schemeGuid) {
    # PCI Express: SubGroup=501a4d13-42af-4429-9fd1-a8218c268e20, Setting=ee12f906-d277-404b-b6da-e5fa1a576df5
    powercfg -setacvalueindex $schemeGuid 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
    powercfg -setdcvalueindex $schemeGuid 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
    powercfg -setactive $schemeGuid
}

Write-Output "[OK] USB e PCI Express power management desativados!"
Write-Output "[INFO] Mouse/teclado nao vao dormir durante o jogo."
Write-Output "[DONE] Energia USB otimizada."
exit 0
