Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Remove GPOS
$BackupPath = "$Env:UserProfile\Desktop\GPO"
Remove-GPOZaurr -Type Empty, Unlinked -BackupPath $BackupPath -BackupDated -LimitProcessing 2 -Verbose