Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Use Save-GPOZaurrFiles -GPOPath $ENV:USERPROFILE\Desktop\GPOExport
#$OutputNoTranslation = Invoke-GPOZaurr -GPOPath $Env:UserProfile\Desktop\GPOExport -NoTranslation
#$OutputNoTranslation = Invoke-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExportTest' -NoTranslation
$OutputNoTranslation | Format-Table *

<#
New-HTML {
    foreach ($GPOCategory in $OutputNoTranslation.Keys) {
        New-HTMLTab -Name $GPOCategory {
            if ($OutputNoTranslation["$GPOCategory"] -is [System.Collections.IDictionary]) {
                foreach ($GpoSettings in $OutputNoTranslation["$GPOCategory"].Keys) {
                    New-HTMLTab -Name $GpoSettings {
                        New-HTMLTable -DataTable $OutputNoTranslation[$GPOCategory][$GpoSettings] -ScrollX -DisablePaging -AllProperties -Title $GpoSettings
                    }
                }
            } else {
                New-HTMLTable -DataTable $OutputNoTranslation[$GPOCategory] -ScrollX -DisablePaging -AllProperties -Title $GpoSettings
            }
        }
    }
} -Online -ShowHTML -FilePath $Env:UserProfile\Desktop\OutputFromFindGPO-NoTranslationFromDisk.html

#>
foreach ($GPOCategory in $OutputNoTranslation.Keys) {
    if ($OutputNoTranslation["$GPOCategory"] -is [System.Collections.IDictionary]) {
        foreach ($GpoSettings in $OutputNoTranslation["$GPOCategory"].Keys) {
            ConvertTo-Excel -DataTable $OutputNoTranslation[$GPOCategory][$GpoSettings] -AllProperties -ExcelWorkSheetName $GpoSettings -FilePath $Env:UserProfile\Desktop\Export\$GpoSettings.xlsx -AutoFilter -AutoFit
        }
    } else {
        ConvertTo-Excel -DataTable $OutputNoTranslation[$GPOCategory][$GpoSettings] -AllProperties -ExcelWorkSheetName $GpoSettings -FilePath $Env:UserProfile\Desktop\Export\$GpoSettings.xlsx -AutoFilter -AutoFit
    }
}