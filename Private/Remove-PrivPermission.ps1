function Remove-PrivPermission {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [string] $Principal,
        [validateset('DistinguishedName', 'Name', 'Sid')][string] $PrincipalType = 'DistinguishedName',
        [PSCustomObject] $GPOPermission,
        [alias('PermissionType')][Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType

    )
    if ($PrincipalType -eq 'DistinguishedName') {
        if ($GPOPermission.DistinguishedName -eq $Principal -and $GPOPermission.Permission -eq $IncludePermissionType) {
            if ($PSCmdlet.ShouldProcess($GPOPermission.DisplayName, "Removing $($GPOPermission.Sid)/$($GPOPermission.Name) from domain $($GPOPermission.DomainName)")) {
                try {
                    Write-Verbose "Remove-GPOZaurrPermission - Removing permission $IncludePermissionType for $($Principal) / $($GPOPermission.Name)"
                    $GPOPermission.GPOSecurity.Remove($GPOPermission.GPOSecurityPermissionIndex)
                    $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                } catch {
                    Write-Warning "Remove-GPOZaurrPermission - Adding permission $IncludePermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                }
            }
        }
    } elseif ($PrincipalType -eq 'Sid') {
        if ($GPOPermission.Sid -eq $Principal -and $GPOPermission.Permission -eq $IncludePermissionType) {
            if ($PSCmdlet.ShouldProcess($GPOPermission.DisplayName, "Removing $($GPOPermission.Sid)/$($GPOPermission.Name) from domain $($GPOPermission.DomainName)")) {
                try {
                    Write-Verbose "Remove-GPOZaurrPermission - Removing permission $IncludePermissionType for $($Principal) / $($GPOPermission.Name)"
                    $GPOPermission.GPOSecurity.Remove($GPOPermission.GPOSecurityPermissionIndex)
                    $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                } catch {
                    Write-Warning "Remove-GPOZaurrPermission - Adding permission $IncludePermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                }
            }
        }
    } elseif ($PrincipalType -eq 'Name') {
        if ($GPOPermission.Name -eq $Principal -and $GPOPermission.Permission -eq $IncludePermissionType) {
            if ($PSCmdlet.ShouldProcess($GPOPermission.DisplayName, "Removing $($GPOPermission.Sid)/$($GPOPermission.Name) from domain $($GPOPermission.DomainName)")) {
                try {
                    Write-Verbose "Remove-GPOZaurrPermission - Removing permission $IncludePermissionType for $($Principal)"
                    $GPOPermission.GPOSecurity.Remove($GPOPermission.GPOSecurityPermissionIndex)
                    $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                } catch {
                    Write-Warning "Remove-GPOZaurrPermission - Adding permission $IncludePermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                }
            }
        }
    }
}
