Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPODefender'
#$Output = Invoke-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExport'

$Output | Format-Table
$Output.Reports | Format-Table
$Output.Reports.WindowsDefenderExploitGuard
#$Output.Reports.RegistrySetting | Format-Table
#$Output.CategoriesFull | Format-Table
<#
$Output.Reports.Policies | Format-Table
$Output.Reports.SecurityOptions | Format-Table
$Output.Reports.PublicKeyPoliciesCertificates | Format-Table
$Output.Reports.PublicKeyPoliciesEnrollmentPolicy | Format-Table
$Output.Reports.PublicKeyPoliciesAuto | Format-Table *
#>

return

# Report to Excel of translated reports
foreach ($Key in $Output.Reports.Keys) {
    $Output.Reports[$Key] | ConvertTo-Excel -FilePath $Env:USERPROFILE\Desktop\GPOAnalysis.xlsx -ExcelWorkSheetName $Key -AutoFilter -AutoFit -FreezeTopRowFirstColumn
}

# Report to HTML of translated reports
New-HTML {
    foreach ($Key in $Output.Reports.Keys) {
        New-HTMLTab -Name $Key {
            New-HTMLTable -DataTable $Output.Reports[$Key] -Filtering
        }
    }
} -FilePath $Env:USERPROFILE\Desktop\GPOAnalysis.html -ShowHTML -Online