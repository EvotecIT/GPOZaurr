Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Remove-GPOZaurrLegacyFiles -Verbose -BackupPath $Env:USERPROFILE\Desktop\BackupADM1 -BackupDated -RemoveEmptyFolders #-WhatIf #-LimitProcessing 2 -WhatIf