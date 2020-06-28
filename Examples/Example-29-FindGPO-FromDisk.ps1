Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Use Save-GPOZaurrFiles -GPOPath $ENV:USERPROFILE\Desktop\GPOExport

$Output = Invoke-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExportTest'
$Output | Format-Table *

New-HTML {
    foreach ($GPOCategory in $Output.Keys) {
        New-HTMLTab -Name $GPOCategory {
            if ($Output["$GPOCategory"] -is [System.Collections.IDictionary]) {
                foreach ($GpoSettings in $Output["$GPOCategory"].Keys) {
                    New-HTMLTab -Name $GpoSettings {
                        New-HTMLTable -DataTable $Output[$GPOCategory][$GpoSettings] -ScrollX -DisablePaging -AllProperties -Title $Key
                    }
                }
            } else {
                New-HTMLTable -DataTable $Output[$GPOCategory] -ScrollX -DisablePaging -AllProperties -Title $Key
            }
        }
    }
} -Online -ShowHTML -FilePath $Env:UserProfile\Desktop\OutputFromFindGPO-FromDisk.html