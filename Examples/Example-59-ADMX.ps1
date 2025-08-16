Import-Module .\GPOZaurr.psd1 -Force

$DirectoryPath = "C:\Support\GitHub\GpoZaurr\Data\ADMXTemplates"
$Paths = @(
    [PSCustomObject] @{ Name = "Citrix"; Path = "C:\Program Files (x86)\Citrix\ICA Client\Configuration"; ExportFile = "Citrix" }
    [PSCustomObject] @{ Name = "Remote Desktop Manager"; Path = "C:\Program Files\Devolutions\Remote Desktop Manager\Policies" ; ExportFile = "Remote Desktop Manager" }
    [PSCustomObject] @{ Name = "Microsoft Windows 2022 Security Baseline"; Path = "C:\Users\przemyslaw.klys\Downloads\GPO\Windows Server 2022 Security Baseline\Windows Server-2022-Security-Baseline-FINAL\Templates" ; ExportFile = "Windows Server 2022 Security Baseline" }
    [PSCustomObject] @{ Name = "Microsoft OneDrive"; Path = "C:\Program Files\Microsoft OneDrive\24.216.1027.0003\adm" ; ExportFile = "Microsoft OneDrive" }
    [PSCustomObject] @{ Name = "Microsoft PowerShell 7 Core"; Path = "C:\Program Files\PowerShell\7" ; ExportFile = "Microsoft PowerShell 7" }
    [PSCustomObject] @{ Name = "Microsoft Windows 11 (24H2) September 2024"; Path = "C:\Program Files (x86)\Microsoft Group Policy\Windows 11 Sep 2024 Update (24H2)" ; ExportFile = "Microsoft Windows11 24H2 September 2024" }
)
foreach ($Path in $Paths) {
    $InitializeGPOZaurrTemplateSplat = @{
        Path       = $Path.Path
        Name       = $Path.Name
        ExportPath = "$DirectoryPath\$($Path.ExportFile).json"
    }
    $List = Initialize-GPOZaurrTemplate @InitializeGPOZaurrTemplateSplat -Verbose
}