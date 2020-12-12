Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Clear-Host

$GPOName = 'TEST | Deny Admins'

$T = Get-GPOZaurrPermission -GPOName $GPOName #-IncludePermissionType GpoEditDeleteModifySecurity -PermitType Allow -Principal 'Domain Admins' -PrincipalType 'Name'
$T | Format-Table *


return

<#
# this will go and check for both Domain Admins / Enterprise Admins - if found won't do anything
Add-GPOZaurrPermission -GPOName $GPOName -PermissionType GpoEditDeleteModifySecurity -Type Administrative -Verbose
# this will go thru, because PrincipalType is not set to look by Name. Be precise with what you ask for
Add-GPOZaurrPermission -GPOName $GPOName -PermissionType GpoEditDeleteModifySecurity -Principal 'Domain Admins' -Verbose
# this will be detected as already existing
Add-GPOZaurrPermission -GPOName $GPOName -PermissionType GpoEditDeleteModifySecurity -Principal 'Domain Admins' -PrincipalType Name -Verbose
# this will be added only if it doesn't exists - assuming that przemyslaw.klys is displayed in Get-GPOZaurrPermissions
Add-GPOZaurrPermission -GPOName $GPOName -PermissionType GpoApply -Principal 'przemyslaw.klys' -PrincipalType Name -Verbose
# this will be added only if it doesn't exists - assuming that przemyslaw.klys is displayed in Get-GPOZaurrPermissions
Add-GPOZaurrPermission -GPOName $GPOName -PermissionType GpoEditDeleteModifySecurity -Principal 'przemyslaw.klys' -PrincipalType Name -Verbose
# this will ADD system if it doesn't eists
Add-GPOZaurrPermission -GPOName $GPOName -PermissionType GpoEditDeleteModifySecurity -Type WellKnownAdministrative -Verbose

Add-GPOZaurrPermission -GPOName $GPOName -PermissionType GpoApply -Principal 'przemyslaw.klys' -Verbose
Add-GPOZaurrPermission -GPOName $GPOName -PermissionType GpoEditDeleteModifySecurity -Principal 'przemyslaw.klys' -Verbose
# this will not work because we already have GPOEditDeleteModifySecurity which is higher than GpoEDIT
Add-GPOZaurrPermission -GPOName $GPOName -PermissionType GpoEdit -Principal 'przemyslaw.klys' -Verbose
#>
Add-GPOZaurrPermission -GPOName $GPOName -Type AuthenticatedUsers -PermissionType GpoRead -Verbose #-WhatIf

#$T = Get-GPOZaurrPermission -GPOName $GPOName #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
#$T | Format-Table -AutoSize *

#Remove-GPOZaurrPermission -GPOName $GPOName -PermissionType GpoApply -Principal 'przemyslaw.klys' -PrincipalType Name -Verbose

#$T = Get-GPOZaurrPermission -GPOName $GPOName #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
#$T = Get-GPOZaurrPermission -GPOName $GPOName #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
#$T | Format-Table -AutoSize *