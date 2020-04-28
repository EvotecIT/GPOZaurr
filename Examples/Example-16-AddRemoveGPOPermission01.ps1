Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Clear-Host

$T = Get-GPOZaurrPermission -GPOName 'ALL | Enable RDP' #-IncludeGPOObject #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
$T | Format-Table -AutoSize *

Add-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEdit -Principal 'przemyslaw.klys' -Verbose

$T = Get-GPOZaurrPermission -GPOName 'ALL | Enable RDP' #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
$T | Format-Table -AutoSize *

Add-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEditDeleteModifySecurity -Principal 'Domain Admins' -Verbose
Remove-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEdit -Principal 'przemyslaw.klys' -PrincipalType Name -Verbose

$T = Get-GPOZaurrPermission -GPOName 'ALL | Enable RDP' #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
$T | Format-Table -AutoSize *