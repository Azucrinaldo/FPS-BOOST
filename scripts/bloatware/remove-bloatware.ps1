# Azucrinaldo BOOST FPS - Remover Bloatware do Windows
$ErrorActionPreference = "SilentlyContinue"

$bloatware = @(
    "Microsoft.BingWeather",
    "Microsoft.BingNews",
    "Microsoft.BingFinance",
    "Microsoft.BingSports",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MixedReality.Portal",
    "Microsoft.People",
    "Microsoft.SkypeApp",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.YourPhone",
    "Microsoft.WindowsMaps",
    "Microsoft.Todos",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.Office.OneNote",
    "Clipchamp.Clipchamp",
    "Microsoft.549981C3F5F10",
    "MicrosoftTeams",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.WindowsCamera",
    "microsoft.windowscommunicationsapps",
    "Microsoft.GamingApp",
    "Microsoft.OutlookForWindows",
    "Microsoft.Paint",
    "Microsoft.ScreenSketch"
)

$total = $bloatware.Count
$current = 0

Write-Output "[INFO] Iniciando remocao de $total bloatwares..."

foreach ($app in $bloatware) {
    $current++
    Write-Output "[PROGRESS] $current/$total Removendo $app..."

    # Remove para o usuário atual
    Get-AppxPackage -Name $app -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue

    # Remove para todos os usuários (previne reinstalação)
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -eq $app } |
        Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

Write-Output "[OK] Remocao de bloatware concluida!"
Write-Output "[INFO] $total aplicativos processados."
Write-Output "[DONE] Bloatware removido com sucesso."
exit 0
