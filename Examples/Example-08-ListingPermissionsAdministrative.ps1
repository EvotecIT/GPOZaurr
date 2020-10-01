Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$T = Get-GPOZaurrPermission -GPOName 'Default Domain Policy' -Type 'All' -IncludeOwner
$T | Format-Table *