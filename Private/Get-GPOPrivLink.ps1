function Get-GPOPrivLink {
    [cmdletBinding()]
    param(
        [parameter(ParameterSetName = 'ADObject', ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)][Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,
        [System.Collections.IDictionary] $CacheReturnedGPOs,
        [System.Collections.IDictionary] $ForestInformation,
        [string] $Domain,
        [switch] $SkipDomainRoot,
        [switch] $SkipDomainControllers,
        [switch] $AsHashTable,
        [switch] $SkipDuplicates
    )
    foreach ($Object in $ADObject) {
        if ($SkipDomainRoot) {
            if ($Object.DistinguishedName -eq $ForestInformation['DomainsExtended'][$Domain]['DistinguishedName']) {
                # other skips Domain Root
                continue
            }
        }
        if ($SkipDomainControllers) {
            if ($Object.DistinguishedName -eq $ForestInformation['DomainsExtended'][$Domain]['DomainControllersContainer']) {
                # other skips Domain Controllers
                continue
            }
        }
        $OutputGPOs = Get-PrivGPOZaurrLink -Object $Object -Limited:$Limited.IsPresent -GPOCache $GPOCache
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