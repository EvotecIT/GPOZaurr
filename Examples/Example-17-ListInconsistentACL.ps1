Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#Get-GPOZaurrPermissionConsistency -Type All -Forest 'test.evotec.pl' | Format-Table
Get-GPOZaurrPermissionConsistency -Type All | Format-Table