Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# this allows you to process X amount of orphaned folders/files (good for testing)
Remove-GPOZaurrOrphaned -Verbose -WhatIf -IncludeDomains 'ad.evotec.xyz' #-LimitProcessing 2

# this runs for whole SYSVOL and checks things against GPOS
Remove-GPOZaurrOrphaned -Verbose -IncludeDomains 'ad.evotec.xyz' -BackupPath $Env:UserProfile\Desktop\MyBackup1 -WhatIf