Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurrContent -Verbose -OutputType HTML, Object -Open
$Output | Format-Table