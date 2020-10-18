Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$FilesAll = Get-GPOZaurrNetlogon
$FilesAll | Format-Table -a *