Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Backup GPOs
$BackupPath = "$Env:UserProfile\Desktop\GPO"
$GPOSummary = Backup-GPOZaurr -BackupPath $BackupPath -Verbose -Type All #-BackupDated #-LimitProcessing 1
$GPOSummary | Format-Table -AutoSize

## Confirm GPOs are backed up properly
Get-GPOZaurrBackupInformation -BackupFolder $GPOSummary[0].BackupDirectory | Format-Table -a