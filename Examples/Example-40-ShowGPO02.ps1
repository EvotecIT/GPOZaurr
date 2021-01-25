Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Type GPOConsistency, GPOList, GPODuplicates, GPOBroken, GPOOwners, NetLogonOwners, GPOPermissionsRead, GPOPermissionsAdministrative, GPOPermissionsUnknown, GPOPermissions