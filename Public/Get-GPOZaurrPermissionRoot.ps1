function Get-GPOZaurrPermissionRoot {
    <#
    .SYNOPSIS
    Retrieves the root permissions of Group Policy Objects (GPOs) based on specified criteria.

    .DESCRIPTION
    Retrieves the root permissions of GPOs based on the specified criteria, including filtering by permission types, forest, domains, and more.

    .PARAMETER IncludePermissionType
    Specifies the root permission types to include in the search.

    .PARAMETER ExcludePermissionType
    Specifies the root permission types to exclude from the search.

    .PARAMETER Forest
    Specifies the target forest. By default, the current forest is used.

    .PARAMETER ExcludeDomains
    Specifies domains to exclude from the search.

    .PARAMETER IncludeDomains
    Specifies domains to include in the search.

    .PARAMETER ExtendedForestInformation
    Provides additional forest information to speed up processing.

    .PARAMETER SkipNames
    Skips processing names during the operation.

    .EXAMPLE
    Get-GPOZaurrPermissionRoot -IncludePermissionType 'GpoRootCreate' -ExcludePermissionType 'GpoRootOwner' -Forest 'ExampleForest' -IncludeDomains 'Domain1', 'Domain2' -ExtendedForestInformation $ForestInfo -SkipNames

    .EXAMPLE
    Get-GPOZaurrPermissionRoot -IncludePermissionType 'GpoRootOwner' -ExcludePermissionType 'GpoRootCreate' -Forest 'AnotherForest' -ExcludeDomains 'Domain3' -SkipNames

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [ValidateSet('GpoRootCreate', 'GpoRootOwner')][string[]] $IncludePermissionType,
        [ValidateSet('GpoRootCreate', 'GpoRootOwner')][string[]] $ExcludePermissionType,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [switch] $SkipNames
    )
    Begin {
        $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -Extended
    }
    Process {
        foreach ($Domain in $ForestInformation.Domains) {
            $DomainDistinguishedName = $ForestInformation['DomainsExtended'][$Domain].DistinguishedName
            $QueryServer = $ForestInformation['QueryServers'][$Domain].HostName[0]
            $getADACLSplat = @{
                ADObject                       = "CN=Policies,CN=System,$DomainDistinguishedName"
                IncludeActiveDirectoryRights   = 'GenericAll', 'CreateChild', 'WriteOwner', 'WriteDACL'
                IncludeObjectTypeName          = 'All', 'Group-Policy-Container'
                IncludeInheritedObjectTypeName = 'All', 'Group-Policy-Container'
                ADRightsAsArray                = $true
                ResolveTypes                   = $true
            }
            $GPOPermissionsGlobal = Get-ADACL @getADACLSplat -Verbose:$false
            $GPOs = Get-ADObject -SearchBase "CN=Policies,CN=System,$DomainDistinguishedName" -SearchScope OneLevel -Filter * -Properties DisplayName -Server $QueryServer -Verbose:$false
            foreach ($Permission in $GPOPermissionsGlobal) {
                $CustomPermission = foreach ($_ in $Permission.ActiveDirectoryRights) {
                    if ($_ -in 'WriteDACL', 'WriteOwner', 'GenericAll' ) {
                        'GpoRootOwner'
                    }
                    if ($_ -in 'CreateChild', 'GenericAll') {
                        'GpoRootCreate'
                    }
                }
                $CustomPermission = $CustomPermission | Sort-Object -Unique
                foreach ($SinglePermission in $CustomPermission) {
                    if ($SinglePermission -in $ExcludePermissionType) {
                        continue
                    }
                    if ($IncludePermissionType.Count -gt 0 -and $SinglePermission -notin $IncludePermissionType) {
                        continue
                    }
                    $OutputEntry = [ordered] @{
                        PrincipalName        = $Permission.Principal
                        Permission           = $SinglePermission
                        PermissionType       = $Permission.AccessControlType
                        PrincipalSidType     = $Permission.PrincipalType
                        PrincipalObjectClass = $Permission.PrincipalObjectType
                        PrincipalDomainName  = $Permission.PrincipalObjectDomain
                        PrincipalSid         = $Permission.PrincipalObjectSid
                        DomainName           = $Domain
                        GPOCount             = $GPOs.Count
                    }
                    if (-not $SkipNames) {
                        $OutputEntry['GPONames'] = $GPOs.DisplayName
                    }
                    [PSCustomObject] $OutputEntry
                }
            }
        }
    }
    End {}
}