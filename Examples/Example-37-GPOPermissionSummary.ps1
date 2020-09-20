Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$SummaryPermission = Get-GPOZaurrPermissionSummary -IncludePermissionType GpoEdit, GpoEditDeleteModifySecurity -IncludeOwner
$SummaryPermission | Sort-Object -Property Permission | Format-Table