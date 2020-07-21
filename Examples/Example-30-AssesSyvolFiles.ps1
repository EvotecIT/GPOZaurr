Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Files = Get-GPOZaurrFiles -Limited -Signature
$Files | ConvertTo-Excel -OpenWorkBook -FilePath $Env:USERPROFILE\Desktop\GPOTesting.xlsx -ExcelWorkSheetName 'GPO Output' -AutoFilter -AutoFit -FreezeTopRowFirstColumn