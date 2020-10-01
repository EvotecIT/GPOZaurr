Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Default Permissions:
# 'GpoApply', 'GpoEdit', 'GPOCustom', 'GpoEditDeleteModifySecurity', 'GPORead'
# If you want to see also owners
# 'GpoOwner'
# If you want to include Root Level Permissions
# 'GpoRootCreate', 'GpoRootOwner'
$SummaryPermission = Get-GPOZaurrPermissionSummary -IncludePermissionType 'GpoCustom', 'GpoEdit', 'GpoEditDeleteModifySecurity', 'GpoOwner', 'GpoRootCreate', 'GpoRootOwner'
$SummaryPermission | Sort-Object -Property Permission | Format-Table