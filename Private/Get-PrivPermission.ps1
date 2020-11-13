function Get-PrivPermission {
    [cmdletBinding()]
    param(
        [Microsoft.GroupPolicy.Gpo] $GPO,
        [Object] $SecurityRights,

        [string[]] $Principal,
        [validateset('DistinguishedName', 'Name', 'NetbiosName', 'Sid')][string] $PrincipalType = 'Sid',

        [switch] $SkipWellKnown,
        [switch] $SkipAdministrative,
        [switch] $IncludeOwner,
        [Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType,
        [Microsoft.GroupPolicy.GPPermissionType[]] $ExcludePermissionType,
        [validateSet('Allow', 'Deny', 'All')][string] $PermitType = 'All',

        [string[]] $ExcludePrincipal,
        [validateset('DistinguishedName', 'Name', 'Sid')][string] $ExcludePrincipalType = 'Sid',

        [switch] $IncludeGPOObject,
        [System.Collections.IDictionary] $ADAdministrativeGroups,
        [validateSet('AuthenticatedUsers', 'DomainComputers', 'Unknown', 'WellKnownAdministrative', 'NotWellKnown', 'NotWellKnownAdministrative', 'NotAdministrative', 'Administrative', 'All')][string[]] $Type = 'All',
        #[System.Collections.IDictionary] $Accounts,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Begin {
        Write-Verbose "Get-PrivPermission - Processing $($GPO.DisplayName) from $($GPO.DomainName)"
    }
    Process {
        $SecurityRights | ForEach-Object -Process {
            $GPOPermission = $_
            if ($PermitType -ne 'All') {
                if ($PermitType -eq 'Deny') {
                    if ($GPOPermission.Denied -eq $false) {
                        return
                    }
                } else {
                    if ($GPOPermission.Denied -eq $true) {
                        return
                    }
                }
            }
            if ($ExcludePermissionType -contains $GPOPermission.Permission) {
                return
            }
            if ($IncludePermissionType) {
                if ($IncludePermissionType -notcontains $GPOPermission.Permission) {
                    if ($IncludePermissionType -eq 'GpoRead' -and $GPOPermission.Permission -eq 'GpoApply') {
                        # We treat GpoApply as GpoRead as well. This is because when GpoApply is set it becomes GpoRead as well but of course not vice versa
                    } else {
                        return
                    }
                }
            }
            if ($SkipWellKnown.IsPresent -or $Type -contains 'NotWellKnown') {
                if ($GPOPermission.Trustee.SidType -eq 'WellKnownGroup') {
                    return
                }
            }
            if ($SkipAdministrative.IsPresent -or $Type -contains 'NotAdministrative') {
                $IsAdministrative = $ADAdministrativeGroups['BySID'][$GPOPermission.Trustee.Sid.Value]
                if ($IsAdministrative) {
                    return
                }
            }
            if ($Type -contains 'Administrative' -and $Type -notcontains 'All') {
                $IsAdministrative = $ADAdministrativeGroups['BySID'][$GPOPermission.Trustee.Sid.Value]
                if (-not $IsAdministrative) {
                    return
                }
            }
            if ($Type -contains 'NotWellKnownAdministrative' -and $Type -notcontains 'All') {
                # We check for SYSTEM account
                # Maybe we should make it a function and provide more
                if ($GPOPermission.Trustee.Sid -eq 'S-1-5-18') {
                    return
                }
            }
            if ($Type -contains 'WellKnownAdministrative' -and $Type -notcontains 'All') {
                # We check for SYSTEM account
                # Maybe we should make it a function and provide more
                if ($GPOPermission.Trustee.Sid -ne 'S-1-5-18') {
                    return
                }
            }
            if ($Type -contains 'Unknown' -and $Type -notcontains 'All') {
                # May need updates if there's more types
                if ($GPOPermission.Trustee.SidType -ne 'Unknown') {
                    return
                }
            }
            if ($Type -contains 'AuthenticatedUsers' -and $Type -notcontains 'All') {
                if ($GPOPermission.Trustee.Sid -ne 'S-1-5-11') {
                    return
                }
            }
            if ($Type -contains 'DomainComputers' -and $Type -notcontains 'All') {
                $DomainComputersSID = -join ($ExtendedForestInformation['DomainsExtended'][$GPO.DomainName].DomainSID, '-515')
                if ($GPOPermission.Trustee.Sid -ne $DomainComputersSID) {
                    return
                }
            }
            if ($GPOPermission.Trustee.Domain) {
                $UserMerge = -join ($GPOPermission.Trustee.Domain, '\', $GPOPermission.Trustee.Name)
            } else {
                $UserMerge = $null
            }
            if ($Principal) {
                if ($PrincipalType -eq 'Sid') {
                    if ($Principal -notcontains $GPOPermission.Trustee.Sid.Value) {
                        return
                    }
                } elseif ($PrincipalType -eq 'DistinguishedName') {
                    if ($Principal -notcontains $GPOPermission.Trustee.DSPath) {
                        return
                    }
                } elseif ($PrincipalType -eq 'Name') {
                    if ($Principal -notcontains $GPOPermission.Trustee.Name) {
                        return
                    }
                } elseif ($PrincipalType -eq 'NetbiosName') {
                    if ($Principal -notcontains $UserMerge) {
                        return
                    }
                }
            }
            if ($ExcludePrincipal) {
                if ($ExcludePrincipalType -eq 'Sid') {
                    if ($ExcludePrincipal -contains $GPOPermission.Trustee.Sid.Value) {
                        return
                    }
                } elseif ($ExcludePrincipalType -eq 'DistinguishedName') {
                    if ($ExcludePrincipal -contains $GPOPermission.Trustee.DSPath) {
                        return
                    }
                } elseif ($ExcludePrincipalType -eq 'Name') {
                    if ($ExcludePrincipal -contains $GPOPermission.Trustee.Name) {
                        return
                    }
                } elseif ($ExcludePrincipalType -eq 'NetbiosName') {
                    if ($ExcludePrincipal -contains $UserMerge) {
                        return
                    }
                }
            }

            <#
            # Sets permissions name, domain, distinguishedname to proper values
            if ($GPOPermission.Trustee.Name) {
                $DomainPlusName = -join ($GPOPermission.Trustee.Domain, '\', $GPOPermission.Trustee.Name)
                if ($GPOPermission.Trustee.DSPath) {
                    $NetbiosConversion = ConvertFrom-NetbiosName -Identity $DomainPlusName
                    if ($NetbiosConversion.DomainName) {
                        $UserNameDomain = $NetbiosConversion.DomainName
                        $UserName = $NetbiosConversion.Name
                    }
                } else {
                    $UserNameDomain = ''
                    $Username = $DomainPlusName
                }
            } else {
                $DomainPlusName = ''
                $UserNameDomain = ''
                $Username = ''
            }
            #>

            # I don't trust the returned data, some stuff like 'alias' shows up for groups. To unify it with everything else... using my own function
            $PermissionAccount = Get-WinADObject -Identity $GPOPermission.Trustee.Sid.Value -AddType -Cache -Verbose:$false
            if ($PermissionAccount) {
                $UserNameDomain = $PermissionAccount.DomainName
                $UserName = $PermissionAccount.Name
                $SidType = $PermissionAccount.Type
                $ObjectClass = $PermissionAccount.ObjectClass
            } else {
                $ConvertFromSID = ConvertFrom-SID -SID $GPOPermission.Trustee.Sid.Value
                $UserNameDomain = ''
                $Username = $ConvertFromSID.Name
                $SidType = $ConvertFromSID.Type
                if ($SidType -eq 'Unknown') {
                    $ObjectClass = 'unknown'
                } else {
                    $ObjectClass = 'foreignSecurityPrincipal'
                }
            }
            $ReturnObject = [ordered] @{
                DisplayName                = $GPO.DisplayName #      : ALL | Enable RDP
                GUID                       = $GPO.ID
                DomainName                 = $GPO.DomainName  #      : ad.evotec.xyz
                Enabled                    = $GPO.GpoStatus
                Description                = $GPO.Description
                CreationDate               = $GPO.CreationTime
                ModificationTime           = $GPO.ModificationTime
                PermissionType             = if ($GPOPermission.Denied -eq $true) { 'Deny' } else { 'Allow' }
                Permission                 = $GPOPermission.Permission  # : GpoEditDeleteModifySecurity
                Inherited                  = $GPOPermission.Inherited   # : False
                PrincipalNetBiosName       = $UserMerge
                PrincipalDistinguishedName = $GPOPermission.Trustee.DSPath  #: CN = Domain Admins, CN = Users, DC = ad, DC = evotec, DC = xyz
                PrincipalDomainName        = $UserNameDomain  #: EVOTEC
                PrincipalName              = $UserName    #: Domain Admins
                PrincipalSid               = $GPOPermission.Trustee.Sid.Value     #: S - 1 - 5 - 21 - 853615985 - 2870445339 - 3163598659 - 512
                PrincipalSidType           = $SidType #$GPOPermission.Trustee.SidType #: Group
                PrincipalObjectClass       = $ObjectClass
            }


            if ($IncludeGPOObject) {
                $ReturnObject['GPOObject'] = $GPO
                $ReturnObject['GPOSecurity'] = $SecurityRights
                $ReturnObject['GPOSecurityPermissionItem'] = $GPOPermission
            }
            [PSCustomObject] $ReturnObject
        }
        if ($IncludeOwner) {
            if ($GPO.Owner) {
                # I don't trust the returned data, some stuff like 'alias' shows up for groups. To unify it with everything else... using my own function
                $OwnerAccount = Get-WinADObject -Identity $GPO.Owner -AddType -Cache -Verbose:$false
                if ($OwnerAccount) {
                    $UserNameDomain = $OwnerAccount.DomainName
                    $UserName = $OwnerAccount.Name
                    $SidType = $OwnerAccount.Type
                    $OwnerObjectClass = $OwnerAccount.ObjectClass
                    $SID = $OwnerAccount.ObjectSID
                } else {
                    $ConvertFromSID = ConvertFrom-SID -SID $GPO.Owner
                    $UserNameDomain = ''
                    $Username = $ConvertFromSID.Name
                    $SidType = $ConvertFromSID.Type
                    if ($SidType -eq 'Unknown') {
                        $OwnerObjectClass = 'unknown'
                    } else {
                        $OwnerObjectClass = 'foreignSecurityPrincipal'
                    }
                    $SID = $ConvertFromSID.SID
                }
            } else {
                $UserName = ''
                $UserNameDomain = ''
                $SID = ''
                $SIDType = 'Unknown'
                $DistinguishedName = ''
                $OwnerObjectClass = 'unknown'
            }
            # We have to process it for owners after querying user because $Owners are not as established as standard permissions so we don't know a lot

            if ($Type -contains 'Administrative' -and $Type -notcontains 'All') {
                if ($SID) {
                    $IsAdministrative = $ADAdministrativeGroups['BySID'][$SID]
                    if (-not $IsAdministrative) {
                        return
                    }
                } else {
                    # if there is no SID, it's not administrative
                    return
                }
            }
            if ($Type -contains 'NotWellKnownAdministrative' -and $Type -notcontains 'All') {
                # We check for SYSTEM account
                # Maybe we should make it a function and provide more
                if ($SID -eq 'S-1-5-18') {
                    return
                }
            }
            if ($Type -contains 'WellKnownAdministrative' -and $Type -notcontains 'All') {
                # We check for SYSTEM account
                # Maybe we should make it a function and provide more
                if ($SID -ne 'S-1-5-18') {
                    return
                }
            }
            if ($Type -contains 'Unknown' -and $Type -notcontains 'All') {
                # May need updates if there's more types
                if ($SidType -ne 'Unknown') {
                    return
                }
            }
            if ($Type -contains 'AuthenticatedUsers' -and $Type -notcontains 'All') {
                if ($SID -ne 'S-1-5-11') {
                    return
                }
            }
            if ($Type -contains 'DomainComputers' -and $Type -notcontains 'All') {
                $DomainComputersSID = -join ($ExtendedForestInformation['DomainsExtended'][$GPO.DomainName].DomainSID, '-515')
                if ($SID -ne $DomainComputersSID) {
                    return
                }
            }

            if ($Principal) {
                if ($PrincipalType -eq 'Sid') {
                    if ($Principal -notcontains $SID) {
                        return
                    }
                } elseif ($PrincipalType -eq 'DistinguishedName') {
                    if ($Principal -notcontains $DistinguishedName) {
                        return
                    }
                } elseif ($PrincipalType -eq 'Name') {
                    if ($Principal -notcontains $UserName) {
                        return
                    }
                } elseif ($PrincipalType -eq 'NetbiosName') {
                    if ($Principal -notcontains $GPO.Owner) {
                        return
                    }
                }
            }
            if ($ExcludePrincipal) {
                if ($ExcludePrincipalType -eq 'Sid') {
                    if ($ExcludePrincipal -contains $SID) {
                        return
                    }
                } elseif ($ExcludePrincipalType -eq 'DistinguishedName') {
                    if ($ExcludePrincipal -contains $DistinguishedName) {
                        return
                    }
                } elseif ($ExcludePrincipalType -eq 'Name') {
                    if ($ExcludePrincipal -contains $UserName) {
                        return
                    }
                } elseif ($ExcludePrincipalType -eq 'NetbiosName') {
                    if ($ExcludePrincipal -contains $GPO.Owner) {
                        return
                    }
                }
            }

            $ReturnObject = [ordered] @{
                DisplayName                = $GPO.DisplayName #      : ALL | Enable RDP
                GUID                       = $GPO.Id
                DomainName                 = $GPO.DomainName  #      : ad.evotec.xyz
                Enabled                    = $GPO.GpoStatus
                Description                = $GPO.Description
                CreationDate               = $GPO.CreationTime
                ModificationTime           = $GPO.ModificationTime
                PermissionType             = 'Allow'
                Permission                 = 'GpoOwner'  # : GpoEditDeleteModifySecurity
                Inherited                  = $false  # : False
                PrincipalNetBiosName       = $GPO.Owner
                PrincipalDistinguishedName = $DistinguishedName  #: CN = Domain Admins, CN = Users, DC = ad, DC = evotec, DC = xyz
                PrincipalDomainName        = $UserNameDomain
                PrincipalName              = $UserName
                PrincipalSid               = $SID     #: S - 1 - 5 - 21 - 853615985 - 2870445339 - 3163598659 - 512
                PrincipalSidType           = $SIDType #  #: Group
                PrincipalObjectClass       = $OwnerObjectClass
            }
            if ($IncludeGPOObject) {
                $ReturnObject['GPOObject'] = $GPO
                $ReturnObject['GPOSecurity'] = $SecurityRights
                $ReturnObject['GPOSecurityPermissionItem'] = $null
            }
            [PSCustomObject] $ReturnObject
        }
    }
    End {

    }
}