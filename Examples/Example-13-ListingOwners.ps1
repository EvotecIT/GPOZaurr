Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Owners = Get-GPOZaurr -owneronly
$Owners | Format-Table