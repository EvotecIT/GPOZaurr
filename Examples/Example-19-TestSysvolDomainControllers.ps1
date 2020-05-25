Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrSysvol -VerifyDomainControllers -Verbose | Format-Table *