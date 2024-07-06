function Get-GPOBlockedInheritance {
    <#
    .SYNOPSIS
    Retrieves information about Organizational Units (OUs) with blocked inheritance of Group Policy Objects (GPOs).

    .DESCRIPTION
    The Get-GPOBlockedInheritance function retrieves information about OUs within a specified forest that have blocked inheritance of GPOs. It returns a list of OUs with their distinguished names and whether they have blocked inheritance enabled.

    .PARAMETER Filter
    Specifies a filter to select specific OUs. Default is '*'.

    .PARAMETER Forest
    Specifies the name of the forest to query.

    .PARAMETER ExcludeDomains
    Specifies an array of domain names to exclude from the query.

    .PARAMETER IncludeDomains
    Specifies an array of domain names to include in the query.

    .PARAMETER AsHashTable
    Indicates whether to return the results as a hashtable. If specified, the function returns a hashtable with OU distinguished names as keys and blocked inheritance status as values.

    .PARAMETER ExtendedForestInformation
    Specifies additional forest information to include in the query.

    .EXAMPLE
    Get-GPOBlockedInheritance -Forest 'contoso.com'
    Retrieves a list of all OUs within the 'contoso.com' forest with blocked inheritance status.

    .EXAMPLE
    Get-GPOBlockedInheritance -Forest 'contoso.com' -IncludeDomains 'child1.contoso.com', 'child2.contoso.com' -AsHashTable
    Retrieves a hashtable of OUs within the 'contoso.com' forest from specified domains with blocked inheritance status.

    #>
    [cmdletBinding()]
    param(
        [string] $Filter = '*',

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [switch] $AsHashTable,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $OUCache = [ordered] @{}

    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation

    foreach ($Domain in $ForestInformation.Domains) {
        $OrganizationalUnits = Get-ADOrganizationalUnit -Filter $Filter -Properties gpOptions, canonicalName -Server $ForestInformation['QueryServers'][$Domain]['HostName'][0] #-SearchScope Subtree
        foreach ($OU in $OrganizationalUnits) {
            $OUCache[$OU.DistinguishedName] = [PSCustomObject] @{
                DistinguishedName  = $OU.DistinguishedName
                BlockedInheritance = if ($OU.gpOptions -eq 1) { $true } else { $false } # blocked inheritance
            }
        }
    }
    if ($AsHashTable) {
        $OUCache
    } else {
        $OUCache.Values
    }
}
