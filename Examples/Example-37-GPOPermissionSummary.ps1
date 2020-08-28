Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$SummaryPermission = Get-GPOZaurrPermissionSummary -IncludePermissionType GpoEdit, GpoEditDeleteModifySecurity
$SummaryPermission | Sort-Object -Property Permission