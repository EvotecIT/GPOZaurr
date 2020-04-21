Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$GPOS = Get-GPOZaurr
$GPOS | Format-Table -AutoSize

$GPOS[0] | Format-List

$GPOs[0].ACL | Format-Table -AutoSize

$GPOs.Links | Format-Table -AutoSize

$GPOS | Format-Table -AutoSize DisplayName, WmiFilter, WMIDescription