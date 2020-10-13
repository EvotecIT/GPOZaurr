Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurr -Verbose #-SingleObject
$Output | Format-Table