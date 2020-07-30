Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Asses GPO based on exported data
$Output = Invoke-GPOZaurr -GPOPath $Env:USERPROFILE\Desktop\GPOExport -Verbose
#$Output = Invoke-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExportTest' -Verbose
$Output | Format-Table *

# Export to Excel
foreach ($Key in $Output.Reports.Keys) {
    $Output.Reports[$Key] | ConvertTo-Excel -FilePath $Env:USERPROFILE\Desktop\EFGPOAnalysis.xlsx -ExcelWorkSheetName $Key -AutoFilter -AutoFit -FreezeTopRowFirstColumn
}