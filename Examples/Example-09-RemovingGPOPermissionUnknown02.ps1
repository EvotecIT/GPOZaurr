Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Step 1 - Create report
$Report = Get-GPOZaurrPermission -Type All
$Report | ConvertTo-Excel -FilePath $Env:UserProfile\Desktop\GPOOutput.xlsx -ExcelWorkSheetName 'GPO Permissions Before' -AutoFilter -AutoFit

# Step 2 - Verify couple of GPOS returned with whatif
#Remove-GPOZaurrPermission -Verbose -Type Unknown -LimitProcessing 4 -WhatIf

# Step 3 - Confirm the change without whatif
#Remove-GPOZaurrPermission -Verbose -Type Unknown -LimitProcessing 4

# Step 4 - Analyze GPO manually to confirm only unknown sids were removed

# Step 5 - if everything went ok, continue process without whatif

# Step-6 - Generate new report
#$Report = Get-GPOZaurrPermission -Type All
#$Report | ConvertTo-Excel -FilePath $Env:UserProfile\Desktop\GPOOutput.xlsx -ExcelWorkSheetName 'GPO Permissions After' -AutoFilter -AutoFit