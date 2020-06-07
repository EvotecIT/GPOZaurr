function Add-GPOZaurrPermission {
    [cmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'GPOGUID')]
    param(
        [Parameter(ParameterSetName = 'GPOName', Mandatory)]
        [string] $GPOName,

        [Parameter(ParameterSetName = 'GPOGUID', Mandatory)]
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [Parameter(ParameterSetName = 'ADObject', Mandatory)]
        [alias('OrganizationalUnit', 'DistinguishedName')][Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,

        [validateset('WellKnownAdministrative', 'Administrative', 'AuthenticatedUsers', 'Default')][string] $Type = 'Default',

        [alias('Trustee')][string] $Principal,
        [alias('TrusteeType')][validateset('DistinguishedName', 'Name', 'Sid')][string] $PrincipalType = 'DistinguishedName',

        [Parameter(Mandatory)][alias('IncludePermissionType')][Microsoft.GroupPolicy.GPPermissionType] $PermissionType,
        [switch] $Inheritable,

        [validateSet('Allow', 'Deny', 'All')][string] $PermitType = 'All',

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [System.Collections.IDictionary] $ADAdministrativeGroups,
        [int] $LimitProcessing
    )
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -Extended
    if (-not $ADAdministrativeGroups) {
        $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    }
    if ($GPOName) {
        $Splat = @{
            GPOName = $GPOName
        }
    } elseif ($GPOGUID) {
        $Splat = @{
            GPOGUID = $GPOGUID
        }
    } else {
        $Splat = @{}
    }
    $Splat['IncludeGPOObject'] = $true
    $Splat['Forest'] = $Forest
    $Splat['IncludeDomains'] = $IncludeDomains
    if ($Type -ne 'Default') {
        $Splat['Type'] = $Type
    }
    $Splat['PermitType'] = $PermitType
    $Splat['Principal'] = $Principal
    if ($PrincipalType) {
        $Splat.PrincipalType = $PrincipalType
    }
    $Splat['ExcludeDomains'] = $ExcludeDomains
    $Splat['ExtendedForestInformation'] = $ExtendedForestInformation
    #$Splat['ExcludePermissionType'] = $ExcludePermissionType
    $Splat['IncludePermissionType'] = $PermissionType
    $Splat['SkipWellKnown'] = $SkipWellKnown.IsPresent
    $Splat['SkipAdministrative'] = $SkipAdministrative.IsPresent

    $AdministrativeExists = @{
        DomainAdmins     = $false
        EnterpriseAdmins = $false
    }

    # This should always return results. When no data is found it should return basic information that will allow us to add credentials.
    [Array] $GPOPermissions = Get-GPOZaurrPermission @Splat -ReturnSecurityWhenNoData
    # When it has GPOSecurityPermissionItem property it means it has permissions, if it doesn't it means we have clean object to process
    if ($GPOPermissions.GPOSecurityPermissionItem) {
        # Permission exists, but may be incomplete
        foreach ($GPOPermission in $GPOPermissions) {
            if ($Type -eq 'Default') {
                # We were looking for specific principal and we got it. nothing to do
                # this is for standard users such as przemyslaw.klys / adam.gonzales
                return
            } elseif ($Type -eq 'Administrative') {
                # We are looking for administrative but we need to make sure we got correct administrative
                if ($GPOPermission.Permission -eq $PermissionType) {
                    $AdministrativeGroup = $ADAdministrativeGroups['BySID'][$GPOPermission.SID]
                    if ($AdministrativeGroup.SID -like '*-519') {
                        $AdministrativeExists['EnterpriseAdmins'] = $true
                    } elseif ($AdministrativeGroup.SID -like '*-512') {
                        $AdministrativeExists['DomainAdmins'] = $true
                    }
                    <#
                    if ($AdministrativeGroup) {
                        $DomainAdminsSID = -join ($ForestInformation['DomainsExtended'][$GPOPermission.DomainName].DomainSID, '-512')
                        $EnterpriseAdminsSID = -join ($ForestInformation['DomainsExtended'][$GPOPermission.DomainName].DomainSID, '-519')
                        if ($GPOPermission.SID -eq $DomainAdminsSID) {
                            $AdministrativeExists['DomainAdmins'] = $true
                        } elseif ($GPOPermission.SID -eq $EnterpriseAdminsSID) {
                            $AdministrativeExists['EnterpriseAdmins'] = $true
                        }
                    }
                    #>
                }
            } elseif ($Type -eq 'WellKnownAdministrative') {
                # this is for SYSTEM account
                return
            } elseif ($Type -eq 'AuthenticatedUsers') {
                # this is for Authenticated Users
                return
            }
        }
    }
    if (-not $GPOPermissions) {
        # This is bad - things went wrong
        Write-Warning "Add-GPOZaurrPermission - Couldn't get permissions for GPO. Things aren't what they should be. Skipping!"
    } else {
        $GPO = $GPOPermissions[0]
        if ($GPOPermissions.GPOSecurityPermissionItem) {
            # We asked, we got response, now we need to check if maybe we're missing one of the two administrative groups
            if ($Type -eq 'Administrative') {
                # this is a case where something was returned. Be it Domain Admins or Enterprise Admins or both. But we still need to check because it may have been Domain Admins from other domain or just one of the two required groups
                if ($AdministrativeExists['DomainAdmins'] -eq $false) {
                    $Principal = $ADAdministrativeGroups[$GPO.DomainName]['DomainAdmins']
                    Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal) to $($GPO.DisplayName) at $($GPO.DomainName)"
                    if ($PSCmdlet.ShouldProcess($GPO.DisplayName, "Adding $Principal / $PermissionType to $($GPO.DisplayName) at $($GPO.DomainName)")) {
                        try {
                            $AddPermission = [Microsoft.GroupPolicy.GPPermission]::new($Principal, $PermissionType, $Inheritable.IsPresent)
                            $GPO.GPOSecurity.Add($AddPermission)
                            $GPO.GPOObject.SetSecurityInfo($GPO.GPOSecurity)
                        } catch {
                            Write-Warning "Add-GPOZaurrPermission - Adding permission $PermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                        }
                    }
                }
                if ($AdministrativeExists['EnterpriseAdmins'] -eq $false) {
                    $Principal = $ADAdministrativeGroups[$ForestInformation.Forest.RootDomain]['EnterpriseAdmins']
                    Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal) to $($GPO.DisplayName) at $($GPO.DomainName)"
                    if ($PSCmdlet.ShouldProcess($GPO.DisplayName, "Adding $Principal / $PermissionType to $($GPO.DisplayName) at $($GPO.DomainName)")) {
                        try {
                            $AddPermission = [Microsoft.GroupPolicy.GPPermission]::new($Principal, $PermissionType, $Inheritable.IsPresent)
                            $GPO.GPOSecurity.Add($AddPermission)
                            $GPO.GPOObject.SetSecurityInfo($GPO.GPOSecurity)
                        } catch {
                            Write-Warning "Add-GPOZaurrPermission - Adding permission $PermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                        }
                    }
                }
            } elseif ($Type -eq 'Default') {
                # This shouldn't really happen, as if we got response, and it didn't exists it wouldn't be here
                Write-Warning "Add-GPOZaurrPermission - Adding permission $PermissionType skipped for $($Principal). This shouldn't even happen!"
            }
        } else {
            # We got no response. That means we either asked incorrectly or we need to fix permission. Trying to do so
            if ($Type -eq 'Default') {
                Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal) to $($GPO.DisplayName) at $($GPO.DomainName)"
                if ($PSCmdlet.ShouldProcess($GPO.DisplayName, "Adding $Principal / $PermissionType to $($GPO.DisplayName) at $($GPO.DomainName)")) {
                    try {
                        Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal)"
                        $AddPermission = [Microsoft.GroupPolicy.GPPermission]::new($Principal, $PermissionType, $Inheritable.IsPresent)
                        $GPO.GPOSecurity.Add($AddPermission)
                        $GPO.GPOObject.SetSecurityInfo($GPO.GPOSecurity)
                    } catch {
                        Write-Warning "Add-GPOZaurrPermission - Adding permission $PermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                    }
                }
            } elseif ($Type -eq 'Administrative') {
                # this is a case where both Domain Admins/Enterprise Admins were missing
                $Principal = $ADAdministrativeGroups[$GPO.DomainName]['DomainAdmins']
                Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal) to $($GPO.DisplayName) at $($GPO.DomainName)"
                if ($PSCmdlet.ShouldProcess($GPO.DisplayName, "Adding $Principal / $PermissionType to $($GPO.DisplayName) at $($GPO.DomainName)")) {
                    try {
                        $AddPermission = [Microsoft.GroupPolicy.GPPermission]::new($Principal, $PermissionType, $Inheritable.IsPresent)
                        $GPO.GPOSecurity.Add($AddPermission)
                        $GPO.GPOObject.SetSecurityInfo($GPO.GPOSecurity)
                    } catch {
                        Write-Warning "Add-GPOZaurrPermission - Adding permission $PermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                    }
                }
                $Principal = $ADAdministrativeGroups[$ForestInformation.Forest.RootDomain]['EnterpriseAdmins']
                Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal) to $($GPO.DisplayName) at $($GPO.DomainName)"
                if ($PSCmdlet.ShouldProcess($GPO.DisplayName, "Adding $Principal / $PermissionType to $($GPO.DisplayName) at $($GPO.DomainName)")) {
                    try {
                        $AddPermission = [Microsoft.GroupPolicy.GPPermission]::new($Principal, $PermissionType, $Inheritable.IsPresent)
                        $GPO.GPOSecurity.Add($AddPermission)
                        $GPO.GPOObject.SetSecurityInfo($GPO.GPOSecurity)
                    } catch {
                        Write-Warning "Add-GPOZaurrPermission - Adding permission $PermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                    }
                }
            } elseif ($Type -eq 'WellKnownAdministrative') {
                $Principal = 'S-1-5-18'
                Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal) to $($GPO.DisplayName) at $($GPO.DomainName)"
                if ($PSCmdlet.ShouldProcess($GPO.DisplayName, "Adding $Principal (SYSTEM) / $PermissionType to $($GPO.DisplayName) at $($GPO.DomainName)")) {
                    try {
                        $AddPermission = [Microsoft.GroupPolicy.GPPermission]::new($Principal, $PermissionType, $Inheritable.IsPresent)
                        $GPO.GPOSecurity.Add($AddPermission)
                        $GPO.GPOObject.SetSecurityInfo($GPO.GPOSecurity)
                    } catch {
                        Write-Warning "Add-GPOZaurrPermission - Adding permission $PermissionType failed for $($Principal) (SYSTEM) with error: $($_.Exception.Message)"
                    }
                }
            } elseif ($Type -eq 'AuthenticatedUsers') {
                $Principal = 'S-1-5-11'
                Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal) to $($GPO.DisplayName) at $($GPO.DomainName)"
                if ($PSCmdlet.ShouldProcess($GPO.DisplayName, "Adding $Principal (Authenticated Users) / $PermissionType to $($GPO.DisplayName) at $($GPO.DomainName)")) {
                    try {
                        $AddPermission = [Microsoft.GroupPolicy.GPPermission]::new($Principal, $PermissionType, $Inheritable.IsPresent)
                        $GPO.GPOSecurity.Add($AddPermission)
                        $GPO.GPOObject.SetSecurityInfo($GPO.GPOSecurity)
                    } catch {
                        Write-Warning "Add-GPOZaurrPermission - Adding permission $PermissionType failed for $($Principal) (Authenticated Users) with error: $($_.Exception.Message)"
                    }
                }
            }
        }

    }
}