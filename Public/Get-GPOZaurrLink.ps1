function Get-GPOZaurrLink {
    [cmdletbinding(DefaultParameterSetName = 'Linked')]
    param(
        [parameter(ParameterSetName = 'ADObject', ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)][Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,
        # weirdly enough site doesn't really work this way unless you give it 'CN=Configuration,DC=ad,DC=evotec,DC=xyz' as SearchBase
        [parameter(ParameterSetName = 'Filter')][string] $Filter, # "(objectClass -eq 'organizationalUnit' -or objectClass -eq 'domainDNS' -or objectClass -eq 'site')"
        [parameter(ParameterSetName = 'Filter')][string] $SearchBase,
        [parameter(ParameterSetName = 'Filter')][Microsoft.ActiveDirectory.Management.ADSearchScope] $SearchScope,

        [parameter(ParameterSetName = 'Linked')][validateset('All', 'Root', 'DomainControllers', 'Site', 'Other')][string[]] $Linked,

        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [switch] $Limited,

        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [switch] $SkipDuplicates,

        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [System.Collections.IDictionary] $GPOCache,

        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [alias('ForestName')][string] $Forest,

        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [string[]] $ExcludeDomains,

        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,

        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [switch] $AsHashTable
    )
    Begin {
        $CacheReturnedGPOs = [ordered] @{}
        $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        if (-not $GPOCache -and -not $Limited) {
            $GPOCache = @{ }
            # While initially we used $ForestInformation.Domains but the thing is GPOs can be linked to other domains so we need to get them all so we can use cache of it later on even if we're processing just one domain
            # That's why we use $ForestInformation.Forest.Domains instead
            foreach ($Domain in $ForestInformation.Forest.Domains) {
                $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                Get-GPO -All -DomainName $Domain -Server $QueryServer | ForEach-Object {
                    $GPOCache["$Domain$($_.ID.Guid)"] = $_
                }
            }
        }
    }
    Process {
        if (-not $ADObject) {
            if (-not $Filter) {
                # if not linked, we force it to All
                if (-not $Linked) {
                    $Linked = 'All'
                }
                foreach ($Domain in $ForestInformation.Domains) {
                    $Splat = @{
                        #Filter     = $Filter
                        Properties = 'distinguishedName', 'gplink', 'CanonicalName'
                        # Filter     = "(objectClass -eq 'organizationalUnit' -or objectClass -eq 'domainDNS' -or objectClass -eq 'site')"
                        Server     = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                    }
                    if ($Linked -contains 'Root' -or $Linked -contains 'All') {
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
                    if ($Linked -contains 'Other' -or $Linked -contains 'All') {
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
    End {

    }
}