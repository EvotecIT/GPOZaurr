Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrAD | Format-Table
Get-GPOZaurrAD -Forest 'test.evotec.pl' | Format-Table

Get-GPOZaurrAD -GPOName 'Default Domain Policy' -IncludeDomains 'ad.evotec.pl' | Format-Table