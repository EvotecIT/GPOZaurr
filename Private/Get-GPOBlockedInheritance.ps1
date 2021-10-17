function Get-GPOBlockedInheritance {
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
