Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Invoke-GPOZaurr -Type GPOOrganizationalUnit -Online -FilePath $PSScriptRoot\Reports\GPOZaurr.html

return

# Shows how to use exclusions (supported only in GPOBlockedInheritance)
Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Type GPOBlockedInheritance -Online -Exclusions @(
    'OU=Test,OU=ITR02,DC=ad,DC=evotec,DC=xyz'
)

# different approach to query multiple reports or just one
Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -PassThru -Type GPOConsistency, GPOList, GPODuplicates, GPOBroken, GPOOwners, NetLogonOwners, GPOPermissionsRead, GPOPermissionsAdministrative,GPOPermissionsUnknown

Invoke-GPOZaurr -Type GPOOwners -Online -FilePath $PSScriptRoot\Reports\GPOZaurr.html

# Shows how to use exclusions for GPOList (different way)
Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Type GPOList -Online -Exclusions {
    Skip-GroupPolicy -Name 'de14_usr_std'
    Skip-GroupPolicy -Name 'ALL | Enable RDP' -DomaiName 'ad.evotec.xyz'
}