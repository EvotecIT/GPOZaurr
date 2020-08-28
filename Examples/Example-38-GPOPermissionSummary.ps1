Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$SummaryPermission = Get-GPOZaurrPermissionSummary -IncludeOwner
$SummaryPermission | Sort-Object -Property Permission | Format-Table *