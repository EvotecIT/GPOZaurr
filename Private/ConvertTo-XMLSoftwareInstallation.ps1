function ConvertTo-XMLSoftwareInstallation {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [switch] $SingleObject
    )
    if ($SingleObject) {
        $CreateGPO = [ordered]@{
            DisplayName = $GPO.DisplayName
            DomainName  = $GPO.DomainName
            GUID        = $GPO.GUID
            GpoType     = $GPO.GpoType
            #GpoCategory = $GPOEntry.GpoCategory
            #GpoSettings = $GPOEntry.GpoSettings
            Count       = 0
            Settings    = $null
        }
        [Array] $CreateGPO['Settings'] = foreach ($MsiInstallerr in $GPO.DataSet) {
            [PSCustomObject] @{
                Identifier          = $MsiInstallerr.Identifier          #: { 10495e9e-79c1-4a32-b278-a24cd495437f }
                Name                = $MsiInstallerr.Name                #: Local Administrator Password Solution (2)
                Path                = $MsiInstallerr.Path                #: \\area1.local\SYSVOL\area1.local\Policies\ { 5F5042A0-008F-45E3-8657-79C87BD002E3 }\LAPS.x64.msi
                MajorVersion        = $MsiInstallerr.MajorVersion        #: 6
                MinorVersion        = $MsiInstallerr.MinorVersion        #: 2
                LanguageId          = $MsiInstallerr.LanguageId          #: 1033
                Architecture        = $MsiInstallerr.Architecture        #: 9
                IgnoreLanguage      = if ($MsiInstallerr.IgnoreLanguage -eq 'true') { $true } else { $false }      #: false
                Allowx86Onia64      = if ($MsiInstallerr.Allowx86Onia64 -eq 'true') { $true } else { $false }       #: true
                SupportURL          = $MsiInstallerr.SupportURL          #:
                AutoInstall         = if ($MsiInstallerr.AutoInstall -eq 'true') { $true } else { $false }          #: true
                DisplayInARP        = if ($MsiInstallerr.DisplayInARP -eq 'true') { $true } else { $false }        #: true
                IncludeCOM          = if ($MsiInstallerr.IncludeCOM -eq 'true') { $true } else { $false }          #: true
                SecurityDescriptor  = $MsiInstallerr.SecurityDescriptor  #: SecurityDescriptor
                DeploymentType      = $MsiInstallerr.DeploymentType      #: Assign
                ProductId           = $MsiInstallerr.ProductId           #: { ea8cb806-c109 - 4700 - 96b4-f1f268e5036c }
                ScriptPath          = $MsiInstallerr.ScriptPath          #: \\area1.local\SysVol\area1.local\Policies\ { 5F5042A0-008F-45E3-8657-79C87BD002E3 }\Machine\Applications\ { EAC9B821-FB4D - 457A-806F-E5B528D1E41A }.aas
                DeploymentCount     = $MsiInstallerr.DeploymentCount     #: 0
                InstallationUILevel = $MsiInstallerr.InstallationUILevel #: Maximum
                Upgrades            = if ($MsiInstallerr.Upgrades.Mandatory -eq 'true') { $true } else { $false }            #: Upgrades
                UninstallUnmanaged  = if ($MsiInstallerr.UninstallUnmanaged -eq 'true') { $true } else { $false }   #: false
                LossOfScopeAction   = $MsiInstallerr.LossOfScopeAction   #: Unmanage
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($MsiInstallerr in $GPO.DataSet) {
            $CreateGPO = [ordered]@{
                DisplayName         = $GPO.DisplayName
                DomainName          = $GPO.DomainName
                GUID                = $GPO.GUID
                GpoType             = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
                Identifier          = $MsiInstallerr.Identifier          #: { 10495e9e-79c1-4a32-b278-a24cd495437f }
                Name                = $MsiInstallerr.Name                #: Local Administrator Password Solution (2)
                Path                = $MsiInstallerr.Path                #: \\area1.local\SYSVOL\area1.local\Policies\ { 5F5042A0-008F-45E3-8657-79C87BD002E3 }\LAPS.x64.msi
                MajorVersion        = $MsiInstallerr.MajorVersion        #: 6
                MinorVersion        = $MsiInstallerr.MinorVersion        #: 2
                LanguageId          = $MsiInstallerr.LanguageId          #: 1033
                Architecture        = $MsiInstallerr.Architecture        #: 9
                IgnoreLanguage      = if ($MsiInstallerr.IgnoreLanguage -eq 'true') { $true } else { $false }      #: false
                Allowx86Onia64      = if ($MsiInstallerr.Allowx86Onia64 -eq 'true') { $true } else { $false }       #: true
                SupportURL          = $MsiInstallerr.SupportURL          #:
                AutoInstall         = if ($MsiInstallerr.AutoInstall -eq 'true') { $true } else { $false }          #: true
                DisplayInARP        = if ($MsiInstallerr.DisplayInARP -eq 'true') { $true } else { $false }        #: true
                IncludeCOM          = if ($MsiInstallerr.IncludeCOM -eq 'true') { $true } else { $false }          #: true
                SecurityDescriptor  = $MsiInstallerr.SecurityDescriptor  #: SecurityDescriptor
                DeploymentType      = $MsiInstallerr.DeploymentType      #: Assign
                ProductId           = $MsiInstallerr.ProductId           #: { ea8cb806-c109 - 4700 - 96b4-f1f268e5036c }
                ScriptPath          = $MsiInstallerr.ScriptPath          #: \\area1.local\SysVol\area1.local\Policies\ { 5F5042A0-008F-45E3-8657-79C87BD002E3 }\Machine\Applications\ { EAC9B821-FB4D - 457A-806F-E5B528D1E41A }.aas
                DeploymentCount     = $MsiInstallerr.DeploymentCount     #: 0
                InstallationUILevel = $MsiInstallerr.InstallationUILevel #: Maximum
                Upgrades            = if ($MsiInstallerr.Upgrades.Mandatory -eq 'true') { $true } else { $false }            #: Upgrades
                UninstallUnmanaged  = if ($MsiInstallerr.UninstallUnmanaged -eq 'true') { $true } else { $false }   #: false
                LossOfScopeAction   = $MsiInstallerr.LossOfScopeAction   #: Unmanage
            }
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
    }
}