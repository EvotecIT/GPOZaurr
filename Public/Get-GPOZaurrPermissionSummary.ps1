function Get-GPOZaurrPermissionSummary {
    [cmdletBinding()]
    param(
        [validateSet('AuthenticatedUsers', 'DomainComputers', 'Unknown', 'WellKnownAdministrative', 'NotWellKnown', 'NotWellKnownAdministrative', 'NotAdministrative', 'Administrative', 'All')][string[]] $Type = 'All',
        [validateSet('Allow', 'Deny', 'All')][string] $PermitType = 'All',
        [Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType,
        [Microsoft.GroupPolicy.GPPermissionType[]] $ExcludePermissionType,
        [switch] $IncludeOwner,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [string] $Separator
    )
    $RootPermissions = Get-GPOZaurrPermissionRoot -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    $Permissions = Get-GPOZaurrPermission -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -IncludePermissionType $IncludePermissionType -ExcludePermissionType $ExcludePermissionType -Type $Type -PermitType $PermitType -IncludeOwner:$IncludeOwner
    $Entries = @(
        foreach ($Permission in $Permissions) {
            [PSCustomObject] @{
                PrincipalName       = $Permission.PrincipalName
                PrincipalDomainName = $Permission.PrincipalDomainName
                Permission          = $Permission.Permission
                PermissionType      = $Permission.PermissionType
                PrincipalSid        = $Permission.PrincipalSid
                PrincipalSidType    = $Permission.PrincipalSidType
                DisplayName         = $Permission.DisplayName
                DomainName          = $Permission.DomainName
            }
        }
        foreach ($RootPermission in $RootPermissions) {
            [PSCustomObject] @{
                PrincipalName       = $RootPermission.PrincipalName
                PrincipalDomainName = $Permission.PrincipalDomainName
                Permission          = $RootPermission.Permission
                PermissionType      = $RootPermission.PermissionType
                PrincipalSid        = $RootPermission.PrincipalSid
                PrincipalSidType    = $RootPermission.PrincipalSidType
                DisplayName         = $RootPermission.GPONames
                DomainName          = $RootPermission.DomainName
            }
        }
    )
    ($Entries | Group-Object -Property Permission, PrincipalSidType, PrincipalName, PrincipalDomainName, DomainName, PermissionType) | ForEach-Object {
        $Property = $_.Name -split ', '
        Write-Verbose "$Property - $($Property.Count)"
        if ($Property[0] -eq 'GpoOwner') {
            [PSCustomObject] @{
                Permission          = $Property[0]
                PrincipalSidType    = $Property[1]
                PrincipalName       = $Property[2]
                PrincipalDomainName = $Property[3]
                DomainName          = $Property[4]
                PermissionType      = 'Allow'
                GPOCount            = $_.Count
                GPONames            = if ($Separator) { $_.Group.DisplayName -join $Separator } else { $_.Group.DisplayName }
            }
        } elseif ($Property.Count -eq 5) {
            [PSCustomObject] @{
                Permission          = $Property[0]
                PrincipalSidType    = $Property[1]
                PrincipalName       = $Property[2]
                PrincipalDomainName = $Property[3]
                DomainName          = $Property[4]
                PermissionType      = if ($Property[5]) { $Property[5] } else { 'Owner' }
                GPOCount            = $_.Count
                GPONames            = if ($Separator) { $_.Group.DisplayName -join $Separator } else { $_.Group.DisplayName }
            }
        } else {
            [PSCustomObject] @{
                Permission          = $Property[0]
                PrincipalSidType    = $Property[1]
                PrincipalName       = ''
                PrincipalDomainName = ''
                DomainName          = $Property[2]
                PermissionType      = if ($Property[3]) { $Property[3] } else { 'Owner' }
                GPOCount            = $_.Count
                GPONames            = if ($Separator) { $_.Group.DisplayName -join $Separator } else { $_.Group.DisplayName }
            }
        }
    }
}