Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrWMI | Format-Table -AutoSize *