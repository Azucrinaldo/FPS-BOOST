# Azucrinaldo BOOST FPS - Privacy Registry Tweaks
$ErrorActionPreference = "SilentlyContinue"
$total = 5
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Desativando Windows Tips e sugestoes..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Value 0 -Type DWord -Force

Report-Progress "Desativando Location Tracking..."
$locPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
if (Test-Path $locPath) { Set-ItemProperty -Path $locPath -Name "Value" -Value "Deny" -Force }

Report-Progress "Desativando Activity History..."
$actPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
if (-not (Test-Path $actPath)) { New-Item -Path $actPath -Force | Out-Null }
Set-ItemProperty -Path $actPath -Name "EnableActivityFeed" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $actPath -Name "PublishUserActivities" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $actPath -Name "UploadUserActivities" -Value 0 -Type DWord -Force

Report-Progress "Desativando apps em background..."
$bgPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
if (-not (Test-Path $bgPath)) { New-Item -Path $bgPath -Force | Out-Null }
Set-ItemProperty -Path $bgPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force

$bgSearch = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
Set-ItemProperty -Path $bgSearch -Name "BackgroundAppGlobalToggle" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

Report-Progress "Desativando clipboard cloud sync..."
$clipPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
Set-ItemProperty -Path $clipPath -Name "AllowClipboardHistory" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $clipPath -Name "AllowCrossDeviceClipboard" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

Write-Output "[OK] Privacy tweaks aplicados!"
Write-Output "[INFO] Tips/sugestoes OFF, Location OFF, Activity History OFF, Background Apps OFF"
Write-Output "[DONE] Privacidade reforçada."
exit 0
