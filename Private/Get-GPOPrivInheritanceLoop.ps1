function Get-GPOPrivInheritanceLoop {
    <#
    .SYNOPSIS
    Retrieves the Group Policy Object (GPO) inheritance loop for a given Active Directory object.

    .DESCRIPTION
    This function retrieves the GPO inheritance loop for a specified Active Directory object. It analyzes the inheritance of GPOs based on the object's location in the Active Directory structure.

    .PARAMETER ADObject
    Specifies the Active Directory object for which the GPO inheritance loop needs to be determined.

    .PARAMETER CacheReturnedGPOs
    Specifies a dictionary containing cached GPO information to optimize retrieval.

    .PARAMETER ForestInformation
    Specifies a dictionary containing information about the Active Directory forest.

    .PARAMETER Linked
    Specifies the types of linked objects to consider during the inheritance analysis. Valid values are 'Root', 'DomainControllers', 'OrganizationalUnit'.

    .PARAMETER SearchBase
    Specifies the base location in Active Directory to start the search for GPO inheritance.

    .PARAMETER SearchScope
    Specifies the scope of the search in Active Directory.

    .PARAMETER Filter
    Specifies the filter to apply when searching for Active Directory objects.

    .EXAMPLE
    Get-GPOPrivInheritanceLoop -ADObject $ADObject -CacheReturnedGPOs $Cache -ForestInformation $ForestInfo -Linked 'Root' -SearchBase 'DC=contoso,DC=com' -SearchScope Subtree -Filter '(objectClass -eq "organizationalUnit")'

    Description:
    Retrieves the GPO inheritance loop for the specified Active Directory object located in the 'contoso.com' domain starting from the root.

    .EXAMPLE
    Get-GPOPrivInheritanceLoop -ADObject $ADObject -CacheReturnedGPOs $Cache -ForestInformation $ForestInfo -Linked 'DomainControllers' -SearchBase 'DC=contoso,DC=com' -SearchScope Base -Filter '(objectClass -eq "organizationalUnit")'

    Description:
    Retrieves the GPO inheritance loop for the specified Active Directory object located in the 'contoso.com' domain starting from the Domain Controllers container.

    #>
    [cmdletBinding()]
    param(
        [Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,
        [System.Collections.IDictionary] $CacheReturnedGPOs,
        [System.Collections.IDictionary] $ForestInformation,
        [validateset('Root', 'DomainControllers', 'OrganizationalUnit')][string[]] $Linked,
        [string] $SearchBase,
        [Microsoft.ActiveDirectory.Management.ADSearchScope] $SearchScope,
        [string] $Filter
    )
    if (-not $ADObject) {
        if ($Linked) {
            foreach ($Domain in $ForestInformation.Domains) {
                $Splat = @{
                    #Filter     = $Filter
                    Properties = 'distinguishedName', 'gplink', 'CanonicalName'
                    # Filter     = "(objectClass -eq 'organizationalUnit' -or objectClass -eq 'domainDNS' -or objectClass -eq 'site')"
                    Server     = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                }
                if ($Linked -contains 'DomainControllers') {
                    $SearchBase = $ForestInformation['DomainsExtended'][$Domain]['DomainControllersContainer']
                    $Splat['Filter'] = "(objectClass -eq 'organizationalUnit')"
                    $Splat['SearchBase'] = $SearchBase
                    try {
                        $ADObjectGPO = Get-ADObject @Splat
                    } catch {
                        Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                    }
                    Get-GPOPrivInheritance -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation
                }
                if ($Linked -contains 'Root') {
                    $SearchBase = $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName']
                    $Splat['Filter'] = "objectClass -eq 'domainDNS'"
                    $Splat['SearchBase'] = $SearchBase
                    try {
                        $ADObjectGPO = Get-ADObject @Splat
                    } catch {
                        Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                    }
                    Get-GPOPrivInheritance -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation
                }
                if ($Linked -contains 'Site') {
                    # Sites are defined only in primary domain
                    # Sites are not supported by Get-GPInheritance
                }
                if ($Linked -contains 'OrganizationalUnit') {
                    $SearchBase = $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName']
                    $Splat['Filter'] = "(objectClass -eq 'organizationalUnit')"
                    $Splat['SearchBase'] = $SearchBase
                    try {
                        $ADObjectGPO = Get-ADObject @Splat
                    } catch {
                        Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                    }
                    Get-GPOPrivInheritance -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation -SkipDomainRoot -SkipDomainControllers
                }
            }
        } elseif ($Filter) {
            foreach ($Domain in $ForestInformation.Domains) {
                $Splat = @{
                    Filter     = $Filter
                    Properties = 'distinguishedName', 'gplink', 'CanonicalName'
                    Server     = $ForestInformation['QueryServers'][$Domain]['HostName'][0]

                }
                if ($PSBoundParameters.ContainsKey('SearchBase')) {
                    $DomainDistinguishedName = $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName']
                    $SearchBaseDC = ConvertFrom-DistinguishedName -DistinguishedName $SearchBase -ToDC
                    if ($SearchBaseDC -ne $DomainDistinguishedName) {
                        # we check if SearchBase is part of domain distinugishname. If it isn't we skip
                        continue
                    }
                    $Splat['SearchBase'] = $SearchBase

                }
                if ($PSBoundParameters.ContainsKey('SearchScope')) {
                    $Splat['SearchScope'] = $SearchScope
                }

                try {
                    $ADObjectGPO = Get-ADObject @Splat
                } catch {
                    Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                }
                Get-GPOPrivInheritance -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation
            }
        }
    } else {
        Get-GPOPrivInheritance -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObject -Domain '' -ForestInformation $ForestInformation
    }
}