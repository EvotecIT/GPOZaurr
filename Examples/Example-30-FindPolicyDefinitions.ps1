Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Policies = Get-GPOZaurrFilesPolicyDefinitions -Signature
$Policies | Format-Table
#$Policies.FilesToDelete | Format-Table *
$Policies['ad.evotec.xyz'] | Format-Table *