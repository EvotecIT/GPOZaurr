function Get-GPOZaurrDuplicateObject {
    <#
    .SYNOPSIS
    Retrieves duplicate Group Policy Objects (GPOs) within a specified forest.

    .DESCRIPTION
    This function retrieves duplicate Group Policy Objects (GPOs) within a specified forest by comparing GPOs based on partial distinguished name matching.

    .PARAMETER Forest
    Specifies the name of the forest to search for duplicate GPOs.

    .PARAMETER IncludeDomains
    Specifies an array of domain names to include in the search for duplicate GPOs.

    .PARAMETER ExcludeDomains
    Specifies an array of domain names to exclude from the search for duplicate GPOs.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest to aid in the search for duplicate GPOs.

    .EXAMPLE
    Get-GPOZaurrDuplicateObject -Forest "contoso.com" -IncludeDomains "child1.contoso.com", "child2.contoso.com" -ExcludeDomains "child3.contoso.com" -ExtendedForestInformation $additionalInfo

    Description
    -----------
    Retrieves duplicate GPOs within the "contoso.com" forest, including domains "child1.contoso.com" and "child2.contoso.com" while excluding "child3.contoso.com". Additional forest information is provided for the search.

    #>
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )

    $getWinADDuplicateObjectSplat = @{
        Forest                        = $Forest
        IncludeDomains                = $IncludeDomains
        ExcludeDomains                = $ExcludeDomains
        ExtendedForestInformation     = $ExtendedForestInformation
        PartialMatchDistinguishedName = "*,CN=Policies,CN=System,DC=*"
        Extended                      = $true
    }

    $DuplicateObjects = Get-WinADDuplicateObject @getWinADDuplicateObjectSplat
    $DuplicateObjects
}