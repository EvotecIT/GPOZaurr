Clear-Host
Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Dictionary = Get-GPOZaurrDictionary #-Splitter '; '
$Dictionary | Format-Table
$Dictionary | Out-HtmlView