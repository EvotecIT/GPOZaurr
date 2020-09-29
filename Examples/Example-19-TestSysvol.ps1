Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrSysvol -Verbose | Format-Table
#Get-GPOZaurrSysvol | Out-HtmlView -ScrollX