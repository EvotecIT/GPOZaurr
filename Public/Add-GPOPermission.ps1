function Add-GPOPermission {
    [cmdletBinding()]
    param(
        [validateset('WellKnownAdministrative', 'Administrative', 'AuthenticatedUsers', 'Default')][string] $Type = 'Default',
        [Microsoft.GroupPolicy.GPPermissionType] $IncludePermissionType,
        [alias('Trustee')][string] $Principal,
        [alias('TrusteeType')][validateset('DistinguishedName', 'Name', 'Sid')][string] $PrincipalType = 'DistinguishedName',
        [validateSet('Allow', 'Deny')][string] $PermitType = 'Allow'
    )
    if ($Type -eq 'Default') {
        @{
            Action                = 'Add'
            Type                  = 'Default'
            Principal             = $Principal
            IncludePermissionType = $IncludePermissionType
            PrincipalType         = $PrincipalType
            PermitType            = $PermitType
        }
    } elseif ($Type -eq 'AuthenticatedUsers') {
        @{
            Action                = 'Add'
            Type                  = 'AuthenticatedUsers'
            IncludePermissionType = $IncludePermissionType
            PermitType            = $PermitType
        }
    } elseif ($Type -eq 'Administrative') {
        @{
            Action                = 'Add'
            Type                  = 'Administrative'
            IncludePermissionType = $IncludePermissionType
            PermitType            = $PermitType
        }
    } elseif ($Type -eq 'WellKnownAdministrative') {
        @{
            Action                = 'Add'
            Type                  = 'WellKnownAdministrative'
            IncludePermissionType = $IncludePermissionType
            PermitType            = $PermitType
        }
    }
}