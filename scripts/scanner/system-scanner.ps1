$ErrorActionPreference = "SilentlyContinue"

# 1. Bloatware (Se não existir XboxGameOverlay, assumimos limpo)
$bloatware = $false
$xbox = Get-AppxPackage *Microsoft.XboxGameOverlay*
if (-not $xbox) { $bloatware = $true }

# 2. AI Removal (Verifica flag principal do Copilot)
$aiRemoval = $false
$copilot = Get-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue
if ($copilot -and $copilot.TurnOffWindowsCopilot -eq 1) { $aiRemoval = $true }
else {
    $recall = Get-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -ErrorAction SilentlyContinue
    if ($recall -and $recall.DisableAIDataAnalysis -eq 1) { $aiRemoval = $true }
}

# 3. Services (SysMain / Superfetch disabled)
$services = $false
$sysMain = Get-Service -Name "SysMain" -ErrorAction SilentlyContinue
if (-not $sysMain -or $sysMain.StartType -eq 'Disabled') { $services = $true }

# 4. Registry (Win32PrioritySeparation = 38 (0x26))
$registry = $false
$priority = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -ErrorAction SilentlyContinue
if ($priority -and $priority.Win32PrioritySeparation -eq 38) { $registry = $true }

# 5. Network (NetworkThrottlingIndex = FFFFFFFF)
$network = $false
$throttling = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -ErrorAction SilentlyContinue
if ($throttling -and $throttling.NetworkThrottlingIndex -eq 4294967295) { $network = $true }

# 6. Power (Active Scheme = Ultimate Performance GUID)
$power = $false
$powerScheme = powercfg /getactivescheme
if ($powerScheme -match "e9a42b02-d5df-448d-aa00-03f14749eb61") { $power = $true }

# 7. Danger Boost (Spectre mitigations disabled)
$dangerBoost = $false
$danger = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "FeatureSettingsOverride" -ErrorAction SilentlyContinue
if ($danger -and $danger.FeatureSettingsOverride -eq 3) { $dangerBoost = $true }

$result = @{
    "bloatware" = $bloatware
    "ai-removal" = $aiRemoval
    "services" = $services
    "registry" = $registry
    "network" = $network
    "power" = $power
    "danger-boost" = $dangerBoost
    "disk" = $false
    "memory" = $false
}

$result | ConvertTo-Json -Compress
