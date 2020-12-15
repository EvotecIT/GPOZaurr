Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#$Output = Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -PassThru -Type GPOConsistency, GPOList, GPODuplicates, GPOOrphans, GPOOwners, NetLogonOwners, GPOPermissionsRead, GPOPermissionsAdministrative,GPOPermissionsUnknown
Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Type GPOPermissions,GPOPermissionsRead