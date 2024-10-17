Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# # Shows how to use exclusions for GPOList (different way)
# Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Type GPOList -Online -Exclusions {
#     Skip-GroupPolicy -Name 'de14_usr_std'
#     Skip-GroupPolicy -Name 'ALL | Enable RDP' -DomaiName 'ad.evotec.xyz'
#     '01446204-d2b5-4c9a-a539-5d0f64f27fbc'
#     '{01cef2e1-ea5c-4c4a-bd43-94d89d8a7810}'
# }

# Invoke-GPOZaurr -Type GPOOrganizationalUnit -Online -FilePath $PSScriptRoot\Reports\GPOZaurr.html

# # Shows how to use exclusions (supported only in GPOBlockedInheritance)
# Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Type GPOBlockedInheritance -Online -Exclusions @(
#     'OU=Test,OU=ITR02,DC=ad,DC=evotec,DC=xyz'
# )

# # different approach to query multiple reports or just one
# Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -PassThru -Type GPOConsistency, GPOList, GPODuplicates, GPOBroken, GPOOwners, NetLogonOwners, GPOPermissionsRead, GPOPermissionsAdministrative, GPOPermissionsUnknown

#Invoke-GPOZaurr -Type GPOOwners,GPOConsistency -Online -FilePath $PSScriptRoot\Reports\GPOZaurr.html

#Invoke-GPOZaurr -Type GPOOwners -Online -FilePath $PSScriptRoot\Reports\GPOZaurr.html

##Invoke-GPOZaurr -Type GPOOwners,GPOConsistency -Online -FilePath $PSScriptRoot\Reports\GPOZaurr.html -SplitReports
#invoke-gpozaurr -Type GPOOrganizationalUnit
#Invoke-GPOZaurr -Online -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Type GPOAnalysis #-SplitReports -Forest test.evotec.pl


Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html # -Verbose #-Type GPOBlockedInheritance -Forest 'ad.evotec.xyz'