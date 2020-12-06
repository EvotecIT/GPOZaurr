Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Backup GPOs
$GPOSummary = Backup-GPOZaurr -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -Type Disabled, Empty -IncludeDomains 'ad.evotec.pl' #-BackupDated #-LimitProcessing 1
$GPOSummary | Format-Table -AutoSize

## Confirm GPOs are backed up properly, assuming everything was done
if ($GPOSummary) {
    Get-GPOZaurrBackupInformation -BackupFolder $GPOSummary[0].BackupDirectory | Format-Table -a
} else {
    Write-Warning "Backup wasn't done, or there was nothing to backup. "
}