function Get-GPOZaurrPermissionSummary {
    [cmdletBinding()]
    param(
        [Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType,
        [Microsoft.GroupPolicy.GPPermissionType[]] $ExcludePermissionType,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )

    $Permissions = Get-GPOZaurrPermission -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -IncludePermissionType $IncludePermissionType -ExcludePermissionType $ExcludePermissionType
    $Entries = foreach ($Permission in $Permissions) {
        [PSCustomObject] @{
            Name        = $Permission.Name
            Permission  = $Permission.Permission
            Sid         = $Permission.Sid
            SidType     = $Permission.SidType
            DisplayName = $Permission.DisplayName
            DomainName  = $Permission.DomainName
            Domain      = $Domain
        }
    }
    $Entries | Group-Object -Property Permission, Name, DomainName | ForEach-Object {
        $Property = $_.Name -split ', '
        [PSCustomObject] @{
            Permission = $Property[0]
            Name       = $Property[1]
            DomainName = $Property[2]
            GPOCount   = $_.Count
        }
    }
}