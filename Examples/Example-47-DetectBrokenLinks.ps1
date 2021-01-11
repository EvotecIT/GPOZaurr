Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#Get-GPOZaurrBrokenLink -Verbose | Format-Table -AutoSize *

Get-GPOZaurrBrokenLink -Verbose -IncludeDomains ad.evotec.pl | Format-Table -AutoSize *