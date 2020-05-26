Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrWMI -Name 'Test - Dual Filter' | Format-Table -AutoSize *