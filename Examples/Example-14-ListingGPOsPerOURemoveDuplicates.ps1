Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrLink -SearchBase "OU=ITR01,DC=ad,DC=evotec,DC=xyz" -Verbose | Format-Table -a *

Get-GPOZaurrLink -SearchBase "OU=ITR01,DC=ad,DC=evotec,DC=xyz" -SkipDuplicates | Format-Table -a *