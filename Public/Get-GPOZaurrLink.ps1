function Get-GPOZaurrLink {
    [cmdletbinding()]
    param(
        [parameter(ParameterSetName = 'ADObject', ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)][Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,
        # weirdly enough site doesn't really work this way unless you give it 'CN=Configuration,DC=ad,DC=evotec,DC=xyz' as SearchBase
        [parameter(ParameterSetName = 'Filter')][string] $Filter = "(objectClass -eq 'organizationalUnit' -or objectClass -eq 'domainDNS' -or objectClass -eq 'site')",
        [parameter(ParameterSetName = 'Filter')][string] $SearchBase,
        [parameter(ParameterSetName = 'Filter')][Microsoft.ActiveDirectory.Management.ADSearchScope] $SearchScope,

        [parameter(ParameterSetName = 'Linked', Mandatory)][validateset('Root', 'DomainControllers', 'Site', 'Other')][string] $Linked,

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
        [System.Collections.IDictionary] $ExtendedForestInformation
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
                        #if ($SearchBase -notlike "*$DomainDistinguishedName") {
                        # we check if SearchBase is part of domain distinugishname. If it isn't we skip
                        #    continue
                        #}
                        $Splat['Filter'] = "(objectClass -eq 'organizationalUnit')"
                        $Splat['SearchBase'] = $SearchBase
                        try {
                            $ADObjectGPO = Get-ADObject @Splat
                        } catch {
                            Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                        }
                        foreach ($_ in $ADObjectGPO) {
                            $OutputGPOs = Get-PrivGPOZaurrLink -Object $_ -Limited:$Limited.IsPresent -GPOCache $GPOCache
                            foreach ($OutputGPO in $OutputGPOs) {
                                if (-not $SkipDuplicates) {
                                    $OutputGPO
                                } else {
                                    $UniqueGuid = -join ($OutputGPO.DomainName, $OutputGPO.Guid)
                                    if (-not $CacheReturnedGPOs[$UniqueGuid]) {
                                        $CacheReturnedGPOs[$UniqueGuid] = $OutputGPO
                                        $OutputGPO
                                    }
                                }
                            }
                        }
                    }
                    if ($Linked -contains 'Root') {
                        $SearchBase = $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName']
                        #if ($SearchBase -notlike "*$DomainDistinguishedName") {
                        # we check if SearchBase is part of domain distinugishname. If it isn't we skip
                        #    continue
                        # }
                        $Splat['Filter'] = "objectClass -eq 'domainDNS'"
                        $Splat['SearchBase'] = $SearchBase
                        try {
                            $ADObjectGPO = Get-ADObject @Splat
                        } catch {
                            Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                        }
                        foreach ($_ in $ADObjectGPO) {
                            $OutputGPOs = Get-PrivGPOZaurrLink -Object $_ -Limited:$Limited.IsPresent -GPOCache $GPOCache
                            foreach ($OutputGPO in $OutputGPOs) {
                                if (-not $SkipDuplicates) {
                                    $OutputGPO
                                } else {
                                    $UniqueGuid = -join ($OutputGPO.DomainName, $OutputGPO.Guid)
                                    if (-not $CacheReturnedGPOs[$UniqueGuid]) {
                                        $CacheReturnedGPOs[$UniqueGuid] = $OutputGPO
                                        $OutputGPO
                                    }
                                }
                            }
                        }
                    }
                    if ($Linked -contains 'Site') {
                        # Sites are defined only in primary domain
                        if ($ForestInformation['DomainsExtended'][$Domain]['DNSRoot'] -eq $ForestInformation['DomainsExtended'][$Domain]['Forest']) {
                            $SearchBase = -join ("CN=Configuration,", $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName'])
                            # if ($SearchBase -notlike "*$DomainDistinguishedName") {
                            # we check if SearchBase is part of domain distinugishname. If it isn't we skip
                            #continue
                            #}
                            $Splat['Filter'] = "(objectClass -eq 'site')"
                            $Splat['SearchBase'] = $SearchBase
                            try {
                                $ADObjectGPO = Get-ADObject @Splat
                            } catch {
                                Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                            }
                            foreach ($_ in $ADObjectGPO) {
                                Get-PrivGPOZaurrLink -Object $_ -Limited:$Limited.IsPresent -GPOCache $GPOCache
                            }
                        }
                    }
                    if ($Linked -contains 'Other') {
                        $SearchBase = $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName']
                        #if ($SearchBase -notlike "*$DomainDistinguishedName") {
                        # we check if SearchBase is part of domain distinugishname. If it isn't we skip
                        #    continue
                        #}
                        $Splat['Filter'] = "(objectClass -eq 'organizationalUnit')"
                        $Splat['SearchBase'] = $SearchBase
                        try {
                            $ADObjectGPO = Get-ADObject @Splat
                        } catch {
                            Write-Warning "Get-GPOZaurrLink - Get-ADObject error $($_.Exception.Message)"
                        }
                        foreach ($_ in $ADObjectGPO) {
                            if ($_.DistinguishedName -eq $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName']) {
                                # other skips Domain Root
                            } elseif ($_.DistinguishedName -eq $ForestInformation['DomainsExtended'][$Domain]['DomainControllersContainer']) {
                                # other skips Domain Controllers
                            } else {
                                $OutputGPOs = Get-PrivGPOZaurrLink -Object $_ -Limited:$Limited.IsPresent -GPOCache $GPOCache
                                foreach ($OutputGPO in $OutputGPOs) {
                                    if (-not $SkipDuplicates) {
                                        $OutputGPO
                                    } else {
                                        $UniqueGuid = -join ($OutputGPO.DomainName, $OutputGPO.Guid)
                                        if (-not $CacheReturnedGPOs[$UniqueGuid]) {
                                            $CacheReturnedGPOs[$UniqueGuid] = $OutputGPO
                                            $OutputGPO
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
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
                    foreach ($_ in $ADObjectGPO) {
                        $OutputGPOs = Get-PrivGPOZaurrLink -Object $_ -Limited:$Limited.IsPresent -GPOCache $GPOCache
                        foreach ($OutputGPO in $OutputGPOs) {
                            if (-not $SkipDuplicates) {
                                $OutputGPO
                            } else {
                                $UniqueGuid = -join ($OutputGPO.DomainName, $OutputGPO.Guid)
                                if (-not $CacheReturnedGPOs[$UniqueGuid]) {
                                    $CacheReturnedGPOs[$UniqueGuid] = $OutputGPO
                                    $OutputGPO
                                }
                            }
                        }
                    }
                }
            }
        } else {
            foreach ($Object in $ADObject) {
                Get-PrivGPOZaurrLink -Object $Object -Limited:$Limited.IsPresent -GPOCache $GPOCache
            }
        }
    }
    End {

    }
}