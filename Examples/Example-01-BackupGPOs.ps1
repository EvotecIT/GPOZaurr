Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Backup GPOs
$GPOSummary = Backup-GPOZaurr -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -Type All -IncludeDomains 'ad.evotec.pl' #-BackupDated #-LimitProcessing 1
$GPOSummary | Format-Table -AutoSize

## Confirm GPOs are backed up properly
Get-GPOZaurrBackupInformation -BackupFolder $GPOSummary[0].BackupDirectory | Format-Table -a