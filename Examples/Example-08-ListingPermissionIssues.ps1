Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Issues = Get-GPOZaurrPermissionIssue
$Issues | Format-Table