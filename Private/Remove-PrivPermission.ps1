function Remove-PrivPermission {
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
