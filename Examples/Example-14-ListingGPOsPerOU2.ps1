Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrLink -SearchBase 'OU=Domain Controllers,DC=ad,DC=evotec,DC=xyz' | Format-Table -AutoSize

Get-GPOZaurrLink -SearchBase 'OU=Accounts,OU=Production,DC=ad,DC=evotec,DC=xyz' | Format-Table -AutoSize

Get-GPOZaurrLink -SearchBase 'DC=ad,DC=evotec,DC=xyz' -SearchScope Base | Format-Table -AutoSize