Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Use Save-GPOZaurrFiles -GPOPath $ENV:USERPROFILE\Desktop\GPOExportAudit
$Output = Invoke-GPOZaurr -GPOPath $ENV:USERPROFILE\Desktop\GPOExportAudit -Verbose #-SkipCleanup #-Type PoliciesPrinters, Policies
$Output | Format-Table *

$Output.Reports | Format-Table

# Export to Excel
foreach ($Key in $Output.Reports.Keys) {
    $Output.Reports[$Key] | ConvertTo-Excel -FilePath $Env:USERPROFILE\Desktop\GPOAnalysis.xlsx -ExcelWorkSheetName $Key -AutoFilter -AutoFit -FreezeTopRowFirstColumn
}
Start-Process "$Env:USERPROFILE\Desktop\GPOAnalysis.xlsx"