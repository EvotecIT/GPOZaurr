function Get-XMLSoftwareInstallation {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [System.Xml.XmlElement[]] $GPOOutput,
        [string] $Splitter = [System.Environment]::NewLine,
        [switch] $FullObjects
    )
    $LinksInformation = Get-LinksFromXML -GPOOutput $GPOOutput -Splitter $Splitter -FullObjects:$FullObjects
    foreach ($Type in @('User', 'Computer')) {
        if ($GPOOutput.$Type.ExtensionData.Extension) {
            foreach ($ExtensionType in $GPOOutput.$Type.ExtensionData.Extension) {
                foreach ($Key in $ExtensionType.MsiApplication) {
                    if ($FullObjects) {
                        [PSCustomObject] @{
                            DisplayName         = $GPO.DisplayName
                            DomainName          = $GPO.DomainName
                            GUID                = $GPO.Guid
                            Linked              = $LinksInformation.Linked
                            LinksCount          = $LinksInformation.LinksCount
                            Links               = $LinksInformation.Links
                            GpoType             = $Type
                            Identifier          = $Key.Identifier          #: { 10495e9e-79c1-4a32-b278-a24cd495437f }
                            Name                = $Key.Name                #: Local Administrator Password Solution (2)
                            Path                = $Key.Path                #: \\area1.local\SYSVOL\area1.local\Policies\ { 5F5042A0-008F-45E3-8657-79C87BD002E3 }\LAPS.x64.msi
                            MajorVersion        = $Key.MajorVersion        #: 6
                            MinorVersion        = $Key.MinorVersion        #: 2
                            LanguageId          = $Key.LanguageId          #: 1033
                            Architecture        = $Key.Architecture        #: 9
                            IgnoreLanguage      = if ($Key.IgnoreLanguage -eq 'true') { $true } else { $false }      #: false
                            Allowx86Onia64      = if ($Key.Allowx86Onia64 -eq 'true') { $true } else { $false }       #: true
                            SupportURL          = $Key.SupportURL          #:
                            AutoInstall         = if ($Key.AutoInstall -eq 'true') { $true } else { $false }          #: true
                            DisplayInARP        = if ($Key.DisplayInARP -eq 'true') { $true } else { $false }        #: true
                            IncludeCOM          = if ($Key.IncludeCOM -eq 'true') { $true } else { $false }          #: true
                            SecurityDescriptor  = $Key.SecurityDescriptor  #: SecurityDescriptor
                            DeploymentType      = $Key.DeploymentType      #: Assign
                            ProductId           = $Key.ProductId           #: { ea8cb806-c109 - 4700 - 96b4-f1f268e5036c }
                            ScriptPath          = $Key.ScriptPath          #: \\area1.local\SysVol\area1.local\Policies\ { 5F5042A0-008F-45E3-8657-79C87BD002E3 }\Machine\Applications\ { EAC9B821-FB4D - 457A-806F-E5B528D1E41A }.aas
                            DeploymentCount     = $Key.DeploymentCount     #: 0
                            InstallationUILevel = $Key.InstallationUILevel #: Maximum
                            Upgrades            = if ($Key.Upgrades.Mandatory -eq 'true') { $true } else { $false }            #: Upgrades
                            UninstallUnmanaged  = if ($Key.UninstallUnmanaged -eq 'true') { $true } else { $false }   #: false
                            LossOfScopeAction   = $Key.LossOfScopeAction   #: Unmanage
                        }
                    } else {
                        [PSCustomObject] @{
                            DisplayName         = $GPO.DisplayName
                            DomainName          = $GPO.DomainName
                            GUID                = $GPO.Guid
                            Linked              = $LinksInformation.Linked
                            LinksCount          = $LinksInformation.LinksCount
                            Links               = $LinksInformation.Links
                            GpoType             = $Type
                            Identifier          = $Key.Identifier          #: { 10495e9e-79c1-4a32-b278-a24cd495437f }
                            Name                = $Key.Name                #: Local Administrator Password Solution (2)
                            Path                = $Key.Path                #: \\area1.local\SYSVOL\area1.local\Policies\ { 5F5042A0-008F-45E3-8657-79C87BD002E3 }\LAPS.x64.msi
                            MajorVersion        = $Key.MajorVersion        #: 6
                            MinorVersion        = $Key.MinorVersion        #: 2
                            LanguageId          = $Key.LanguageId          #: 1033
                            Architecture        = $Key.Architecture        #: 9
                            IgnoreLanguage      = if ($Key.IgnoreLanguage -eq 'true') { $true } else { $false }      #: false
                            Allowx86Onia64      = if ($Key.Allowx86Onia64 -eq 'true') { $true } else { $false }       #: true
                            SupportURL          = $Key.SupportURL          #:
                            AutoInstall         = if ($Key.AutoInstall -eq 'true') { $true } else { $false }          #: true
                            DisplayInARP        = if ($Key.DisplayInARP -eq 'true') { $true } else { $false }        #: true
                            IncludeCOM          = if ($Key.IncludeCOM -eq 'true') { $true } else { $false }          #: true
                            SecurityDescriptor  = $Key.SecurityDescriptor  #: SecurityDescriptor
                            DeploymentType      = $Key.DeploymentType      #: Assign
                            ProductId           = $Key.ProductId           #: { ea8cb806-c109 - 4700 - 96b4-f1f268e5036c }
                            ScriptPath          = $Key.ScriptPath          #: \\area1.local\SysVol\area1.local\Policies\ { 5F5042A0-008F-45E3-8657-79C87BD002E3 }\Machine\Applications\ { EAC9B821-FB4D - 457A-806F-E5B528D1E41A }.aas
                            DeploymentCount     = $Key.DeploymentCount     #: 0
                            InstallationUILevel = $Key.InstallationUILevel #: Maximum
                            Upgrades            = if ($Key.Upgrades.Mandatory -eq 'true') { $true } else { $false }            #: Upgrades
                            UninstallUnmanaged  = if ($Key.UninstallUnmanaged -eq 'true') { $true } else { $false }   #: false
                            LossOfScopeAction   = $Key.LossOfScopeAction   #: Unmanage
                        }
                    }
                }
            }
        }
    }
}