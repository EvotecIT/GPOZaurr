function Remove-GPOPermission {
    [cmdletBinding()]
    param(
        [validateSet('Unknown', 'NotWellKnown', 'NotWellKnownAdministrative', 'Administrative', 'NotAdministrative', 'All')][string[]] $Type,
        [Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType,
        [Microsoft.GroupPolicy.GPPermissionType[]] $ExcludePermissionType,
        [validateSet('Allow', 'Deny', 'All')][string] $PermitType = 'Allow',

        [string[]] $Principal,
        [validateset('DistinguishedName', 'Name', 'Sid')][string] $PrincipalType = 'Sid',

        [string[]] $ExcludePrincipal,
        [validateset('DistinguishedName', 'Name', 'Sid')][string] $ExcludePrincipalType = 'Sid'
    )

    if ($Type) {
        @{
            Action                = 'Remove'
            Type                  = $Type
            IncludePermissionType = $IncludePermissionType
            ExcludePermissionType = $ExcludePermissionType
            PermitType            = $PermitType
            Principal             = $Principal
            PrincipalType         = $PrincipalType
            ExcludePrincipal      = $ExcludePrincipal
            ExcludePrincipalType  = $ExcludePrincipalType
        }
    }
}