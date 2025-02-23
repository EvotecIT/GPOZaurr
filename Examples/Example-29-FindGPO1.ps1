Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force


#$O = Invoke-GPOZaurrContent -GPOName "Test-RestrictedGroups" -Verbose
#$O

Invoke-GPOZaurr -Online -Type GPOBroken, GPOBrokenLink -Verbose -SplitReports

return

#$Output = Invoke-GPOZaurrContent -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPODefender'
$Output = Invoke-GPOZaurrContent -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExport' -Type WindowsHelloForBusiness
$Output | Format-Table
$Output.WindowsDefenderExploitGuard | Format-Table
$Output.Reports.RegistrySetting | Format-Table

# Report to Excel of translated reports
foreach ($Key in $Output.Keys) {
    $Output[$Key] | ConvertTo-Excel -FilePath $Env:USERPROFILE\Desktop\GPOAnalysis.xlsx -ExcelWorkSheetName $Key -AutoFilter -AutoFit -FreezeTopRowFirstColumn
}

# Report to HTML of translated reports
New-HTML {
    New-HTMLTableOption -DataStore JavaScript
    foreach ($Key in $Output.Keys) {
        New-HTMLTab -Name $Key {
            New-HTMLTable -DataTable $Output[$Key] -Filtering -Title $Key
        }
    }
} -FilePath $Env:USERPROFILE\Desktop\GPOAnalysis.html -ShowHTML -Online