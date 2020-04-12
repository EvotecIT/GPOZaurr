Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$T = Get-GPOZaurrPermission -GPOName 'DC | PowerShell Logging' -Type Unknown

#$T = Get-GPOZaurrPermission #-Type All #-SkipWellKnown -SkipAdministrative # -ExcludePermissionType GpoRead,GpoApply #| Out-HtmlView
$T | Format-Table -AutoSize *
#$T | Out-HtmlView -ScrollX -Filtering -Online -DisablePaging