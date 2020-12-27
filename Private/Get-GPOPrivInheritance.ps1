function Get-GPOPrivInheritance {
    [cmdletBinding()]
    param(
        [parameter(ParameterSetName = 'ADObject', ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)][Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,
        [System.Collections.IDictionary] $CacheReturnedGPOs,
        [System.Collections.IDictionary] $ForestInformation,
        [string] $Domain,
        [switch] $SkipDomainRoot,
        [switch] $SkipDomainControllers
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
        $Inheritance = Get-GPInheritance -Target $Object.DistinguishedName
        foreach ($Link in $Inheritance.GpoLinks) {
            [PSCustomObject] @{
                DisplayName       = $Link.DisplayName
                DomainName        = $Domain
                GUID              = $Link.GPOID
                Enabled           = $Link.Enabled
                Enforced          = $Link.Enforced
                Order             = $Link.Order
                Target            = $Object.DistinguishedName
                TargetCanonical   = $Object.CanonicalName
                TargetObjectClass = $Object.objectClass
            }
        }
    }
}