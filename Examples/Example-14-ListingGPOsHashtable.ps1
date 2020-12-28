Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$SummaryHashtable = Get-GPOZaurrLink -AsHashTable -Summary
$SummaryHashtable | Format-Table -AutoSize
$SummaryHashtable[5]