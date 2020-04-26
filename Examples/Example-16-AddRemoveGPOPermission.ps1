#Clear-Host
Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$ApprovedGroups = @(
    'GDS-TestGroup10'
)
$RootGroups = @(
    #'przemyslaw.klys'
)



Invoke-GPOZaurrPermission -Linked Root -Verbose { #-IncludePermissionType GpoEdit, GpoEditDeleteModifySecurity -Type NotAdministrative, NotWellKnownAdministrative -Verbose {
    Set-GPOOwner -Type Administrative
    #Set-GPOOwner -Principal 'EVOTEC\Enterprise Admins'
    #Set-GPOOwner -Principal 'Domain Admins'
    Remove-GPOPermission -Type Administrative -IncludePermissionType GPOCustom
    Remove-GPOPermission -Type NotAdministrative, NotWellKnownAdministrative -IncludePermissionType GpoEdit, GpoEditDeleteModifySecurity
    Add-GPOPermission -Type Administrative -IncludePermissionType GpoEditDeleteModifySecurity
    #Add-GPOPermission -Type WellKnownAdministrative -IncludePermissionType GpoEditDeleteModifySecurity
} #-WhatIf #| Format-Table *
#-ApprovedGroups $ApprovedGroups -Trustee $RootGroups -TrusteeType Name -TrusteePermissionType GpoEditDeleteModifySecurity -WhatIf | Format-Table *


return
Get-GPOZaurrLink -Linked Root | ForEach-Object {
    Get-GPOZaurrPermission -GPOGuid $_.GUID -IncludePermissionType 'GpoEdit', 'GpoEditDeleteModifySecurity' -Type 'NotAdministrative', 'NotWellKnownAdministrative' -IncludeGPOObject | ForEach-Object {
        $_
    }
} | Format-Table -a *

#Get-GPOZaurrLink -Linked Site | Format-Table -AutoSize

#Get-GPOZaurrLink -Linked DomainControllers | Format-Table -AutoSize

#Get-GPOZaurrLink -Linked Other | Format-Table -AutoSize

#Get-GPOZaurrLink -SearchBase 'CN=Configuration,DC=ad,DC=evotec,DC=xyz' | Format-Table -AutoSize

#Get-AdObject -SearchBase 'DC=ad,DC=evotec,DC=xyz'  -Server 'ad.evotec.xyz' -Filter "(ObjectClass -eq 'site') -or (ObjectClass -eq 'organizationalUnit' -or ObjectClass -eq 'domainDNS')" -SearchScope Subtree #

#Get-ADObject -SearchBase 'CN=Configuration,DC=ad,DC=evotec,DC=xyz' | fl