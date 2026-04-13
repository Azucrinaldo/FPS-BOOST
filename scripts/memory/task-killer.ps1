# Azucrinaldo BOOST FPS - Task Killer (retorna JSON de processos pesados)
$ErrorActionPreference = "SilentlyContinue"

# Lista processos com mais de 80MB de RAM, excluindo processos essenciais
$essential = @("System", "Registry", "smss", "csrss", "wininit", "services", "lsass", "svchost",
               "dwm", "explorer", "winlogon", "fontdrvhost", "sihost", "taskhostw",
               "RuntimeBroker", "SearchHost", "StartMenuExperienceHost", "ShellExperienceHost",
               "TextInputHost", "ctfmon", "conhost", "SecurityHealthService",
               "MsMpEng", "NisSrv", "Azucrinaldo", "electron")

$procs = Get-Process | Where-Object {
    ($_.WorkingSet64 / 1MB) -gt 80 -and
    $essential -notcontains $_.Name
} | Sort-Object -Property WorkingSet64 -Descending | Select-Object -First 30

$result = @()
foreach ($p in $procs) {
    $cpuUsage = "-"
    try {
        $perf = Get-Counter "\Process($($p.Name))\% Processor Time" -ErrorAction SilentlyContinue
        if ($perf) {
            $cpuUsage = [math]::Round($perf.CounterSamples[0].CookedValue, 1)
        }
    } catch { }

    $result += @{
        Name = $p.Name
        PID = $p.Id
        RAM = [math]::Round($p.WorkingSet64 / 1MB, 1)
        CPU = $cpuUsage
    }
}

$result | ConvertTo-Json -Compress
