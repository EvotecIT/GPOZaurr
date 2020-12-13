Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# GPOConsistency,GPODuplicates,GPOOrphans,GPOOwners,NetLogonOwners,GPOPermissionsRead,GPOPermissionsAdministrative - functional

#$Output = Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -PassThru -Type GPOConsistency, GPOList, GPODuplicates, GPOOrphans, GPOOwners, NetLogonOwners, GPOPermissionsRead, GPOPermissionsAdministrative,GPOPermissionsUnknown
Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Type GPOPermissions

return
#
$GPOS = Get-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\Empty' -ExcludeGroupPolicies @(
    Skip-GroupPolicy -Name 'de14_usr_std'
    Skip-GroupPolicy -Name 'de14_usr_std' -DomaiName 'ad.evotec.xyz'
)
$GPOS | Format-Table -AutoSize *