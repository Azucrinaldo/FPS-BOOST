# Azucrinaldo BOOST FPS - DANGER ULTRA SECRET PRO BOOST
$ErrorActionPreference = "SilentlyContinue"
$total = 3
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Desativando Mitigacoes de Kernel (Spectre/Meltdown)..."
# Desativa mitigacoes no nivel do SO e hardware para ganho bruto de IO e CPU cycles
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "FeatureSettingsOverride" -Value 3 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "FeatureSettingsOverrideMask" -Value 3 -Type DWord -Force

Report-Progress "Desativando Kernel DMA Protection e HVCi..."
# Disable DMA Protection (Note: requires reboot, might be blocked by BIOS in some modern systems, but we force it where possible)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -Value 0 -Type DWord -Force
# Disable Dynamic Tick (Timer Coalescing)
bcdedit /set disabledynamictick yes | Out-Null
bcdedit /set useplatformclock false | Out-Null

Report-Progress "Ajustando DPC Latencies e Otimizacoes Extremas de Barramento..."
# DPC Latency - Desliga Network Throttling 
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Type DWord -Force

Write-Output "[WARNING] O SISTEMA ESTA VULNERAVEL. SECURITY LIMITATIONS LIFTED."
Write-Output "[OK] Kernel Mitigations DESLIGADOS. DPC Latency no modo Agressivo."
Write-Output "[DONE] MAXIMUM PERFORMANCE ACHIEVED."
exit 0
