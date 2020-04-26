function Add-GPOPermission {
    [cmdletBinding()]
    param(
        [validateset('WellKnownAdministrative','Administrative', 'AuthenticatedUsers', 'Default')][string] $Type = 'Default',
        [Microsoft.GroupPolicy.GPPermissionType] $IncludePermissionType,
        [alias('Principal')][Array] $Trustee,
        [alias('PrincipalType')][validateset('DistinguishedName', 'Name', 'Sid')][string] $TrusteeType = 'DistinguishedName'
    )
    if ($Type -eq 'Default'){
        @{
            Action                = 'Add'
            Type                  = 'Standard'
            Trustee               = $Trustee
            IncludePermissionType = $IncludePermissionType
            TrusteeType           = $TrusteeType
        }
    } elseif ($Type -eq 'AuthenticatedUsers') {
        @{
            Action = 'Add'
            Type   = 'AuthenticatedUsers'
            IncludePermissionType = $IncludePermissionType
        }
    } elseif ($Type -eq 'Administrative') {
        @{
            Action = 'Add'
            Type   = 'Administrative'
            IncludePermissionType = $IncludePermissionType
        }
    }
}