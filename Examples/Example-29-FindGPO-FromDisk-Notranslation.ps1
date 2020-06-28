Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Use Save-GPOZaurrFiles -GPOPath $ENV:USERPROFILE\Desktop\GPOExport

$OutputNoTranslation = Invoke-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExportTest' -NoTranslation
$OutputNoTranslation | Format-Table *

New-HTML {
    foreach ($GPOCategory in $OutputNoTranslation.Keys) {
        New-HTMLTab -Name $GPOCategory {
            if ($Output["$GPOCategory"] -is [System.Collections.IDictionary]) {
                foreach ($GpoSettings in $OutputNoTranslation["$GPOCategory"].Keys) {
                    New-HTMLTab -Name $GpoSettings {
                        New-HTMLTable -DataTable $OutputNoTranslation[$GPOCategory][$GpoSettings] -ScrollX -DisablePaging -AllProperties -Title $Key
                    }
                }
            } else {
                New-HTMLTable -DataTable $OutputNoTranslation[$GPOCategory] -ScrollX -DisablePaging -AllProperties -Title $Key
            }
        }
    }
} -Online -ShowHTML -FilePath $Env:UserProfile\Desktop\OutputFromFindGPO-NoTranslationFromDisk.html