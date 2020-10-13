Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurr -GPOPath $ENV:USERPROFILE\Desktop\GPOTestingUserAccess -Verbose
$Output | Format-Table *