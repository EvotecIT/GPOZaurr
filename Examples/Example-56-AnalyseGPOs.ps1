Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurrContent -Verbose -GPOName 'Default Domain Policy'
$Output | Format-Table

<#
# You need PSWriteOffice for that
foreach ($Key in $Output.Keys) {
    $Output[$Key] | Export-OfficeExcel -FilePath $Env:USERPROFILE\Desktop\GPOAnalysis.xlsx -WorkSheetName $Key
}

Invoke-GPOZaurr -Type GPOAnalysis -GPOName 'ALL | Allow use of biometrics', 'ALL | Enable RDP' -GPOGUID '{31B2F340-016D-11D2-945F-00C04FB984F9}' -IncludeDomains 'ad.evotec.xyz' -Verbose

#>