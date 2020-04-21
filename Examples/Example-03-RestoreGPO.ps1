Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$RestoreFrom = 'C:\Users\przemyslaw.klys\Desktop\GPO\2020-04-20_15_51_00'

$BackupInformation = Get-GPOZaurrBackupInformation -BackupFolder $RestoreFrom
$BackupInformation | Format-Table -a

# restore all gpos
$RestoredGPOs = Restore-GPOZaurr -BackupFolder $RestoreFrom -Verbose
$RestoredGPOs | Format-Table -AutoSize

# restore just one Gpo
#$RestoredGPOs = Restore-GPOZaurr -BackupFolder $RestoreFrom -Verbose -DisplayName 'Users | Synced Office 365 Users'
#$RestoredGPOs | Format-Table -AutoSize