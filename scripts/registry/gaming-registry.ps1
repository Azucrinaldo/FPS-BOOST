# Azucrinaldo BOOST FPS - Gaming Registry Tweaks
# Win32PrioritySeparation, MMCSS, NetworkThrottling, GameDVR
$ErrorActionPreference = "SilentlyContinue"
$total = 8
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Configurando Win32PrioritySeparation (0x26)..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force

Report-Progress "Configurando SystemResponsiveness (10%)..."
$mmcssPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
Set-ItemProperty -Path $mmcssPath -Name "SystemResponsiveness" -Value 10 -Type DWord -Force

Report-Progress "Desativando NetworkThrottlingIndex..."
Set-ItemProperty -Path $mmcssPath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force

Report-Progress "Configurando prioridade de tarefas de jogos..."
$gamesPath = "$mmcssPath\Tasks\Games"
if (-not (Test-Path $gamesPath)) { New-Item -Path $gamesPath -Force | Out-Null }
Set-ItemProperty -Path $gamesPath -Name "GPU Priority" -Value 8 -Type DWord -Force
Set-ItemProperty -Path $gamesPath -Name "Priority" -Value 6 -Type DWord -Force
Set-ItemProperty -Path $gamesPath -Name "Scheduling Category" -Value "High" -Type String -Force
Set-ItemProperty -Path $gamesPath -Name "SFIO Priority" -Value "High" -Type String -Force

Report-Progress "Desativando Game DVR/Game Bar..."
$gameDvrPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
if (-not (Test-Path $gameDvrPath)) { New-Item -Path $gameDvrPath -Force | Out-Null }
Set-ItemProperty -Path $gameDvrPath -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force
$gameStorePath = "HKCU:\System\GameConfigStore"
if (-not (Test-Path $gameStorePath)) { New-Item -Path $gameStorePath -Force | Out-Null }
Set-ItemProperty -Path $gameStorePath -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $gameStorePath -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force
Set-ItemProperty -Path $gameStorePath -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $gameStorePath -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force

Report-Progress "Ativando Game Mode..."
$gameModePath = "HKCU:\SOFTWARE\Microsoft\GameBar"
if (-not (Test-Path $gameModePath)) { New-Item -Path $gameModePath -Force | Out-Null }
Set-ItemProperty -Path $gameModePath -Name "AllowAutoGameMode" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $gameModePath -Name "AutoGameModeEnabled" -Value 1 -Type DWord -Force

Report-Progress "Desativando Fullscreen Optimizations globalmente..."
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue

Report-Progress "Configurando BCD timers para menor latencia DPC..."
Start-Process -FilePath "bcdedit.exe" -ArgumentList "/deletevalue useplatformtick" -Wait -NoNewWindow -ErrorAction SilentlyContinue
Start-Process -FilePath "bcdedit.exe" -ArgumentList "/set tscsyncpolicy enhanced" -Wait -NoNewWindow -ErrorAction SilentlyContinue
Start-Process -FilePath "bcdedit.exe" -ArgumentList "/set disabledynamictick yes" -Wait -NoNewWindow -ErrorAction SilentlyContinue

Write-Output "[OK] Registry gaming tweaks aplicados!"
Write-Output "[INFO] Win32PrioritySeparation=0x26, SystemResponsiveness=10, NetworkThrottling=OFF"
Write-Output "[INFO] Game DVR desativado, Game Mode ativado, BCD timers otimizados"
Write-Output "[DONE] Registro otimizado para gaming."
exit 0
