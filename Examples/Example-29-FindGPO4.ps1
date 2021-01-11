Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurrContent -Verbose -OutputType HTML, Object -Open -Type LocalGroups
$Output | Format-Table