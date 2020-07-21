Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# this allows you to process X amount of orphaned folders/files (good for testing)
Remove-GPOZaurrOrphanedSysvolFolders -Verbose -WhatIf -LimitProcessing 2 -IncludeDomains 'ad.evotec.xyz'

# this runs for whole SYSVOL and checks things against GPOS
Remove-GPOZaurrOrphanedSysvolFolders -Verbose -IncludeDomains 'ad.evotec.xyz' -BackupPath $Env:UserProfile\Desktop\MyBackup -WhatIf