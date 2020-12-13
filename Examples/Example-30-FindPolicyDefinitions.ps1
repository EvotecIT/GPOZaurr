Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Policies = Get-GPOZaurrFilesPolicyDefinition -Signature
$Policies | Format-Table
#$Policies.FilesToDelete | Format-Table *
$Policies['ad.evotec.xyz'] | Format-Table *