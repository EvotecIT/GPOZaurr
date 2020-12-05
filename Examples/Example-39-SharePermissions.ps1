Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$FilesAll = Get-GPOZaurrNetLogon -SkipOwner -IncludeDomains 'ad.evotec.pl' #-OwnerOnly
$FilesAll | Format-Table -a *