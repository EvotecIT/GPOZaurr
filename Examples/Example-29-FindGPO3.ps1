Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Use Save-GPOZaurrFiles -GPOPath $ENV:USERPROFILE\Desktop\GPOExportAudit

# This will allow you to process offline data more than once
# It's useful for when you want to request different types
$Output = Invoke-GPOZaurrContent -GPOPath $ENV:USERPROFILE\Desktop\GPOExportAudit -Extended -Verbose
$Output | Format-Table *
$Output.Reports | Format-Table

# Export to Excel
foreach ($Key in $Output.Reports.Keys) {
    $Output.Reports[$Key] | ConvertTo-Excel -FilePath $Env:USERPROFILE\Desktop\GPOAnalysis.xlsx -ExcelWorkSheetName $Key -AutoFilter -AutoFit -FreezeTopRowFirstColumn
}
Start-Process "$Env:USERPROFILE\Desktop\GPOAnalysis.xlsx"