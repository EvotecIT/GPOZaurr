Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force
#Get-GPOZaurrPermissionConsistency -Type All -Forest 'test.evotec.pl' | Format-Table

$Output = Get-GPOZaurrPermissionConsistency -GPOName 'Default Domain Controllers Policy' -IncludeDomains 'ad.evotec.xyz' -VerifyInheritance
$Output | Format-Table DisplayName, DomainName, ACLConsistent, ACLConsistentInside
$Output.ACLConsistentInsideDetails | Format-Table

$Output = Get-GPOZaurrPermissionConsistency -VerifyInheritance -Type 'All'
$Output | Format-Table