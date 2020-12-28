Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrLink -Site 'Katowice-1','Katowice-2' | Format-Table -AutoSize *