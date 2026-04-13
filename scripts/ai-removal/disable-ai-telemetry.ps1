# Azucrinaldo BOOST FPS - Desativar Telemetria de IA
$ErrorActionPreference = "SilentlyContinue"
$total = 6
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Desativando telemetria de diagnostico..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force

Report-Progress "Desativando Diagnostics Tracking Service..."
Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue

Report-Progress "Desativando Connected User Experiences..."
Stop-Service -Name "dmwappushservice" -Force -ErrorAction SilentlyContinue
Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue

Report-Progress "Desativando Input Personalization (analise de digitacao)..."
$inputPath = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
if (-not (Test-Path $inputPath)) { New-Item -Path $inputPath -Force | Out-Null }
Set-ItemProperty -Path $inputPath -Name "RestrictImplicitInkCollection" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $inputPath -Name "RestrictImplicitTextCollection" -Value 1 -Type DWord -Force

$trainPath = "$inputPath\TrainedDataStore"
if (-not (Test-Path $trainPath)) { New-Item -Path $trainPath -Force | Out-Null }
Set-ItemProperty -Path $trainPath -Name "HarvestContacts" -Value 0 -Type DWord -Force

Report-Progress "Desativando Advertising ID..."
$advPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
if (-not (Test-Path $advPath)) { New-Item -Path $advPath -Force | Out-Null }
Set-ItemProperty -Path $advPath -Name "Enabled" -Value 0 -Type DWord -Force

Report-Progress "Desativando feedback e experiencias personalizadas..."
$cloudPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-ItemProperty -Path $cloudPath -Name "ContentDeliveryAllowed" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $cloudPath -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $cloudPath -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $cloudPath -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $cloudPath -Name "SubscribedContent-353698Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

Write-Output "[OK] Telemetria e rastreamento de IA desativados!"
Write-Output "[DONE] Privacidade restaurada."
exit 0
