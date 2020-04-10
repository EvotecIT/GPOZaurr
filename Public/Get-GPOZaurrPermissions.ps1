function Get-GPOZaurrPermissions {
    [cmdletBinding()]
    param(
        [switch] $SkipWellKnownGroup,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
        Get-GPO -All -Domain $Domain -Server $QueryServer | ForEach-Object -Process {
            $GPO = $_

            <#
            DisplayName      : ALL | Enable RDP
            DomainName       : ad.evotec.xyz
            Owner            : EVOTEC\Domain Admins
            Id               : 051bcddf-cc11-427b-bdf0-684c0a6e3ddb
            GpoStatus        : AllSettingsEnabled
            Description      :
            CreationTime     : 07.08.2018 12:47:44
            ModificationTime : 07.04.2020 22:09:24
            UserVersion      : AD Version: 1, SysVol Version: 1
            ComputerVersion  : AD Version: 1, SysVol Version: 1
            WmiFilter        :
            #>
            Get-GPPermission -Name $GPO.DisplayName -DomainName $GPO.DomainName -All -Server $QueryServer | ForEach-Object -Process {
                $GPOPermission = $_
                #$GPOPermissionFormatted = ConvertTo-TableFormat -InputObject $_
                [PSCustomObject] @{
                    DisplayName       = $GPO.DisplayName #      : ALL | Enable RDP
                    GUID              = $GPO.ID
                    DomainName        = $GPO.DomainName  #      : ad.evotec.xyz
                    Enabled           = $GPO.GpoStatus
                    Description       = $GPO.Description
                    CreationDate      = $GPO.CreationTime
                    ModificationTime  = $GPO.ModificationTime
                    #Owner             = $GPO.Owner       #      : EVOTEC\Domain Admins
                    #Trustee     = $GPOPermission.Trustee     # : Domain Admins
                    #TrusteeType       = $GPOPermissionFormatted.TrusteeType # # : Group
                    Permission        = $GPOPermission.Permission  # : GpoEditDeleteModifySecurity
                    Inherited         = $GPOPermission.Inherited   # : False
                    Domain            = $GPOPermission.Trustee.Domain  #: EVOTEC
                    DistinguishedName = $GPOPermission.Trustee.DSPath  #: CN = Domain Admins, CN = Users, DC = ad, DC = evotec, DC = xyz
                    Name              = $GPOPermission.Trustee.Name    #: Domain Admins
                    Sid               = $GPOPermission.Trustee.Sid     #: S - 1 - 5 - 21 - 853615985 - 2870445339 - 3163598659 - 512
                    SidType           = $GPOPermission.Trustee.SidType #: Group
                }
            }
            $SplittedOwner = $GPO.Owner.Split('\')
            [PSCustomObject] @{
                DisplayName       = $GPO.DisplayName #      : ALL | Enable RDP
                GUID              = $GPO.GUID
                DomainName        = $GPO.DomainName  #      : ad.evotec.xyz
                #Owner             = $GPO.Owner       #      : EVOTEC\Domain Admins
                #Trustee     = $GPOPermission.Trustee     # : Domain Admins
                #TrusteeType       = $GPOPermissionFormatted.TrusteeType # # : Group
                Enabled           = $GPO.GpoStatus
                Description       = $GPO.Description
                CreationDate      = $GPO.CreationTime
                ModificationTime  = $GPO.ModificationTime

                Permission        = 'Owner'  # : GpoEditDeleteModifySecurity
                Inherited         = $false  # : False
                Domain            = $SplittedOwner[0]  #: EVOTEC
                DistinguishedName = ''  #: CN = Domain Admins, CN = Users, DC = ad, DC = evotec, DC = xyz
                Name              = $SplittedOwner[1]   #: Domain Admins
                Sid               = ''     #: S - 1 - 5 - 21 - 853615985 - 2870445339 - 3163598659 - 512
                SidType           = '' #: Group
            }
        }
    }
}