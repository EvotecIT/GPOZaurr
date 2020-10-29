Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Step 1 - Create report
$Report = Get-GPOZaurrOwner -IncludeSysvol
$Report | ConvertTo-Excel -FilePath $Env:UserProfile\Desktop\GPOOwners.xlsx -ExcelWorkSheetName 'GPO Owners Before' -AutoFilter -AutoFit

# Step 2 - Fix owners / use WhatIf and LimitProcessing / verify changes before/after
Set-GPOZaurrOwner -Type All -Verbose:$true -WhatIf # -LimitProcessing 2

# Step 3
$Report = Get-GPOZaurrOwner -IncludeSysvol
$Report | ConvertTo-Excel -FilePath $Env:UserProfile\Desktop\GPOOwners.xlsx -ExcelWorkSheetName 'GPO Owners After' -AutoFilter -AutoFit