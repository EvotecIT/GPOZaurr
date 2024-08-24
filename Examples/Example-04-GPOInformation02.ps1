Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#$GPOS = Get-GPOZaurr -GPOName 'TEST | Office Configuration'
#$GPOS | Format-Table -AutoSize *

$GPOS = Get-GPOZaurr -GPOName 'TEST | EmptyWITHGPF'
$GPOS | Format-Table -AutoSize *