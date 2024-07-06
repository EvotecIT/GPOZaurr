function Get-GPOPrivInheritance {
    <#
    .SYNOPSIS
    Retrieves the Group Policy Object (GPO) inheritance information for a given Active Directory object.

    .DESCRIPTION
    This function retrieves the inheritance information of Group Policy Objects (GPOs) for a specified Active Directory object. It provides details on how GPOs are linked and inherited by the object.

    .PARAMETER ADObject
    Specifies the Active Directory object for which to retrieve GPO inheritance information.

    .PARAMETER CacheReturnedGPOs
    Specifies a dictionary containing cached GPO information to optimize retrieval.

    .PARAMETER ForestInformation
    Specifies a dictionary containing information about the Active Directory forest.

    .PARAMETER Domain
    Specifies the domain for which to retrieve GPO privilege link information.

    .PARAMETER SkipDomainRoot
    Indicates whether to skip the Domain Root container.

    .PARAMETER SkipDomainControllers
    Indicates whether to skip the Domain Controllers container.

    .EXAMPLE
    Get-GPOPrivInheritance -ADObject $ADObject -CacheReturnedGPOs $Cache -ForestInformation $ForestInfo -Domain "example.com" -SkipDomainRoot -SkipDomainControllers
    Retrieves GPO inheritance information for the specified ADObject in the "example.com" domain, skipping the Domain Root container and Domain Controllers container.

    .NOTES
    File Name      : Get-GPOPrivInheritance.ps1
    Prerequisite   : This function requires the Get-GPInheritance function.
    #>
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