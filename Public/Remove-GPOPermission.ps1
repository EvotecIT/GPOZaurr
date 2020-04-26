function Remove-GPOPermission {
    [cmdletBinding()]
    param(
        [validateSet('Unknown', 'NotWellKnown', 'NotWellKnownAdministrative', 'Administrative', 'NotAdministrative', 'All')][string[]] $Type,
        [Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType,
        [Microsoft.GroupPolicy.GPPermissionType[]] $ExcludePermissionType
    )

    if ($Type) {
        @{
            Action                = 'Remove'
            Type                  = $Type
            IncludePermissionType = $IncludePermissionType
            ExcludePermissionType = $ExcludePermissionType
        }
    }
    <#
    foreach ($T in $Type) {
        foreach ($Permission in $IncludePermissionType) {
            if ($T -eq 'NotWellKnownAdministrative') {
                $Script:Actions[$Permission][$T] = $true
            } elseif ($T -eq 'NotAdministrative') {
                $Script:Actions[$Permission][$T] = $true
            }
        }
    }
    #>
}
<#
function Find-GPOPermission {
    param(
        $GPOPermissions,
        [Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType,
        [bool] $NotAdministrative,
        [bool] $NotWellKnownAdministrative
    )
    foreach ($Permission in $GPOPermissions) {
        if ($Permission.Permission -in $IncludePermissionType) {
            if ($NotAdministrative -and $NotWellKnownAdministrative) {
                $Permission
            }
        }
    }
}
#>