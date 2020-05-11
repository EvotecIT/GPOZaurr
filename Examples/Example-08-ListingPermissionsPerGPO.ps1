Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$T = Get-GPOZaurrPermission -GPOName 'Default DOmain Policy' #-Principal 'marikegerard' -PrincipalType Name # #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
$T | Format-Table -AutoSize *
$T = Get-GPOZaurrPermission -GPOName 'Default DOmain Policy' -Principal 'marikegerard' -PrincipalType Name # #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
$T | Format-Table -AutoSize *
$T = Get-GPOZaurrPermission -GPOName 'Default DOmain Policy' -Principal 'EVOTEC\marikegerard' -PrincipalType Name # #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
$T | Format-Table -AutoSize *
$T = Get-GPOZaurrPermission -GPOName 'Default DOmain Policy' -Principal 'S-1-5-18' -PrincipalType Sid # #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
$T | Format-Table -AutoSize *
$T = Get-GPOZaurrPermission -GPOName 'Default DOmain Policy' -Principal 'CN=Enterprise Admins,CN=Users,DC=ad,DC=evotec,DC=xyz' -PrincipalType DistinguishedName # #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
$T | Format-Table -AutoSize *