function Add-GPOZaurrPermission {
    <#
    .SYNOPSIS
    Adds permissions to a Group Policy Object (GPO) in Active Directory.

    .DESCRIPTION
    This function allows you to add permissions to a specified GPO in Active Directory. You can specify the GPO by name, GUID, or apply permissions to all GPOs. Various parameters allow you to customize the permission settings.

    .PARAMETER GPOName
    Specifies the name of the GPO to which permissions will be added.

    .PARAMETER GPOGuid
    Specifies the GUID of the GPO to which permissions will be added.

    .PARAMETER All
    Indicates that permissions should be added to all GPOs.

    .PARAMETER ADObject
    Specifies the Active Directory object to which permissions will be applied.

    .PARAMETER Type
    Specifies the type of permissions to be added. Valid values are 'WellKnownAdministrative', 'Administrative', 'AuthenticatedUsers', and 'Default'.

    .PARAMETER Principal
    Specifies the trustee to which permissions will be granted.

    .PARAMETER PrincipalType
    Specifies the type of the trustee. Valid values are 'DistinguishedName', 'Name', and 'Sid'.

    .PARAMETER PermissionType
    Specifies the type of permission to be added.

    .PARAMETER Inheritable
    Indicates whether permissions should be inheritable.

    .PARAMETER PermitType
    Specifies the type of permission to be granted. Valid values are 'Allow', 'Deny', and 'All'.

    .PARAMETER Forest
    Specifies the forest in which the GPO resides.

    .PARAMETER ExcludeDomains
    Specifies the domains to exclude when applying permissions.

    .PARAMETER IncludeDomains
    Specifies the domains to include when applying permissions.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest.

    .PARAMETER ADAdministrativeGroups
    Specifies the administrative groups in Active Directory.

    .PARAMETER LimitProcessing
    Specifies the maximum number of processing steps.

    .EXAMPLE
    Add-GPOZaurrPermission -GPOName "TestGPO" -Principal "User1" -PermissionType Read -PermitType Allow
    Adds read permission to "User1" for the GPO named "TestGPO".

    .EXAMPLE
    Add-GPOZaurrPermission -GPOGuid "12345678-1234-1234-1234-1234567890AB" -Principal "Group1" -PermissionType Write -PermitType Deny
    Denies write permission to "Group1" for the GPO with the specified GUID.

    #>
    [cmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'GPOName')]
    param(
        [Parameter(ParameterSetName = 'GPOName', Mandatory)][string] $GPOName,
        [Parameter(ParameterSetName = 'GPOGUID', Mandatory)][alias('GUID', 'GPOID')][string] $GPOGuid,
        [Parameter(ParameterSetName = 'All', Mandatory)][switch] $All,

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
        [int] $LimitProcessing = [int32]::MaxValue
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
    $Splat['IncludePermissionType'] = $PermissionType
    $Splat['SkipWellKnown'] = $SkipWellKnown.IsPresent
    $Splat['SkipAdministrative'] = $SkipAdministrative.IsPresent

    $CountFixed = 0

    Do {
        # This should always return results. When no data is found it should return basic information that will allow us to add credentials.
        Get-GPOZaurrPermission @Splat -ReturnSecurityWhenNoData -ReturnSingleObject | ForEach-Object {
            $GPOPermissions = $_
            $PermissionsAnalysis = Get-PermissionsAnalysis -GPOPermissions $GPOPermissions -ADAdministrativeGroups $ADAdministrativeGroups -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -Type $Type -PermissionType $PermissionType
            <#
            # Prepare data to clean
            $Skip = $false
            $AdministrativeExists = @{
                DomainAdmins     = $false
                EnterpriseAdmins = $false
            }
            $GPOPermissions = $_
            # Verification Phase
            # When it has GPOSecurityPermissionItem property it means it has permissions, if it doesn't it means we have clean object to process
            if ($GPOPermissions.GPOSecurityPermissionItem) {
                # Permission exists, but may be incomplete
                foreach ($GPOPermission in $GPOPermissions) {
                    if ($Type -eq 'Default') {
                        # We were looking for specific principal and we got it. nothing to do
                        # this is for standard users such as przemyslaw.klys / adam.gonzales
                        $Skip = $true
                        break
                    } elseif ($Type -eq 'Administrative') {
                        # We are looking for administrative but we need to make sure we got correct administrative
                        if ($GPOPermission.Permission -eq $PermissionType) {
                            $AdministrativeGroup = $ADAdministrativeGroups['BySID'][$GPOPermission.PrincipalSid]
                            if ($AdministrativeGroup.SID -like '*-519') {
                                $AdministrativeExists['EnterpriseAdmins'] = $true
                            } elseif ($AdministrativeGroup.SID -like '*-512') {
                                $AdministrativeExists['DomainAdmins'] = $true
                            }
                        }
                        if ($AdministrativeExists['DomainAdmins'] -and $AdministrativeExists['EnterpriseAdmins']) {
                            $Skip = $true
                            break
                        }
                    } elseif ($Type -eq 'WellKnownAdministrative') {
                        # this is for SYSTEM account
                        $Skip = $true
                        break
                    } elseif ($Type -eq 'AuthenticatedUsers') {
                        # this is for Authenticated Users
                        $Skip = $true
                        break
                    }
                }
            }
            #>
            if (-not $PermissionsAnalysis.'Skip') {
                if (-not $GPOPermissions) {
                    # This is bad - things went wrong
                    Write-Warning "Add-GPOZaurrPermission - Couldn't get permissions for GPO. Things aren't what they should be. Skipping!"
                } else {
                    $GPO = $GPOPermissions[0]
                    if ($GPOPermissions.GPOSecurityPermissionItem) {
                        # We asked, we got response, now we need to check if maybe we're missing one of the two administrative groups
                        if ($Type -eq 'Administrative') {
                            # this is a case where something was returned. Be it Domain Admins or Enterprise Admins or both. But we still need to check because it may have been Domain Admins from other domain or just one of the two required groups
                            if ($PermissionsAnalysis.'DomainAdmins' -eq $false) {
                                $Principal = $ADAdministrativeGroups[$GPO.DomainName]['DomainAdmins']
                                Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal) to $($GPO.DisplayName) at $($GPO.DomainName)"
                                $CountFixed++
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
                            if ($PermissionsAnalysis.'EnterpriseAdmins' -eq $false) {
                                $Principal = $ADAdministrativeGroups[$ForestInformation.Forest.RootDomain]['EnterpriseAdmins']
                                Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal) to $($GPO.DisplayName) at $($GPO.DomainName)"
                                $CountFixed++
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
                            $CountFixed++
                            if ($PrincipalType -eq 'DistinguishedName') {
                                $ADIdentity = Get-WinADObject -Identity $Principal
                                if ($ADIdentity) {
                                    Write-Verbose "Add-GPOZaurrPermission - Need to convert DN $Principal to SID $($ADIdentity.ObjectSID) to $($GPO.DisplayName) at $($GPO.DomainName)"
                                    $Principal = $ADIdentity.ObjectSID
                                }
                            }
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
                            $CountFixed++
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
                            $CountFixed++
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
                            $CountFixed++
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
                            $CountFixed++
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
            if ($CountFixed -ge $LimitProcessing) {
                # We want to exit foreach-object, but ForEach-Object doesn't really allow that
                # that's why there is Do/While which will make sure that breaks doesn't break what it's not supposed to
                break
            }
        }
    } while ($false)
}