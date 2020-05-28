Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force
Import-Module 'C:\Support\GitHub\PSSharedGoods\PSSharedGoods.psd1' -Force

# Apply permissions for ROOT
Invoke-GPOZaurrPermission -Verbose -Linked Root -IncludeDomains 'ad.evotec.xyz' {
    Set-GPOOwner -Type Administrative
    Remove-GPOPermission -Type NotAdministrative, NotWellKnownAdministrative -IncludePermissionType GpoEdit, GpoEditDeleteModifySecurity -PermitType Allow
} #-WhatIf

# Apply perrmissions for Domain Controllers
Invoke-GPOZaurrPermission -Verbose -Linked DomainControllers -IncludeDomains 'ad.evotec.xyz' {
    Set-GPOOwner -Type Administrative
    Remove-GPOPermission -Type NotAdministrative, NotWellKnownAdministrative -IncludePermissionType GpoEdit, GpoEditDeleteModifySecurity -PermitType Allow
    Add-GPOPermission -Type
} #-WhatIf

# Apply permissions for Regions, with exclusions for those 4 groups
$Exclude = @(
    'CN=ITR01_AD Admins,OU=Security,OU=Groups,OU=Production,DC=ad,DC=evotec,DC=xyz'
    'CN=ITR02_AD Admins,OU=Security,OU=Groups,OU=Production,DC=ad,DC=evotec,DC=xyz'
    'CN=ITR03_AD Admins,OU=Security,OU=Groups,OU=Production,DC=ad,DC=evotec,DC=xyz'
    'CN=ITR04_AD Admins,OU=Security,OU=Groups,OU=Production,DC=ad,DC=evotec,DC=xyz'
)

Invoke-GPOZaurrPermission -Verbose -SearchBase 'OU=ITR01,DC=ad,DC=evotec,DC=xyz' {
    Set-GPOOwner -Type Administrative
    Remove-GPOPermission -Type NotAdministrative, NotWellKnownAdministrative -IncludePermissionType GpoEdit, GpoEditDeleteModifySecurity -PermitType Allow -ExcludePrincipal $Exclude -ExcludePrincipalType DistinguishedName
} #-WhatIf

Invoke-GPOZaurrPermission -Verbose -SearchBase 'OU=ITR02,DC=ad,DC=evotec,DC=xyz' {
    Set-GPOOwner -Type Administrative
    Remove-GPOPermission -Type NotAdministrative, NotWellKnownAdministrative -IncludePermissionType GpoEdit, GpoEditDeleteModifySecurity -PermitType Allow -ExcludePrincipal $Exclude -ExcludePrincipalType DistinguishedName
} #-WhatIf