# Azucrinaldo BOOST FPS - Desativar Serviços Desnecessários
$ErrorActionPreference = "SilentlyContinue"

$services = @(
    @{Name="SysMain"; Desc="Superfetch - pre-carrega apps (consome I/O)"},
    @{Name="WSearch"; Desc="Windows Search Indexing (I/O constante)"},
    @{Name="DiagTrack"; Desc="Diagnostics Tracking (telemetria)"},
    @{Name="dmwappushservice"; Desc="Push WAP Message Routing (telemetria)"},
    @{Name="MapsBroker"; Desc="Downloaded Maps Manager"},
    @{Name="lfsvc"; Desc="Geolocation Service"},
    @{Name="SharedAccess"; Desc="Internet Connection Sharing"},
    @{Name="RemoteRegistry"; Desc="Remote Registry"},
    @{Name="RemoteAccess"; Desc="Routing and Remote Access"},
    @{Name="Fax"; Desc="Fax Service"},
    @{Name="XblAuthManager"; Desc="Xbox Live Auth Manager"},
    @{Name="XblGameSave"; Desc="Xbox Live Game Save"},
    @{Name="XboxNetApiSvc"; Desc="Xbox Live Networking Service"},
    @{Name="XboxGipSvc"; Desc="Xbox Accessory Management"},
    @{Name="WMPNetworkSvc"; Desc="Windows Media Player Network Sharing"},
    @{Name="icssvc"; Desc="Mobile Hotspot Service"},
    @{Name="WerSvc"; Desc="Windows Error Reporting"},
    @{Name="wisvc"; Desc="Windows Insider Service"},
    @{Name="RetailDemo"; Desc="Retail Demo Service"},
    @{Name="MessagingService"; Desc="Messaging Service"},
    @{Name="PcaSvc"; Desc="Program Compatibility Assistant"},
    @{Name="TabletInputService"; Desc="Touch Keyboard and Handwriting"}
)

$total = $services.Count
$current = 0

Write-Output "[INFO] Desativando $total servicos desnecessarios..."

foreach ($svc in $services) {
    $current++
    Write-Output "[PROGRESS] $current/$total Desativando $($svc.Name) - $($svc.Desc)"
    Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
    Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
}

Write-Output "[OK] $total servicos desativados!"
Write-Output "[INFO] Servicos do Xbox, telemetria, indexacao e outros foram parados."
Write-Output "[DONE] Servicos otimizados para gaming."
exit 0
