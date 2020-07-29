Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Report on empty folders
Get-GPOZaurrFolders -FolderType Empty | Format-Table *

# ! NOT READY FOR EMPTY
#Remove-GPOZaurrFolders -FolderType Empty -Verbose -BackupPath $Env:USERPROFILE\Desktop\SomeBackup1 -WhatIf