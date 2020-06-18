Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrLink -Linked 'Root' -IncludeDomains 'ad.evotec.pl' | Format-Table