function Get-GPOZaurrPermissionSummary {
    <#
    .SYNOPSIS
    Retrieves a summary of Group Policy Object (GPO) permissions based on specified criteria.

    .DESCRIPTION
    Retrieves a summary of GPO permissions based on the specified criteria, including filtering by permission types, permit types, and more.

    .PARAMETER Type
    Specifies the type of permissions to include. Options include 'AuthenticatedUsers', 'DomainComputers', 'Unknown', 'WellKnownAdministrative', 'NotWellKnown', 'NotWellKnownAdministrative', 'NotAdministrative', 'Administrative', and 'All'.

    .PARAMETER PermitType
    Specifies the type of permission to permit. Options include 'Allow', 'Deny', and 'All'.

    .PARAMETER IncludePermissionType
    Specifies the permission types to include in the summary.

    .PARAMETER ExcludePermissionType
    Specifies the permission types to exclude from the summary.

    .PARAMETER Forest
    Specifies the target forest. By default, the current forest is used.

    .PARAMETER ExcludeDomains
    Specifies domains to exclude from the search.

    .PARAMETER IncludeDomains
    Specifies domains to include in the search.

    .PARAMETER ExtendedForestInformation
    Provides additional forest information to speed up processing.

    .PARAMETER Separator
    Specifies the separator to use in the output.

    .EXAMPLE
    Get-GPOZaurrPermissionSummary -Type 'All' -PermitType 'Allow' -IncludePermissionType 'GpoApply', 'GpoEdit' -ExcludePermissionType 'GpoOwner' -Forest 'ExampleForest' -IncludeDomains 'Domain1', 'Domain2' -ExtendedForestInformation $ForestInfo -Separator '|'

    .EXAMPLE
    Get-GPOZaurrPermissionSummary -Type 'Administrative' -PermitType 'All' -IncludePermissionType 'GpoRead' -ExcludePermissionType 'GpoRootOwner' -Forest 'AnotherForest' -ExcludeDomains 'Domain3' -Separator ','

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [validateSet('AuthenticatedUsers', 'DomainComputers', 'Unknown', 'WellKnownAdministrative', 'NotWellKnown', 'NotWellKnownAdministrative', 'NotAdministrative', 'Administrative', 'All')][string[]] $Type = 'All',
        [validateSet('Allow', 'Deny', 'All')][string] $PermitType = 'All',
        [ValidateSet('GpoApply', 'GpoEdit', 'GpoCustom', 'GpoEditDeleteModifySecurity', 'GpoRead', 'GpoOwner', 'GpoRootCreate', 'GpoRootOwner')][string[]] $IncludePermissionType,
        [ValidateSet('GpoApply', 'GpoEdit', 'GpoCustom', 'GpoEditDeleteModifySecurity', 'GpoRead', 'GpoOwner', 'GpoRootCreate', 'GpoRootOwner')][string[]] $ExcludePermissionType,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [string] $Separator
    )

    $IncludePermTypes = [System.Collections.Generic.List[Microsoft.GroupPolicy.GPPermissionType]]::new()
    $ExcludePermTypes = [System.Collections.Generic.List[Microsoft.GroupPolicy.GPPermissionType]]::new()
    $CustomPermissions = [System.Collections.Generic.List[string]]::new()
    foreach ($PermType in $IncludePermissionType) {
        if ($PermType -in 'GpoApply', 'GpoEdit', 'GPOCustom', 'GpoEditDeleteModifySecurity', 'GPORead') {
            $IncludePermTypes.Add([Microsoft.GroupPolicy.GPPermissionType]::$PermType)
        } elseif ($PermType -in 'GpoOwner') {
            $IncludeOwner = $true
        } elseif ($PermType -in 'GpoRootCreate', 'GpoRootOwner') {
            $CustomPermissions.Add($PermType)
        }
    }
    foreach ($PermType in $ExcludePermissionType) {
        if ($PermType -in 'GpoApply', 'GpoEdit', 'GPOCustom', 'GpoEditDeleteModifySecurity', 'GPORead') {
            $ExcludePermTypes.Add([Microsoft.GroupPolicy.GPPermissionType]::$PermType)
        } elseif ($PermType -in 'GpoOwner') {
            $IncludeOwner = $false
        } elseif ($PermType -in 'GpoRootCreate', 'GpoRootOwner') {
            $CustomPermissions.Add($PermType)
        }
    }

    $RootPermissions = Get-GPOZaurrPermissionRoot -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    $Permissions = Get-GPOZaurrPermission -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -IncludePermissionType $IncludePermTypes -ExcludePermissionType $ExcludePermissionType -Type $Type -PermitType $PermitType -IncludeOwner:$IncludeOwner
    $Entries = @(
        foreach ($Permission in $Permissions) {
            [PSCustomObject] @{
                PrincipalName        = $Permission.PrincipalName
                PrincipalDomainName  = $Permission.PrincipalDomainName
                Permission           = $Permission.Permission
                PermissionType       = $Permission.PermissionType
                PrincipalSid         = $Permission.PrincipalSid
                PrincipalSidType     = $Permission.PrincipalSidType
                PrincipalObjectClass = $Permission.PrincipalObjectClass
                DisplayName          = $Permission.DisplayName
                DomainName           = $Permission.DomainName
            }
        }
        foreach ($RootPermission in $RootPermissions) {
            [PSCustomObject] @{
                PrincipalName        = $RootPermission.PrincipalName
                PrincipalDomainName  = $RootPermission.PrincipalDomainName
                Permission           = $RootPermission.Permission
                PermissionType       = $RootPermission.PermissionType
                PrincipalSid         = $RootPermission.PrincipalSid
                PrincipalSidType     = $RootPermission.PrincipalSidType
                PrincipalObjectClass = $RootPermission.PrincipalObjectClass
                DisplayName          = $RootPermission.GPONames
                DomainName           = $RootPermission.DomainName
            }
        }
    )
    $PermissionsData = [ordered] @{}
    foreach ($Entry in $Entries) {
        $Key = -join ($Entry.Permission, $Entry.PrincipalName, $Entry.PrincipalDomainName)
        if (-not $PermissionsData[$Key]) {
            $PermissionsData[$Key] = [PSCustomObject] @{
                Permission          = $Entry.Permission
                PrincipalName       = $Entry.PrincipalName
                PrincipalDomainName = $Entry.PrincipalDomainName
                PrincipalSidType    = $Entry.PrincipalSidType
                DomainName          = $Entry.DomainName
                PermissionType      = $Entry.PermissionType
                GPOCOunt            = 0
                GPONames            = [System.Collections.Generic.List[string]]::new()
            }
        }
        #if ($IncludeNames) {
        $PermissionsData[$Key].GPONames.Add($Entry.DisplayName)
        #}
        $PermissionsData[$Key].GPOCOunt = $PermissionsData[$Key].GPOCOunt + ($Entry.DisplayName).Count
    }
    $PermissionsData.Values

    <#
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
    #>
}