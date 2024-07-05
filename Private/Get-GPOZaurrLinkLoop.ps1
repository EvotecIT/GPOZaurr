function Get-GPOZaurrLinkLoop {
    <#
    .SYNOPSIS
    Retrieves Group Policy Object (GPO) links for Active Directory objects based on specified criteria.

    .DESCRIPTION
    This function retrieves GPO links for Active Directory objects based on the provided parameters. It allows searching for GPO links within specific sites, domains, or organizational units. The function can handle duplicates and provides flexibility in defining search criteria.

    .PARAMETER ADObject
    Specifies the Active Directory objects for which GPO links will be retrieved.

    .PARAMETER CacheReturnedGPOs
    A dictionary cache of returned Group Policy Objects for efficient processing.

    .PARAMETER ForestInformation
    Information about the forest structure and domains for targeted searches.

    .PARAMETER Linked
    Specifies the type of objects to search for GPO links. Valid values are 'All', 'Root', 'DomainControllers', 'Site', or 'OrganizationalUnit'.

    .PARAMETER SearchBase
    Specifies the base location for the search within Active Directory.

    .PARAMETER SearchScope
    Specifies the scope of the search within Active Directory.

    .PARAMETER Filter
    Specifies additional filters to apply during the search.

    .PARAMETER SkipDuplicates
    Indicates whether to skip duplicate GPO links during processing.

    .PARAMETER Site
    Specifies the site(s) to search for GPO links.

    .EXAMPLE
    Get-GPOZaurrLinkLoop -Site 'SiteA', 'SiteB' -ForestInformation $ForestInfo

    Description:
    Retrieves GPO links for sites 'SiteA' and 'SiteB' within the forest using the provided forest information.

    .EXAMPLE
    Get-GPOZaurrLinkLoop -SearchBase 'OU=Users,DC=contoso,DC=com' -SearchScope Subtree -Filter '(objectClass -eq "user")'

    Description:
    Retrieves GPO links for all user objects within the specified organizational unit 'Users' in the 'contoso.com' domain.

    #>
    [cmdletBinding()]
    param(
        [Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,
        [System.Collections.IDictionary] $CacheReturnedGPOs,
        [System.Collections.IDictionary] $ForestInformation,
        [validateset('All', 'Root', 'DomainControllers', 'Site', 'OrganizationalUnit')][string[]] $Linked,
        [string] $SearchBase,
        [Microsoft.ActiveDirectory.Management.ADSearchScope] $SearchScope,
        [string] $Filter,
        [switch] $SkipDuplicates,
        [string[]] $Site
    )
    if (-not $ADObject) {
        if ($Site) {
            foreach ($S in $Site) {
                foreach ($Domain in $ForestInformation.Domains) {
                    Write-Verbose "Get-GPOZaurrLink - Getting GPO links for site $Site"
                    # Sites are defined only in primary domain
                    if ($ForestInformation['DomainsExtended'][$Domain]['DNSRoot'] -eq $ForestInformation['DomainsExtended'][$Domain]['Forest']) {
                        $Splat = @{
                            #Filter     = $Filter
                            Properties = 'distinguishedName', 'gplink', 'CanonicalName'
                            # Filter     = "(objectClass -eq 'organizationalUnit' -or objectClass -eq 'domainDNS' -or objectClass -eq 'site')"
                            Server     = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                        }
                        $Splat['Filter'] = "(objectClass -eq 'site') -and (name -eq '$S')"
                        $Splat['SearchBase'] = -join ("CN=Configuration,", $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName'])
                        try {
                            $ADObjectGPO = Get-ADObject @Splat
                        } catch {
                            Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                        }
                        if ($ADObjectGPO) {
                            Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation -AsHashTable:$AsHashTable -SkipDuplicates:$SkipDuplicates
                        }
                    }
                }
            }
        } elseif ($SearchBase -or $SearchScope -or $Filter) {
            foreach ($Domain in $ForestInformation.Domains) {
                if (-not $Filter) {
                    $Filter = "(objectClass -eq 'organizationalUnit' -or objectClass -eq 'domainDNS' -or objectClass -eq 'site')"
                }
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
                if ($ADObjectGPO) {
                    Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation -AsHashTable:$AsHashTable -SkipDuplicates:$SkipDuplicates
                }
            }
        } elseif (-not $Filter) {
            # if not linked, we force it to All
            if (-not $Linked) {
                $Linked = 'All'
            }
            foreach ($Domain in $ForestInformation.Domains) {
                Write-Verbose "Get-GPOZaurrLink - Getting GPO links for domain $Domain"
                $Splat = @{
                    #Filter     = $Filter
                    Properties = 'distinguishedName', 'gplink', 'CanonicalName'
                    # Filter     = "(objectClass -eq 'organizationalUnit' -or objectClass -eq 'domainDNS' -or objectClass -eq 'site')"
                    Server     = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                }
                if ($Linked -contains 'Root' -or $Linked -contains 'All') {
                    Write-Verbose "Get-GPOZaurrLink - Getting GPO links for domain $Domain at ROOT level"
                    $Splat['Filter'] = "objectClass -eq 'domainDNS'"
                    $Splat['SearchBase'] = $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName']
                    try {
                        $ADObjectGPO = Get-ADObject @Splat
                    } catch {
                        Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                    }
                    if ($ADObjectGPO) {
                        Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation -AsHashTable:$AsHashTable -SkipDuplicates:$SkipDuplicates
                    }
                }
                if ($Linked -contains 'Site' -or $Linked -contains 'All') {
                    Write-Verbose "Get-GPOZaurrLink - Getting GPO links for domain $Domain at SITE level"
                    # Sites are defined only in primary domain
                    if ($ForestInformation['DomainsExtended'][$Domain]['DNSRoot'] -eq $ForestInformation['DomainsExtended'][$Domain]['Forest']) {
                        $Splat['Filter'] = "(objectClass -eq 'site')"
                        $Splat['SearchBase'] = -join ("CN=Configuration,", $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName'])
                        try {
                            $ADObjectGPO = Get-ADObject @Splat
                        } catch {
                            Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                        }
                        if ($ADObjectGPO) {
                            Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation -AsHashTable:$AsHashTable -SkipDuplicates:$SkipDuplicates
                        }
                    }
                }
                if ($Linked -contains 'DomainControllers' -or $Linked -contains 'All') {
                    Write-Verbose "Get-GPOZaurrLink - Getting GPO links for domain $Domain at DC level"
                    $Splat['Filter'] = "(objectClass -eq 'organizationalUnit')"
                    $Splat['SearchBase'] = $ForestInformation['DomainsExtended'][$Domain]['DomainControllersContainer']
                    try {
                        $ADObjectGPO = Get-ADObject @Splat
                    } catch {
                        Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                    }
                    if ($ADObjectGPO) {
                        Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation -AsHashTable:$AsHashTable -SkipDuplicates:$SkipDuplicates
                    }
                }
                if ($Linked -contains 'OrganizationalUnit' -or $Linked -contains 'All') {
                    Write-Verbose "Get-GPOZaurrLink - Getting GPO links for domain $Domain at OU level"
                    $Splat['Filter'] = "(objectClass -eq 'organizationalUnit')"
                    $Splat['SearchBase'] = $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName']
                    try {
                        $ADObjectGPO = Get-ADObject @Splat
                    } catch {
                        Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                    }
                    if ($ADObjectGPO) {
                        Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation -SkipDomainRoot -SkipDomainControllers -AsHashTable:$AsHashTable -SkipDuplicates:$SkipDuplicates
                    }
                }
            }
        }
        <#
        elseif ($Filter) {
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
                if ($ADObjectGPO) {
                    Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation -AsHashTable:$AsHashTable -SkipDuplicates:$SkipDuplicates
                }
            }
        }
        #>
    } else {
        Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObject -Domain '' -ForestInformation $ForestInformation -AsHashTable:$AsHashTable -SkipDuplicates:$SkipDuplicates
    }
}