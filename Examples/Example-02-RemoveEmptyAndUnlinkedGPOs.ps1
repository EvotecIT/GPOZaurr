Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Remove GPOS, but don't touch 2 defined exclusions
$ExcludeGroupPolicies = {
    'TEST | Drive Mapping 1',
    'TEST | Drive Mapping 2'
}
Remove-GPOZaurr -Type Empty -BackupPath "$Env:UserProfile\Desktop\GPO" -BackupDated -LimitProcessing 3 -Verbose -WhatIf -ExcludeGroupPolicies $ExcludeGroupPolicies

# Remove GPOS, but don't touch 2 defined exclusions
Remove-GPOZaurr -Type Empty, Unlinked -BackupPath "$Env:UserProfile\Desktop\GPO" -BackupDated -LimitProcessing 2 -Verbose -WhatIf {
    Skip-GroupPolicy -Name 'TEST | Drive Mapping 1'
    Skip-GroupPolicy -Name 'TEST | Drive Mapping 2' -DomaiName 'ad.evotec.pl'
}