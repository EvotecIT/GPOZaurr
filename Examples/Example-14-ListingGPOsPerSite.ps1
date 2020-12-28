Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrLink -Linked Site | Format-Table -AutoSize *