function Get-GPOZaurrDuplicateObject {
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