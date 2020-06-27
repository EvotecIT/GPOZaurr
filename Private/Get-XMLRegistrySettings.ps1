function Get-XMLRegistrySettings {
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
                foreach ($Key in $ExtensionType.RegistrySettings.Registry) {
                    [PSCustomObject] @{
                        DisplayName     = $GPO.DisplayName
                        DomainName      = $GPO.DomainName
                        GUID            = $GPO.Guid
                        Linked          = $LinksInformation.Linked
                        LinksCount      = $LinksInformation.LinksCount
                        Links           = $LinksInformation.Links
                        GpoType         = $Type
                        Changed         = [DateTime] $Key.changed
                        GPOSettingOrder = $Key.GPOSettingOrder
                        Hive            = $Key.Properties.hive #: HKEY_LOCAL_MACHINE
                        Key             = $Key.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                        Name            = $Key.Properties.name #: AutoAdminLogon
                        Type            = $Key.Properties.type #: REG_SZ
                        Value           = $Key.Properties.value #
                        Filters         = $Key.Filters
                    }
                }
            }
        }
    }
}