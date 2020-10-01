Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Default Permissions:
# 'GpoApply', 'GpoEdit', 'GPOCustom', 'GpoEditDeleteModifySecurity', 'GPORead'
# If you want to see also owners
# 'GpoOwner'
# If you want to include Root Level Permissions
# 'GpoCustomCreate', 'GpoCustomOwner'

$SummaryPermission = Get-GPOZaurrPermissionSummary -IncludePermissionType 'GPOCustom', 'GpoEdit', 'GpoEditDeleteModifySecurity', 'GpoOwner', 'GpoCustomCreate', 'GpoCustomOwner'
$SummaryPermission | Sort-Object -Property Permission | Format-Table