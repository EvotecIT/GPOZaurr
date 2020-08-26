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

    $Permissions = Get-GPOZaurrPermission -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -IncludePermissionType $IncludePermissionType -ExcludePermissionType $ExcludePermissionType -Type $Type -PermitType $PermitType -IncludeOwner:$IncludeOwner
    $Entries = foreach ($Permission in $Permissions) {
        [PSCustomObject] @{
            Name           = $Permission.Name
            Permission     = $Permission.Permission
            PermissionType = $Permission.PermissionType
            Sid            = $Permission.Sid
            SidType        = $Permission.SidType
            DisplayName    = $Permission.DisplayName
            DomainName     = $Permission.DomainName
            Domain         = $Domain
        }
    }
    $Entries | Group-Object -Property Permission, Name, DomainName, PermissionType | ForEach-Object {
        $Property = $_.Name -split ', '
        [PSCustomObject] @{
            Permission     = $Property[0]
            Name           = $Property[1]
            DomainName     = $Property[2]
            PermissionType = if ($Property[3]) { $Property[3] } else { 'Owner' }
            GPOCount       = $_.Count
            GPONames       = if ($Separator) { $_.Group.DisplayName -join $Separator } else { $_.Group.DisplayName }
        }
    }
}