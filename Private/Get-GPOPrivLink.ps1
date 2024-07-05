function Get-GPOPrivLink {
    <#
    .SYNOPSIS
    Retrieves the GPO (Group Policy Object) privilege link information for specified Active Directory objects.

    .DESCRIPTION
    This function retrieves the GPO privilege link information for the specified Active Directory objects. It allows skipping certain default containers like Domain Root and Domain Controllers if needed. It also provides options to cache returned GPOs and skip duplicates.

    .PARAMETER ADObject
    Specifies the Active Directory objects for which to retrieve GPO privilege link information.

    .PARAMETER CacheReturnedGPOs
    Specifies a dictionary to cache returned GPOs for optimization.

    .PARAMETER ForestInformation
    Specifies a dictionary containing forest information.

    .PARAMETER Domain
    Specifies the domain for which to retrieve GPO privilege link information.

    .PARAMETER SkipDomainRoot
    Indicates whether to skip the Domain Root container.

    .PARAMETER SkipDomainControllers
    Indicates whether to skip the Domain Controllers container.

    .PARAMETER AsHashTable
    Specifies whether to output the GPO information as a hash table.

    .PARAMETER SkipDuplicates
    Indicates whether to skip duplicate GPOs.

    .EXAMPLE
    Get-GPOPrivLink -ADObject $ADObject -CacheReturnedGPOs $Cache -ForestInformation $ForestInfo -Domain "example.com" -SkipDomainRoot -SkipDuplicates
    Retrieves GPO privilege link information for the specified ADObject in the "example.com" domain, skipping the Domain Root container and duplicates.

    .NOTES
    File Name      : Get-GPOPrivLink.ps1
    Prerequisite   : This function requires the Get-PrivGPOZaurrLink function.
    #>
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