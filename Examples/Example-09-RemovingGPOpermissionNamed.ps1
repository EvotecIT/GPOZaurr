Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$T = Get-GPOZaurrPermission -GPOName 'Default DOmain Policy'
$T | Format-Table -AutoSize *

Remove-GPOZaurrPermission -GPOName 'Default DOmain Policy' -Principal 'S-1-5-21-853615985-2870445339-3163598659-3755' -Verbose #-WhatIf #-IncludePermissionType GpoApply #-WhatIf