function Get-GPOZaurrPermission {
    [cmdletBinding()]
    param(
        [switch] $SkipWellKnownGroup,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Begin {
        if ($Type -contains 'NonAdministrative') {
            $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        }
        #$Count = 0
    }
    Process {
        $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        foreach ($Domain in $ForestInformation.Domains) {
            $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
            Get-GPO -All -Domain $Domain -Server $QueryServer | ForEach-Object -Process {
                $GPO = $_
                Write-Verbose "Get-GPOZaurrPermission - Processing $($GPO.DisplayName) from $($GPO.DomainName)"
                Get-GPPermissions -Guid $GPO.ID -DomainName $GPO.DomainName -All -Server $QueryServer | ForEach-Object -Process {
                    $GPOPermission = $_
                    [PSCustomObject] @{
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
                        Sid               = $GPOPermission.Trustee.Sid     #: S - 1 - 5 - 21 - 853615985 - 2870445339 - 3163598659 - 512
                        SidType           = $GPOPermission.Trustee.SidType #: Group
                    }
                }
                if ($GPO.Owner) {
                    $SplittedOwner = $GPO.Owner.Split('\')
                    $DomainOwner = $SplittedOwner[0]  #: EVOTEC
                    $DomainUserName = $SplittedOwner[1]   #: Domain Admins
                    $SID = $ADAdministrativeGroups['ByNetBIOS']["$($GPO.Owner)"].Sid
                    if ($SID) {
                        $SIDType = 'Group'
                    } else {
                        $SIDType = ''
                    }
                } else {
                    $DomainOwner = $GPO.Owner
                    $DomainUserName = ''
                    $SID = ''
                    $SIDType = ''
                }
                [PSCustomObject] @{
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
                    DistinguishedName = ''  #: CN = Domain Admins, CN = Users, DC = ad, DC = evotec, DC = xyz
                    Name              = $DomainUserName
                    Sid               = $SID     #: S - 1 - 5 - 21 - 853615985 - 2870445339 - 3163598659 - 512
                    SidType           = $SIDType #  #: Group
                }
            }
        }
    }
    End {

    }
}