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
        [string[]] $Type
    )

    # $GPO = $_
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
        if ($SkipWellKnown.IsPresent) {
            if ($GPOPermission.Trustee.SidType -eq 'WellKnownGroup') {
                return
            }
        }
        if ($SkipAdministrative.IsPresent) {
            $IsAdministrative = $ADAdministrativeGroups['BySID'][$GPOPermission.Trustee.Sid.Value]
            if ($IsAdministrative) {
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
        if ($IncludeGPOObject) {
            $ReturnObject.GPOObject = $GPO
            $ReturnObject.GPOSecurity = $SecurityRights
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
            $SIDType = ''
            $DistinguishedName = ''
        }
        $ReturnObject = [ordered] @{
            DisplayName       = $GPO.DisplayName #      : ALL | Enable RDP
            GUID              = $GPO.GUID
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
        if ($IncludeGPOObject) {
            $ReturnObject.GPOObject = $GPO
            $ReturnObject.GPOSecurity = $SecurityRights
        }
        [PSCustomObject] $ReturnObject
    }
}