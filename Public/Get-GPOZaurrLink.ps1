function Get-GPOZaurrLink {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)][Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,
        [switch] $Limited,
        [System.Collections.IDictionary] $GPOCache,

        [string] $Filter = '*',
        [string] $SearchBase,
        [Microsoft.ActiveDirectory.Management.ADSearchScope] $SearchScope,


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
        } else {
            foreach ($Object in $ADObject) {
                Get-PrivGPOZaurrLink -Object $Object -Limited:$Limited.IsPresent -GPOCache $GPOCache
            }
        }
    }
    End {

    }
}