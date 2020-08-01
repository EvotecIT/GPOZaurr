function Get-XMLAutologon {
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
                if ($ExtensionType.RegistrySettings.Registry.Properties.Key -ne 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon') {
                    continue
                }
                $Autologon = [ordered] @{
                    DisplayName       = $GPO.DisplayName
                    DomainName        = $GPO.DomainName
                    GUID              = $GPO.Guid
                    Linked            = $LinksInformation.Linked
                    LinksCount        = $LinksInformation.LinksCount
                    Links             = $LinksInformation.Links
                    AutoAdminLogon    = $null
                    DefaultDomainName = $null
                    DefaultUserName   = $null
                    DefaultPassword   = $null
                }
                foreach ($Key in $ExtensionType.RegistrySettings.Registry) {
                    if ($Key.Properties.key -eq 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon') {
                        <#
                        [PSCustomObject] @{
                            DisplayName     = $GPO.DisplayName
                            DomainName      = $GPO.DomainName
                            GUID            = $GPO.Guid
                            Linked          = $Linked
                            LinksCount      = $LinksCount
                            GpoType         = $Type
                            Changed         = [DateTime] $Key.changed
                            GPOSettingOrder = $Key.GPOSettingOrder
                            hive            = $Key.Properties.hive #: HKEY_LOCAL_MACHINE
                            key             = $Key.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                            name            = $Key.Properties.name #: AutoAdminLogon
                            type            = $Key.Properties.type #: REG_SZ
                            value           = $Key.Properties.value #
                            Filters         = $Key.Filters
                        }
                        #>
                        if ($Key.Properties.Name -eq 'AutoAdminLogon') {
                            $Autologon['AutoAdminLogon'] = [bool] $Key.Properties.value
                        } elseif ($Key.Properties.Name -eq 'DefaultDomainName') {
                            $Autologon['DefaultDomainName'] = $Key.Properties.value
                        } elseif ($Key.Properties.Name -eq 'DefaultUserName') {
                            $Autologon['DefaultUserName'] = $Key.Properties.value
                        } elseif ($Key.Properties.Name -eq 'DefaultPassword') {
                            $Autologon['DefaultPassword'] = $Key.Properties.value
                        }
                    }
                }
                [PSCustomObject] $Autologon
            }
        }
    }
}