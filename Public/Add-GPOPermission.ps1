function Add-GPOPermission {
    <#
    .SYNOPSIS
    Adds a permission to a Group Policy Object (GPO).

    .DESCRIPTION
    This function adds a permission to a specified Group Policy Object (GPO) based on the provided parameters.

    .PARAMETER Type
    Specifies the type of permission to add. Valid values are 'WellKnownAdministrative', 'Administrative', 'AuthenticatedUsers', and 'Default'.

    .PARAMETER IncludePermissionType
    Specifies the permission type to include.

    .PARAMETER Principal
    Specifies the principal to which the permission is granted.

    .PARAMETER PrincipalType
    Specifies the type of the principal. Valid values are 'DistinguishedName', 'Name', and 'Sid'.

    .PARAMETER PermitType
    Specifies whether to allow or deny the permission. Valid values are 'Allow' and 'Deny'.

    .EXAMPLE
    Add-GPOPermission -Type Default -IncludePermissionType Read -Principal "Domain Admins" -PrincipalType DistinguishedName -PermitType Allow
    Adds a permission to the GPO with default settings allowing 'Domain Admins' to read.

    .EXAMPLE
    Add-GPOPermission -Type Administrative -IncludePermissionType Write -Principal "Finance Group" -PrincipalType Name -PermitType Allow
    Adds a permission to the GPO for the 'Finance Group' allowing write access.

    .EXAMPLE
    Add-GPOPermission -Type AuthenticatedUsers -IncludePermissionType Modify -PermitType Deny
    Adds a permission to the GPO for all authenticated users denying modification.

    .EXAMPLE
    Add-GPOPermission -Type WellKnownAdministrative -IncludePermissionType FullControl -Principal "Enterprise Admins" -PrincipalType Sid -PermitType Allow
    Adds a permission to the GPO for 'Enterprise Admins' with full control.

    #>
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