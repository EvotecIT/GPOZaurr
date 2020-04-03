Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Backup GPOs
$BackupPath = "$Env:UserProfile\Desktop\GPO"
$GPOSummary = Backup-GPOZaurr -BackupPath $BackupPath -Verbose -Type EmptyAndUnlinked
$GPOSummary | Format-Table -AutoSize

# Confirm GPOs are backed up properly
#Get-GPOZaurrBackupInformation -BackupFolder $GPOSummary[0].BackupDirectory | Format-Table -a

# Remove GPOS
Remove-GPOZaurr -Type EmptyAndUnlinked -Verbose