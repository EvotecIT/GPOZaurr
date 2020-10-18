Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurr -Verbose -OutputType HTML, Object -Open
$Output | Format-Table