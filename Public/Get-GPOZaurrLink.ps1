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
        [switch] $AsHashTable,

        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [switch] $Summary
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
        $getGPOLoopSplat = @{
            Linked            = $Linked
            ForestInformation = $ForestInformation
            CacheReturnedGPOs = $CacheReturnedGPOs
            SearchScope       = $SearchScope
            SearchBase        = $SearchBase
            ADObject          = $ADObject
            Filter            = $Filter
        }
        Remove-EmptyValue -Hashtable $getGPOLoopSplat -Recursive

        if ($AsHashTable -or $Summary) {
            $HashTable = [ordered] @{}
            $SummaryHashtable = [ordered] @{}
            $Links = Get-GPOZaurrLinkLoop @getGPOLoopSplat
            foreach ($Link in $Links) {
                $Key = -join ($Link.DomainName, $Link.GUID)
                if (-not $HashTable[$Key]) {
                    $HashTable[$Key] = [System.Collections.Generic.List[PSCustomObject]]::new()
                }
                $HashTable[$Key].Add($Link)
            }
            foreach ($Key in $HashTable.Keys) {
                [Array] $Link = $HashTable[$Key]
                $EnabledLinks = $Link.Enabled.Where( { $_ -eq $true }, 'split')
                if ($EnabledLinks[0].Count -gt 0) {
                    $IsLinked = $true
                } else {
                    $IsLinked = $false
                }
                $SummaryLink = [PSCustomObject] @{
                    DisplayName        = $Link[0].DisplayName
                    DomainName         = $Link[0].DomainName
                    GUID               = $Link[0].GUID
                    Linked             = $IsLinked
                    LinksCount         = $Link.Count
                    LinksEnabledCount  = $EnabledLinks[0].Count
                    LinksDisabledCount = $EnabledLinks[1].Count
                    Links              = $Link.DistinguishedName
                    LinksObjects       = $Link
                }
                $SummaryHashtable[$Key] = $SummaryLink
            }
            if ($AsHashTable -and $Summary) {
                $SummaryHashtable
            } elseif ($AsHashTable) {
                $HashTable
            } elseif ($Summary) {
                $SummaryHashtable.Values
            }
        } else {
            Get-GPOZaurrLinkLoop @getGPOLoopSplat
        }
    }
    End {

    }
}