Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#$GPOS = Get-GPOZaurr -GPOName 'TEST | Office Configuration'
#$GPOS | Format-Table -AutoSize *

$GPOS = Get-GPOZaurr -GPOName 'New Group Policy Object3'
$GPOS | Format-Table -AutoSize *