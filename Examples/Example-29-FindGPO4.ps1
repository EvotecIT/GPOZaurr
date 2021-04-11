Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurrContent -Verbose -OutputType HTML, Object -Open -GPOPath "C:\Support\GitHub\GpoZaurr\Ignore\NewExamples"  ##-Type LocalGroups
$Output | Format-Table