Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurr -Verbose -Type DriveMapping,EventLog
$Output | Format-Table