Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$T = Get-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -IncludeGPOObject #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
$T | Format-Table -AutoSize *

Remove-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEditDeleteModifySecurity -Principal 'CN=Przemysław Kłys,OU=Users,OU=Production,DC=ad,DC=evotec,DC=xyz' -PrincipalType 'DistinguishedName'

#$T = Add-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEditDeleteModifySecurity -Principal 'Domain Admins' -verbose #| Format-Table
#$T = Add-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoApply -Principal 'przemyslaw.klys' -verbose #| Format-Table
#$T | Format-Table -AutoSize *

$T = Get-GPOZaurrPermission -GPOName 'ALL | Enable RDP' #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
$T | Format-Table -AutoSize *