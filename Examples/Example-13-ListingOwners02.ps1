Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$T = Get-GPOZaurrOwner -Verbose -IncludeSysvol
$T | Format-Table *
#$T | Out-HtmlView -ScrollX

$T = Get-GPOZaurrOwner -Verbose -IncludeSysvol -GPOName 'Default Domain Policy'
$T | Format-Table *

$T = Get-GPOZaurrOwner -Verbose -IncludeSysvol -GPOGuid '4E1F9C70-1DDB-4AB6-BBA3-14A8E07F0B4B'
$T | Format-Table *