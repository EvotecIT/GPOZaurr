Clear-Host
Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrFiles -Type All | Out-HtmlView -ScrollX -Filtering -AllProperties
#Get-GPOZaurrFiles -HashAlgorithm MD5 | Select-Object -First 2 | ConvertTo-Excel -FilePath $Env:USERPROFILE\Desktop\GPOListFiles.xlsx -AllProperties -ExcelWorkSheetName 'Files Just 2' -AutoFilter -AutoFit #-OpenWorkBook
#Get-GPOZaurrFiles -Type All -HashAlgorithm SHA256 | ConvertTo-Excel -FilePath $Env:USERPROFILE\Desktop\GPOListFiles.xlsx -AllProperties -ExcelWorkSheetName 'Files All' -AutoFilter -AutoFit #-OpenWorkBook