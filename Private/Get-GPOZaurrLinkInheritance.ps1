function Get-GPOZaurrLinkInheritance {
    <#
    .SYNOPSIS
    Retrieves the Group Policy Object (GPO) inheritance information for a given Active Directory object.

    .DESCRIPTION
    This function retrieves the inheritance information of Group Policy Objects (GPOs) for a specified Active Directory object. It provides details on how GPOs are linked and inherited by the object.

    .PARAMETER ADObject
    Specifies the Active Directory object for which to retrieve GPO inheritance information.

    .PARAMETER Filter
    Specifies the filter criteria for selecting the types of objects to include in the search. Default value includes 'organizationalUnit', 'domainDNS', and 'site' objects.

    .PARAMETER SearchBase
    Specifies the base distinguished name (DN) for the search operation.

    .PARAMETER SearchScope
    Specifies the scope of the search operation within Active Directory.

    .PARAMETER Linked
    Specifies the type of objects to include in the search. Valid values are 'Root', 'DomainControllers', and 'OrganizationalUnit'.

    .PARAMETER Limited
    Indicates whether to limit the search results. If specified, only a limited set of results will be returned.

    .PARAMETER SkipDuplicates
    Indicates whether to skip duplicate entries in the search results.

    .PARAMETER GPOCache
    Specifies a cache of Group Policy Objects to optimize performance.

    .PARAMETER Forest
    Specifies the target forest to search for GPO inheritance information. By default, the current forest is used.

    .PARAMETER ExcludeDomains
    Specifies the domains to exclude from the search operation. By default, the entire forest is scanned.

    .PARAMETER IncludeDomains
    Specifies the specific domains to include in the search operation. By default, the entire forest is scanned.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest to include in the search results.

    .PARAMETER AsHashTable
    Indicates whether to return the results as a hash table.

    .PARAMETER Summary
    Indicates whether to provide a summary of the GPO inheritance information.

    .EXAMPLE
    $Output = Get-GPOZaurrLinkInheritance -Summary
    $Output | Format-Table

    $Output[5]

    $Output[5].Links | Format-Table
    $Output[5].LinksObjects | Format-Table

    .NOTES
    This function is an improved version of Get-GPInheritance and provides better support for sites. It is recommended for retrieving GPO inheritance information.
    #>
    [cmdletbinding(DefaultParameterSetName = 'All')]
    param(
        [parameter(ParameterSetName = 'ADObject', ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)][Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,
        # weirdly enough site doesn't really work this way unless you give it 'CN=Configuration,DC=ad,DC=evotec,DC=xyz' as SearchBase
        [parameter(ParameterSetName = 'Filter')][string] $Filter = "(objectClass -eq 'organizationalUnit' -or objectClass -eq 'domainDNS' -or objectClass -eq 'site')",
        [parameter(ParameterSetName = 'Filter')][string] $SearchBase,
        [parameter(ParameterSetName = 'Filter')][Microsoft.ActiveDirectory.Management.ADSearchScope] $SearchScope,

        [parameter(ParameterSetName = 'Linked', Mandatory)][validateset('Root', 'DomainControllers', 'OrganizationalUnit')][string[]] $Linked,

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
                if ($ForestInformation['QueryServers'][$Domain]) {
                    $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                    Get-GPO -All -DomainName $Domain -Server $QueryServer | ForEach-Object {
                        $GPOCache["$Domain$($_.ID.Guid)"] = $_
                    }
                } else {
                    Write-Warning -Message "Get-GPOZaurrLinkInheritance - Couldn't get query server for $Domain. Skipped."
                }
            }
        }
    }
    Process {
        if (-not $Filter -and -not $Linked) {
            # We choose ALL, except SITE which is not supported gor Get-GPInheritance
            # that's why it's better to use Get-GPOZaurrLink
            #$Linked = 'Root', 'DomainControllers', 'Site', 'OrganizationalUnit'
        }
        $getGPOPrivInheritanceLoopSplat = @{
            Linked            = $Linked
            ForestInformation = $ForestInformation
            CacheReturnedGPOs = $CacheReturnedGPOs
            SearchScope       = $SearchScope
            SearchBase        = $SearchBase
            ADObject          = $ADObject
            Filter            = $Filter
        }
        Remove-EmptyValue -Hashtable $getGPOPrivInheritanceLoopSplat -Recursive

        # we need to use nested functions to support pipeline output and as hashtable and reporting that returns single value
        if ($AsHashTable -or $Summary) {
            $HashTable = [ordered] @{}
            $SummaryHashtable = [ordered] @{}
            $Links = Get-GPOPrivInheritanceLoop @getGPOPrivInheritanceLoopSplat
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
                    Links              = $Link.Target
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
            Get-GPOPrivInheritanceLoop @getGPOPrivInheritanceLoopSplat
        }
    }
    End {

    }
}