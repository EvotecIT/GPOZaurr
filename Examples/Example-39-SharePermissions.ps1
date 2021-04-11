Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$FilesAll = Get-GPOZaurrNetLogon -IncludeDomains 'ad.evotec.xyz' -Verbose -OwnerOnly
$FilesAll | Format-Table -a *