Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurr -NoTranslation
$Output | Format-Table

New-HTML {
    foreach ($GPOCategory in $Output.Keys) {
        New-HTMLTab -Name $GPOCategory {
            if ($Output["$GPOCategory"] -is [System.Collections.IDictionary]) {
                foreach ($GpoSettings in $Output["$GPOCategory"].Keys) {
                    New-HTMLTab -Name $GpoSettings {
                        New-HTMLTable -DataTable $Output[$GPOCategory][$GpoSettings] -ScrollX -DisablePaging -AllProperties -Title $GpoSettings
                    }
                }
            } else {
                New-HTMLTable -DataTable $Output[$GPOCategory] -ScrollX -DisablePaging -AllProperties -Title $GpoSettings
            }
        }
    }
} -Online -ShowHTML -FilePath $Env:UserProfile\Desktop\OutputFromFindGPO-NoTranslation.html