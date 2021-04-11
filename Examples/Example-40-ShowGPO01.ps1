Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#$Output = Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -PassThru -Type GPOConsistency, GPOList, GPODuplicates, GPOBroken, GPOOwners, NetLogonOwners, GPOPermissionsRead, GPOPermissionsAdministrative,GPOPermissionsUnknown

# Shows how to use exclusions (supported only in GPOBlockedInheritance)
Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Type GPOBlockedInheritance -Online -Exclusions @(
    'OU=Test,OU=ITR02,DC=ad,DC=evotec,DC=xyz'
)

<#
# Shows how to use exclusions for GPOList (different way)
Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Type GPOList -Online -Exclusions {
    Skip-GroupPolicy -Name 'de14_usr_std'
    Skip-GroupPolicy -Name 'ALL | Enable RDP' -DomaiName 'ad.evotec.xyz'
}
#>