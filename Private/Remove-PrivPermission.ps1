function Remove-PrivPermission {
    <#
    .SYNOPSIS
    Removes a specified permission from a Group Policy Object (GPO).

    .DESCRIPTION
    This function removes a specified permission from a GPO based on the provided Principal and PrincipalType. It supports removing permissions by DistinguishedName or SID. It also provides the option to include specific permission types.

    .PARAMETER Principal
    Specifies the principal for which the permission needs to be removed.

    .PARAMETER PrincipalType
    Specifies the type of the principal. Valid values are 'DistinguishedName', 'Name', or 'Sid'.

    .PARAMETER GPOPermission
    Specifies the GPO permission object to remove.

    .PARAMETER IncludePermissionType
    Specifies the permission type to include in the removal process.

    .EXAMPLE
    Remove-PrivPermission -Principal "CN=User1,OU=Users,DC=Contoso,DC=com" -PrincipalType "DistinguishedName" -GPOPermission $PermissionObject -IncludePermissionType "Read"

    This example removes the "Read" permission for the user with the specified DistinguishedName from the GPO.

    .EXAMPLE
    Remove-PrivPermission -Principal "S-1-5-21-3623811015-3361044348-30300820-1013" -PrincipalType "Sid" -GPOPermission $PermissionObject -IncludePermissionType "Write"

    This example removes the "Write" permission for the user with the specified SID from the GPO.
    #>
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [string] $Principal,
        [validateset('DistinguishedName', 'Name', 'Sid')][string] $PrincipalType = 'DistinguishedName',
        [PSCustomObject] $GPOPermission,
        [alias('PermissionType')][Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType
    )
    if ($GPOPermission.PrincipalName) {
        $Text = "Removing SID: $($GPOPermission.PrincipalSid), Name: $($GPOPermission.PrincipalDomainName)\$($GPOPermission.PrincipalName), SidType: $($GPOPermission.PrincipalSidType) from domain $($GPOPermission.DomainName)"
    } else {
        $Text = "Removing SID: $($GPOPermission.PrincipalSid), Name: EMPTY, SidType: $($GPOPermission.PrincipalSidType) from domain $($GPOPermission.DomainName)"
    }
    if ($PrincipalType -eq 'DistinguishedName') {
        if ($GPOPermission.DistinguishedName -eq $Principal -and $GPOPermission.Permission -eq $IncludePermissionType) {
            if ($PSCmdlet.ShouldProcess($GPOPermission.DisplayName, $Text)) {
                try {
                    Write-Verbose "Remove-GPOZaurrPermission - Removing permission $IncludePermissionType for $($Principal) / $($GPOPermission.PrincipalName) / Type: $($GPOPermission.PermissionType)"
                    $GPOPermission.GPOSecurity.Remove($GPOPermission.GPOSecurityPermissionItem)
                    $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                } catch {
                    Write-Warning "Remove-GPOZaurrPermission - Removing permission $IncludePermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                }
            }
        }
    } elseif ($PrincipalType -eq 'Sid') {
        if ($GPOPermission.PrincipalSid -eq $Principal -and $GPOPermission.Permission -eq $IncludePermissionType) {
            if ($PSCmdlet.ShouldProcess($GPOPermission.DisplayName, $Text)) {
                try {
                    Write-Verbose "Remove-GPOZaurrPermission - Removing permission $IncludePermissionType for $($Principal) / $($GPOPermission.PrincipalName) / Type: $($GPOPermission.PermissionType)"
                    $GPOPermission.GPOSecurity.Remove($GPOPermission.GPOSecurityPermissionItem)
                    $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                } catch {
                    if ($_.Exception.Message -like '*The request is not supported. (Exception from HRESULT: 0x80070032)*') {
                        Write-Warning "Remove-GPOZaurrPermission - Bummer! The request is not supported, but lets fix it differently."
                        # This is basically atomic approach. We will totally remove any permissions for that user on ACL level to get rid of this situation.
                        # This situation should only happen if DENY is on FULL Control
                        $ACL = Get-ADACL -ADObject $GPOPermission.GPOObject.Path -Bundle #-Verbose:$VerbosePreference
                        if ($ACL) {
                            Remove-ADACL -ACL $ACL -Principal $Principal -AccessControlType Deny -Verbose:$VerbosePreference
                        }
                        # I've noticed that in situation where Edit settings, delete, modify security is set and then set to Deny we need to fix it once more
                        $ACL = Get-ADACL -ADObject $GPOPermission.GPOObject.Path -Bundle
                        if ($ACL) {
                            Remove-ADACL -ACL $ACL -Principal $Principal -AccessControlType Allow -Verbose:$VerbosePreference
                        }
                    } else {
                        Write-Warning "Remove-GPOZaurrPermission - Removing permission $IncludePermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                    }
                }
            }
        }
    } elseif ($PrincipalType -eq 'Name') {
        if ($GPOPermission.PrincipalName -eq $Principal -and $GPOPermission.Permission -eq $IncludePermissionType) {
            if ($PSCmdlet.ShouldProcess($GPOPermission.DisplayName, $Text)) {
                try {
                    Write-Verbose "Remove-GPOZaurrPermission - Removing permission $IncludePermissionType for $($Principal) / $($GPOPermission.PrincipalName) / Type: $($GPOPermission.PermissionType)"
                    $GPOPermission.GPOSecurity.Remove($GPOPermission.GPOSecurityPermissionItem)
                    $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                } catch {
                    Write-Warning "Remove-GPOZaurrPermission - Removing permission $IncludePermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                }
            }
        }
    }
}
