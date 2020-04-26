Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Clear-Host

Get-GPOZaurrLink -Linked Root | Format-Table -AutoSize

Get-GPOZaurrLink -Linked Site | Format-Table -AutoSize

Get-GPOZaurrLink -Linked DomainControllers | Format-Table -AutoSize

Get-GPOZaurrLink -Linked Other | Format-Table -AutoSize