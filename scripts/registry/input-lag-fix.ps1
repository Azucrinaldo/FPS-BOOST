# Azucrinaldo BOOST FPS - Input Lag Fix (Registry)
$ErrorActionPreference = "SilentlyContinue"
$total = 7
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Desativando mouse acceleration (Enhance Pointer Precision)..."
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Force

Report-Progress "Configurando SmoothMouseXCurve e SmoothMouseYCurve (linear 1:1)..."
$linearX = [byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, 0xC0,0xCC,0x0C,0x00,0x00,0x00,0x00,0x00, 0x80,0x99,0x19,0x00,0x00,0x00,0x00,0x00, 0x40,0x66,0x26,0x00,0x00,0x00,0x00,0x00, 0x00,0x33,0x33,0x00,0x00,0x00,0x00,0x00)
$linearY = [byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, 0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00, 0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00, 0x00,0x00,0xA8,0x00,0x00,0x00,0x00,0x00, 0x00,0x00,0xE0,0x00,0x00,0x00,0x00,0x00)
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseXCurve" -Value $linearX -Type Binary -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseYCurve" -Value $linearY -Type Binary -Force

Report-Progress "Ativando End Task na barra de tarefas..."
$devPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings"
if (-not (Test-Path $devPath)) { New-Item -Path $devPath -Force | Out-Null }
Set-ItemProperty -Path $devPath -Name "TaskbarEndTask" -Value 1 -Type DWord -Force

Report-Progress "Configurando prioridade de foreground e Queue Size de periféricos..."
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ForegroundLockTimeout" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Value "1" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillAppTimeout" -Value "2000" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "HungAppTimeout" -Value "1000" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -Force
# Peripheral Queue - Reduce to minimum values to process inputs faster without buffering
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 16 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 16 -Type DWord -Force

Report-Progress "Otimizando Win32 Priority Separation para Foreground..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force # Hex 0x26

Report-Progress "Aplicando Prioridade Máxima de GPU (Registry Games Profile)..."
$gameProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
if (-not (Test-Path $gameProfile)) { New-Item -Path $gameProfile -Force | Out-Null }
Set-ItemProperty -Path $gameProfile -Name "GPU Priority" -Value 8 -Type DWord -Force
Set-ItemProperty -Path $gameProfile -Name "Priority" -Value 6 -Type DWord -Force
Set-ItemProperty -Path $gameProfile -Name "Scheduling Category" -Value "High" -Type String -Force
Set-ItemProperty -Path $gameProfile -Name "Clock Rate" -Value 10000 -Type DWord -Force

Report-Progress "Desativando animacoes visuais desnecessarias..."
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

Write-Output "[OK] Input lag fixes aplicados!"
Write-Output "[INFO] Periféricos ajustados. Menor Buffer, Prioridade Maxima Foreground e GPU"
Write-Output "[DONE] Input lag reduzido severamente."
exit 0
