function Remove-GPOPermission {
    <#
    .SYNOPSIS
    Removes permissions from a Group Policy Object (GPO).

    .DESCRIPTION
    This function removes specified permissions from a GPO based on the provided criteria.

    .PARAMETER Type
    Specifies the type of permissions to remove. Valid values are 'Unknown', 'NotWellKnown', 'NotWellKnownAdministrative', 'Administrative', 'NotAdministrative', and 'All'.

    .PARAMETER IncludePermissionType
    Specifies the permission types to include in the removal process.

    .PARAMETER ExcludePermissionType
    Specifies the permission types to exclude from the removal process.

    .PARAMETER PermitType
    Specifies whether to allow or deny the specified permissions. Valid values are 'Allow', 'Deny', and 'All'.

    .PARAMETER Principal
    Specifies the principal(s) for which permissions should be removed.

    .PARAMETER PrincipalType
    Specifies the type of principal(s) provided. Valid values are 'DistinguishedName', 'Name', and 'Sid'.

    .PARAMETER ExcludePrincipal
    Specifies the principal(s) for which permissions should be excluded from removal.

    .PARAMETER ExcludePrincipalType
    Specifies the type of principal(s) to exclude. Valid values are 'DistinguishedName', 'Name', and 'Sid'.

    .EXAMPLE
    Remove-GPOPermission -Type 'Administrative' -PermitType 'Deny' -Principal 'S-1-5-21-3623811015-3361044348-30300820-1013' -PrincipalType 'Sid'
    Removes administrative permissions denied for a specific SID from the GPO.

    .EXAMPLE
    Remove-GPOPermission -Type 'All' -PermitType 'Allow' -Principal 'CN=John Doe,OU=Users,DC=contoso,DC=com' -PrincipalType 'DistinguishedName' -ExcludePrincipal 'S-1-5-21-3623811015-3361044348-30300820-1013' -ExcludePrincipalType 'Sid'
    Removes all permissions allowed for a specific distinguished name while excluding permissions for a specific SID from the GPO.

    #>
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