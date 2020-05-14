Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force
#Get-GPOZaurrPermissionConsistency -Type All -Forest 'test.evotec.pl' | Format-Table

$Output = Get-GPOZaurrPermissionConsistency -GPOName 'Default Domain Controllers Policy' -IncludeDomains 'ad.evotec.xyz' -VerifyInside
$Output | Format-Table DisplayName, DomainName, ACLConsistent, ACLConsistentInside
$Output.ACLConsistentInsideDetails | Format-Table

$Output = Get-GPOZaurrPermissionConsistency -VerifyInside -Type 'All'
$Output | Format-Table