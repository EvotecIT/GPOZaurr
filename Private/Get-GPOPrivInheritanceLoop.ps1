function Get-GPOPrivInheritanceLoop {
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