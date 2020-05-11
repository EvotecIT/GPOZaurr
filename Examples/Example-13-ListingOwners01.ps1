Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Owners = Get-GPOZaurr -OwnerOnly
$Owners | Format-Table