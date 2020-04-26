function Get-PrivPermission {
    [cmdletBinding()]
    param(
        [Microsoft.GroupPolicy.Gpo] $GPO,
        [switch] $SkipWellKnown,
        [switch] $SkipAdministrative,
        [switch] $IncludeOwner,
        [Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType,
        [Microsoft.GroupPolicy.GPPermissionType[]] $ExcludePermissionType,
        [switch] $IncludeGPOObject,
        [System.Collections.IDictionary] $ADAdministrativeGroups,
        [validateSet('Unknown', 'NotWellKnown', 'NotWellKnownAdministrative', 'NotAdministrative','Administrative', 'All')][string[]] $Type,
        [System.Collections.IDictionary] $Accounts
    )
    Write-Verbose "Get-GPOZaurrPermission - Processing $($GPO.DisplayName) from $($GPO.DomainName)"
    $SecurityRights = $GPO.GetSecurityInfo()
    $SecurityRights | ForEach-Object -Process {
        #Get-GPPermissions -Guid $GPO.ID -DomainName $GPO.DomainName -All -Server $QueryServer | ForEach-Object -Process {
        $GPOPermission = $_
        if ($ExcludePermissionType -contains $GPOPermission.Permission) {
            return
        }
        if ($IncludePermissionType) {
            if ($IncludePermissionType -notcontains $GPOPermission.Permission) {
                return
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
        if ($Type -contains 'Unknown' -and $Type -notcontains 'All') {
            # May need updates if there's more types
            if ($GPOPermission.Trustee.SidType -ne 'Unknown') {
                return
            }
        }
        $ReturnObject = [ordered] @{
            DisplayName       = $GPO.DisplayName #      : ALL | Enable RDP
            GUID              = $GPO.ID
            DomainName        = $GPO.DomainName  #      : ad.evotec.xyz
            Enabled           = $GPO.GpoStatus
            Description       = $GPO.Description
            CreationDate      = $GPO.CreationTime
            ModificationTime  = $GPO.ModificationTime
            Permission        = $GPOPermission.Permission  # : GpoEditDeleteModifySecurity
            Inherited         = $GPOPermission.Inherited   # : False
            Domain            = $GPOPermission.Trustee.Domain  #: EVOTEC
            DistinguishedName = $GPOPermission.Trustee.DSPath  #: CN = Domain Admins, CN = Users, DC = ad, DC = evotec, DC = xyz
            Name              = $GPOPermission.Trustee.Name    #: Domain Admins
            Sid               = $GPOPermission.Trustee.Sid.Value     #: S - 1 - 5 - 21 - 853615985 - 2870445339 - 3163598659 - 512
            SidType           = $GPOPermission.Trustee.SidType #: Group
        }
        if ($Accounts) {
            $A = -join ($GPOPermission.Trustee.Domain, '\', $GPOPermission.Trustee.Name)
            if ($A -and $Accounts[$A]) {
                $ReturnObject['UserPrincipalName'] = $Accounts[$A].UserPrincipalName
                $ReturnObject['AccountEnabled'] = $Accounts[$A].Enabled
                $ReturnObject['DistinguishedName'] = $Accounts[$A].DistinguishedName
                $ReturnObject['PasswordLastSet'] = if ($Accounts[$A].PasswordLastSet) { $Accounts[$A].PasswordLastSet } else { '' }
                $ReturnObject['LastLogonDate'] = if ($Accounts[$A].LastLogonDate ) { $Accounts[$A].LastLogonDate } else { '' }
                if (-not $ReturnObject['Sid']) {
                    $ReturnObject['Sid'] = $Accounts[$A].Sid.Value
                }
                if ($Accounts[$A].ObjectClass -eq 'group') {
                    $ReturnObject['SidType'] = 'Group'
                } elseif ($Accounts[$A].ObjectClass -eq 'user') {
                    $ReturnObject['SidType'] = 'User'
                } elseif ($Accounts[$A].ObjectClass -eq 'computer') {
                    $ReturnObject['SidType'] = 'Computer'
                } else {
                    $ReturnObject['SidType'] = 'EmptyOrUnknown'
                }
            } else {
                $ReturnObject['UserPrincipalName'] = ''
                $ReturnObject['AccountEnabled'] = ''
                $ReturnObject['PasswordLastSet'] = ''
                $ReturnObject['LastLogonDate'] = ''
            }
        }
        if ($IncludeGPOObject) {
            $ReturnObject['GPOObject'] = $GPO
            $ReturnObject['GPOSecurity'] = $SecurityRights
            $ReturnObject['GPOSecurityPermissionIndex'] = $GPOPermission
        }
        [PSCustomObject] $ReturnObject
    }
    if ($IncludeOwner.IsPresent) {
        if ($GPO.Owner) {
            $SplittedOwner = $GPO.Owner.Split('\')
            $DomainOwner = $SplittedOwner[0]  #: EVOTEC
            $DomainUserName = $SplittedOwner[1]   #: Domain Admins
            $SID = $ADAdministrativeGroups['ByNetBIOS']["$($GPO.Owner)"].Sid.Value
            if ($SID) {
                $SIDType = 'Group'
                $DistinguishedName = $ADAdministrativeGroups['ByNetBIOS']["$($GPO.Owner)"].DistinguishedName
            } else {
                $SIDType = ''
                $DistinguishedName = ''
            }
        } else {
            $DomainOwner = $GPO.Owner
            $DomainUserName = ''
            $SID = ''
            $SIDType = 'EmptyOrUnknown'
            $DistinguishedName = ''
        }
        $ReturnObject = [ordered] @{
            DisplayName       = $GPO.DisplayName #      : ALL | Enable RDP
            GUID              = $GPO.Id
            DomainName        = $GPO.DomainName  #      : ad.evotec.xyz
            Enabled           = $GPO.GpoStatus
            Description       = $GPO.Description
            CreationDate      = $GPO.CreationTime
            ModificationTime  = $GPO.ModificationTime
            Permission        = 'GpoOwner'  # : GpoEditDeleteModifySecurity
            Inherited         = $false  # : False
            Domain            = $DomainOwner
            DistinguishedName = $DistinguishedName  #: CN = Domain Admins, CN = Users, DC = ad, DC = evotec, DC = xyz
            Name              = $DomainUserName
            Sid               = $SID     #: S - 1 - 5 - 21 - 853615985 - 2870445339 - 3163598659 - 512
            SidType           = $SIDType #  #: Group
        }
        if ($Accounts) {
            $A = $GPO.Owner
            if ($A -and $Accounts[$A]) {
                $ReturnObject['UserPrincipalName'] = $Accounts[$A].UserPrincipalName
                $ReturnObject['AccountEnabled'] = $Accounts[$A].Enabled
                $ReturnObject['DistinguishedName'] = $Accounts[$A].DistinguishedName
                $ReturnObject['PasswordLastSet'] = if ($Accounts[$A].PasswordLastSet) { $Accounts[$A].PasswordLastSet } else { '' }
                $ReturnObject['LastLogonDate'] = if ($Accounts[$A].LastLogonDate ) { $Accounts[$A].LastLogonDate } else { '' }
                if (-not $ReturnObject['Sid']) {
                    $ReturnObject['Sid'] = $Accounts[$A].Sid.Value
                }
                if ($Accounts[$A].ObjectClass -eq 'group') {
                    $ReturnObject['SidType'] = 'Group'
                } elseif ($Accounts[$A].ObjectClass -eq 'user') {
                    $ReturnObject['SidType'] = 'User'
                } elseif ($Accounts[$A].ObjectClass -eq 'computer') {
                    $ReturnObject['SidType'] = 'Computer'
                } else {
                    $ReturnObject['SidType'] = 'EmptyOrUnknown'
                }
            } else {
                $ReturnObject['UserPrincipalName'] = ''
                $ReturnObject['AccountEnabled'] = ''
                $ReturnObject['PasswordLastSet'] = ''
                $ReturnObject['LastLogonDate'] = ''
            }
        }
        if ($IncludeGPOObject) {
            $ReturnObject['GPOObject'] = $GPO
            $ReturnObject['GPOSecurity'] = $SecurityRights
            $ReturnObject['GPOSecurityPermissionIndex'] = $null
        }
        [PSCustomObject] $ReturnObject
    }
}