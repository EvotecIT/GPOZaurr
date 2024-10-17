Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Files = Get-GPOZaurrFiles -Type All -Verbose
#$Files | ConvertTo-Excel -OpenWorkBook -FilePath $Env:USERPROFILE\Desktop\GPOTesting.xlsx -ExcelWorkSheetName 'GPO Output' -AutoFilter -AutoFit -FreezeTopRowFirstColumn
$Files | Format-Table