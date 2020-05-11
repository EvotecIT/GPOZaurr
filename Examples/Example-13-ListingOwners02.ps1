Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$T = Get-GPOZaurrOwner -Verbose -IncludeSysvol
$T | Format-Table *
#$T | Out-HtmlView -ScrollX