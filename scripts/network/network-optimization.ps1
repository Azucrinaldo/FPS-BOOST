# Azucrinaldo BOOST FPS - Otimização de Rede
$ErrorActionPreference = "SilentlyContinue"
$total = 6
$current = 0

function Report-Progress { param([string]$msg); $script:current++; Write-Output "[PROGRESS] $script:current/$total $msg" }

Report-Progress "Desativando Nagle Algorithm (TCP_NODELAY)..."
# Encontrar interfaces de rede ativas
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($adapter in $adapters) {
    $interfaceGuid = $adapter.InterfaceGuid
    $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$interfaceGuid"
    if (Test-Path $tcpPath) {
        Set-ItemProperty -Path $tcpPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $tcpPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $tcpPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force
        Write-Output "[INFO] Nagle desativado na interface: $($adapter.Name)"
    }
}

Report-Progress "Otimizando parametros TCP globais..."
netsh int tcp set global autotuninglevel=normal 2>$null
netsh int tcp set global chimney=disabled 2>$null
netsh int tcp set global ecncapability=disabled 2>$null
netsh int tcp set global timestamps=disabled 2>$null
netsh int tcp set global rss=enabled 2>$null

Report-Progress "Configurando DNS para Cloudflare (1.1.1.1)..."
foreach ($adapter in $adapters) {
    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ("1.1.1.1","1.0.0.1") -ErrorAction SilentlyContinue
}

Report-Progress "Desativando Large Send Offload..."
foreach ($adapter in $adapters) {
    Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "*LSOv2IPv4" -RegistryValue 0 -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "*LSOv2IPv6" -RegistryValue 0 -ErrorAction SilentlyContinue
}

Report-Progress "Otimizando porta de rede (Direct Cache Access)..."
netsh int tcp set supplemental template=internet congestionprovider=ctcp 2>$null

Report-Progress "Limpando cache ARP e rotas..."
netsh interface ip delete arpcache 2>$null
ipconfig /flushdns | Out-Null

Write-Output "[OK] Rede otimizada!"
Write-Output "[INFO] Nagle OFF, TcpAckFrequency=1, DNS=1.1.1.1, LSO OFF"
Write-Output "[DONE] Configurações de rede para menor latência aplicadas."
exit 0
