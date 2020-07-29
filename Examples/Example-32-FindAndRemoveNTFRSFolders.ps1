Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Report on NTFRS folders
Get-GPOZaurrFolders -FolderType NTFRS | Format-Table *

# Remove NTFRS (broken replication folders)
Remove-GPOZaurrFolders -FolderType NTFRS -Verbose -BackupPath $Env:USERPROFILE\Desktop\SomeBackup -WhatIf