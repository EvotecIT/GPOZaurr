function Get-GPOZaurrLinkLoop {
    [cmdletBinding()]
    param(
        [Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,
        [System.Collections.IDictionary] $CacheReturnedGPOs,
        [System.Collections.IDictionary] $ForestInformation,
        [validateset('All', 'Root', 'DomainControllers', 'Site', 'OrganizationalUnit')][string[]] $Linked,
        [string] $SearchBase,
        [Microsoft.ActiveDirectory.Management.ADSearchScope] $SearchScope,
        [string] $Filter
    )
    if (-not $ADObject) {
        if (-not $Filter) {
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
                    $SearchBase = $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName']
                    $Splat['Filter'] = "objectClass -eq 'domainDNS'"
                    $Splat['SearchBase'] = $SearchBase
                    try {
                        $ADObjectGPO = Get-ADObject @Splat
                    } catch {
                        Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                    }
                    Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation -AsHashTable:$AsHashTable
                }
                if ($Linked -contains 'Site' -or $Linked -contains 'All') {
                    Write-Verbose "Get-GPOZaurrLink - Getting GPO links for domain $Domain at SITE level"
                    # Sites are defined only in primary domain
                    if ($ForestInformation['DomainsExtended'][$Domain]['DNSRoot'] -eq $ForestInformation['DomainsExtended'][$Domain]['Forest']) {
                        $SearchBase = -join ("CN=Configuration,", $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName'])
                        $Splat['Filter'] = "(objectClass -eq 'site')"
                        $Splat['SearchBase'] = $SearchBase
                        try {
                            $ADObjectGPO = Get-ADObject @Splat
                        } catch {
                            Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                        }
                        Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation -AsHashTable:$AsHashTable
                    }
                }
                if ($Linked -contains 'DomainControllers' -or $Linked -contains 'All') {
                    Write-Verbose "Get-GPOZaurrLink - Getting GPO links for domain $Domain at DC level"
                    $SearchBase = $ForestInformation['DomainsExtended'][$Domain]['DomainControllersContainer']
                    $Splat['Filter'] = "(objectClass -eq 'organizationalUnit')"
                    $Splat['SearchBase'] = $SearchBase
                    try {
                        $ADObjectGPO = Get-ADObject @Splat
                    } catch {
                        Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                    }
                    Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation -AsHashTable:$AsHashTable
                }
                if ($Linked -contains 'OrganizationalUnit' -or $Linked -contains 'All') {
                    Write-Verbose "Get-GPOZaurrLink - Getting GPO links for domain $Domain at OU level"
                    $SearchBase = $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName']
                    $Splat['Filter'] = "(objectClass -eq 'organizationalUnit')"
                    $Splat['SearchBase'] = $SearchBase
                    try {
                        $ADObjectGPO = Get-ADObject @Splat
                    } catch {
                        Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                    }
                    Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation -SkipDomainRoot -SkipDomainControllers -AsHashTable:$AsHashTable
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
                Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObjectGPO -Domain $Domain -ForestInformation $ForestInformation -AsHashTable:$AsHashTable
            }
        }
    } else {
        Get-GPOPrivLink -CacheReturnedGPOs $CacheReturnedGPOs -ADObject $ADObject -Domain '' -ForestInformation $ForestInformation -AsHashTable:$AsHashTable
    }
}