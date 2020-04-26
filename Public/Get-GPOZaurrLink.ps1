function Get-GPOZaurrLink {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)][Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,
        [switch] $Limited,
        [System.Collections.IDictionary] $GPOCache,
        # weirdly enough site doesn't really work this way unless you give it 'CN=Configuration,DC=ad,DC=evotec,DC=xyz' as SearchBase
        [string] $Filter = "(objectClass -eq 'organizationalUnit' -or objectClass -eq 'domainDNS' -or objectClass -eq 'site')",
        [string] $SearchBase,
        [Microsoft.ActiveDirectory.Management.ADSearchScope] $SearchScope,

        [validateset('Root', 'DomainControllers', 'Site', 'Other')][string] $Linked,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Begin {
        $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        if (-not $GPOCache -and -not $Limited) {
            $GPOCache = @{ }
            foreach ($Domain in $ForestInformation.Domains) {
                $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                Get-GPO -All -DomainName $Domain -Server $QueryServer | ForEach-Object {
                    $GPOCache[$_.ID.Guid] = $_
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
                        Get-ADObject @Splat | ForEach-Object -Process {
                            Get-PrivGPOZaurrLink -Object $_ -Limited:$Limited.IsPresent -GPOCache $GPOCache
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
                        Get-ADObject @Splat | ForEach-Object -Process {
                            Get-PrivGPOZaurrLink -Object $_ -Limited:$Limited.IsPresent -GPOCache $GPOCache
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
                            Get-ADObject @Splat | ForEach-Object -Process {
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
                        Get-ADObject @Splat | ForEach-Object -Process {
                            if ($_.DistinguishedName -eq $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName']) {
                                # other skips Domain Root
                            } elseif ($_.DistinguishedName -eq $ForestInformation['DomainsExtended'][$Domain]['DomainControllersContainer']) {
                                # other skips Domain Controllers
                            } else {
                                Get-PrivGPOZaurrLink -Object $_ -Limited:$Limited.IsPresent -GPOCache $GPOCache
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
                        if ($SearchBase -notlike "*$DomainDistinguishedName") {
                            # we check if SearchBase is part of domain distinugishname. If it isn't we skip
                            continue
                        }
                        $Splat['SearchBase'] = $SearchBase

                    }
                    if ($PSBoundParameters.ContainsKey('SearchScope')) {
                        $Splat['SearchScope'] = $SearchScope
                    }

                    Get-ADObject @Splat | ForEach-Object {
                        Get-PrivGPOZaurrLink -Object $_ -Limited:$Limited.IsPresent -GPOCache $GPOCache
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