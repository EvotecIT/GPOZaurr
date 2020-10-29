Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Remove GPOS
Remove-GPOZaurr -Type Empty, Unlinked -BackupPath "$Env:UserProfile\Desktop\GPO" -BackupDated -LimitProcessing 2 -Verbose -WhatIf