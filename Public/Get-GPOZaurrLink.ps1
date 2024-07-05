function Get-GPOZaurrLink {
    <#
    .SYNOPSIS
    Retrieves Group Policy Object (GPO) Zaurr links based on specified criteria.

    .DESCRIPTION
    This function retrieves GPO Zaurr links based on various parameters such as ADObject, Filter, Linked, Site, etc. It provides flexibility in searching for GPO Zaurr links within Active Directory.

    .PARAMETER ADObject
    Specifies the Active Directory object(s) to search for GPO Zaurr links.

    .PARAMETER Filter
    Specifies the filter criteria to search for GPO Zaurr links.

    .PARAMETER SearchBase
    Specifies the search base for filtering GPO Zaurr links.

    .PARAMETER SearchScope
    Specifies the search scope for filtering GPO Zaurr links.

    .PARAMETER Linked
    Specifies the type of linked GPOs to retrieve. Valid values are 'All', 'Root', 'DomainControllers', 'Site', and 'OrganizationalUnit'.

    .PARAMETER Site
    Specifies the site(s) to search for GPO Zaurr links.

    .PARAMETER Limited
    Indicates whether to limit the search results.

    .PARAMETER SkipDuplicates
    Indicates whether to skip duplicate search results.

    .PARAMETER GPOCache
    Specifies a cache for storing GPO information.

    .PARAMETER Forest
    Specifies the forest name for filtering GPO Zaurr links.

    .PARAMETER ExcludeDomains
    Specifies the domains to exclude from the search.

    .PARAMETER IncludeDomains
    Specifies the domains to include in the search.

    .EXAMPLE
    Get-GPOZaurrLink -ADObject $ADObject -Linked 'All'

    Description
    -----------
    Retrieves all linked GPOZaurr links for the specified Active Directory object(s).

    .EXAMPLE
    Get-GPOZaurrLink -Filter "(objectClass -eq 'organizationalUnit')" -SearchBase 'CN=Configuration,DC=ad,DC=evotec,DC=xyz'

    Description
    -----------
    Retrieves GPOZaurr links based on the specified filter and search base.

    #>
    [cmdletbinding(DefaultParameterSetName = 'Linked')]
    param(
        [parameter(ParameterSetName = 'ADObject', ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)][Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,
        # site doesn't really work this way unless you give it 'CN=Configuration,DC=ad,DC=evotec,DC=xyz' as SearchBase
        [parameter(ParameterSetName = 'Filter')][string] $Filter, # "(objectClass -eq 'organizationalUnit' -or objectClass -eq 'domainDNS' -or objectClass -eq 'site')"
        [parameter(ParameterSetName = 'Filter')][string] $SearchBase,
        [parameter(ParameterSetName = 'Filter')][Microsoft.ActiveDirectory.Management.ADSearchScope] $SearchScope,

        [parameter(ParameterSetName = 'Linked')][validateset('All', 'Root', 'DomainControllers', 'Site', 'OrganizationalUnit')][string[]] $Linked,

        [parameter(ParameterSetName = 'Site')][string[]] $Site,

        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [switch] $Limited,

        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [switch] $SkipDuplicates,

        [parameter(ParameterSetName = 'Site')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [System.Collections.IDictionary] $GPOCache,

        [parameter(ParameterSetName = 'Site')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [alias('ForestName')][string] $Forest,

        [parameter(ParameterSetName = 'Site')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [string[]] $ExcludeDomains,

        [parameter(ParameterSetName = 'Site')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,

        [parameter(ParameterSetName = 'Site')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [parameter(ParameterSetName = 'Site')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [switch] $AsHashTable,

        [parameter(ParameterSetName = 'Site')]
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
                Write-Verbose "Get-GPOZaurrLink - Building GPO cache for domain $Domain"
                if ($ForestInformation['QueryServers'][$Domain]) {
                    $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                    Get-GPO -All -DomainName $Domain -Server $QueryServer | ForEach-Object {
                        $GPOCache["$Domain$($_.ID.Guid)"] = $_
                    }
                } else {
                    Write-Warning -Message "Get-GPOZaurrLink - Couldn't get query server for $Domain. Skipped."
                }
            }
        }
    }
    Process {
        $getGPOLoopSplat = @{
            Linked            = $Linked
            ForestInformation = $ForestInformation
            SearchScope       = $SearchScope
            SearchBase        = $SearchBase
            ADObject          = $ADObject
            Filter            = $Filter
            SkipDuplicates    = $SkipDuplicates
            Site              = $Site
        }
        Remove-EmptyValue -Hashtable $getGPOLoopSplat -Recursive
        $getGPOLoopSplat['CacheReturnedGPOs'] = $CacheReturnedGPOs
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

                $LinkedRoot = $false
                $LinkedRootPlaces = [System.Collections.Generic.List[string]]::new()
                $LinkedSite = $false
                $LinkedSitePlaces = [System.Collections.Generic.List[string]]::new()
                $LinkedOU = $false
                $LinkedCrossDomain = $false
                $LinkedCrossDomainPlaces = [System.Collections.Generic.List[string]]::new()
                foreach ($InternalLink in $Link) {
                    if ($InternalLink.ObjectClass -eq 'domainDNS') {
                        $LinkedRoot = $true
                        $LinkedRootPlaces.Add($InternalLink.DistinguishedName)
                    } elseif ($InternalLink.ObjectClass -eq 'site') {
                        $LinkedSite = $true
                        $LinkedSitePlaces.Add($InternalLink.Name)
                    } else {
                        $LinkedOU = $true
                    }
                    $CN = ConvertFrom-DistinguishedName -ToDomainCN -DistinguishedName $InternalLink.distinguishedName
                    $GPOCN = ConvertFrom-DistinguishedName -ToDomainCN -DistinguishedName $InternalLink.GPODomainDistinguishedName
                    if ($CN -ne $GPOCN) {
                        $LinkedCrossDomain = $true
                        $LinkedCrossDomainPlaces.Add($InternalLink.DistinguishedName)
                    }
                }
                if ($EnabledLinks[0].Count -gt 0) {
                    $IsLinked = $true
                } else {
                    $IsLinked = $false
                }
                $SummaryLink = [PSCustomObject] @{
                    DisplayName             = $Link[0].DisplayName
                    DomainName              = $Link[0].DomainName
                    GUID                    = $Link[0].GUID
                    Linked                  = $IsLinked
                    LinksCount              = $Link.Count
                    LinksEnabledCount       = $EnabledLinks[0].Count
                    LinksDisabledCount      = $EnabledLinks[1].Count
                    LinkedCrossDomain       = $LinkedCrossDomain
                    LinkedRoot              = $LinkedRoot
                    LinkedSite              = $LinkedSite
                    LinkedOU                = $LinkedOU
                    LinkedSitePlaces        = $LinkedSitePlaces
                    LinkedRootPlaces        = $LinkedRootPlaces
                    LinkedCrossDomainPlaces = $LinkedCrossDomainPlaces
                    Links                   = $Link.DistinguishedName
                    LinksObjects            = $Link
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