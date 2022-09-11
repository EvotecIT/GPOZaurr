Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurrContent -SingleObject -Verbose -OutputType HTML, Object -Open -GPOPath "C:\Users\przemyslaw.klys\OneDrive - Evotec\Desktop\Test"
$Output | Format-Table