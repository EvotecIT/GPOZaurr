Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Use Save-GPOZaurrFiles -GPOPath $ENV:USERPROFILE\Desktop\GPOExport

$Output = Find-GPO -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExportTest'
$Output | Format-Table *

New-HTML {
    foreach ($Key in $Output.Keys) {
        New-HTMLTab -Name $Key {
            New-HTMLTable -DataTable $Output[$Key] -ScrollX -DisablePaging -AllProperties -Title $Key
        }
    }
} -Online -ShowHTML -FilePath $Env:UserProfile\Desktop\OutputFromFindGPO.html