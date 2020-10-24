Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurrContent -GPOPath $ENV:USERPROFILE\Desktop\GPOTestingUserAccess -Verbose
$Output | Format-Table *