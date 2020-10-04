Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurr -GPOPath $ENV:USERPROFILE\Desktop\GPOTestingUserAccess -Verbose #-SkipCleanup #-Type PoliciesPrinters, Policies
$Output | Format-Table *

#$Output.Reports | Format-Table
#$Output.Reports.SecurityOptions | Format-Table
#$Output.Reports.UserRightsAssignment | Format-Table

