function Get-XMLAutologon {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [System.Xml.XmlElement[]] $GPOOutput
    )
    if ($GPOOutput.LinksTo) {
        $Linked = $true
        $LinksCount = ([Array] $GPOOutput.LinksTo).Count
    } else {
        $Linked = $false
        $LinksCount = 0
    }
    foreach ($Type in @('User', 'Computer')) {
        if ($GPOOutput.$Type.ExtensionData.Extension.RegistrySettings) {
            foreach ($Key in $GPOOutput.$Type.ExtensionData.Extension.RegistrySettings.Registry) {
                #$Key
                <#
                clsid           : {9CD4B2F4-923D-47f5-A062-E897DD1DAD50}
                name            : AutoAdminLogon
                status          : AutoAdminLogon
                image           : 7
                changed         : 2013-02-06 09:57:45
                uid             : {23AD1B6F-0D90-49B5-926D-AAA6E1E2F4B3}
                GPOSettingOrder : 1
                Properties      : Properties
                Filters         :
                #>

                <# $Key.properties
                action         : U
                displayDecimal : 0
                default        : 0
                hive           : HKEY_LOCAL_MACHINE
                key            : SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                name           : AutoAdminLogon
                type           : REG_SZ
                value          : 1
                Values         :
                #>
                [PSCustomObject] @{
                    DisplayName     = $GPO.DisplayName
                    DomainName      = $GPO.DomainName
                    GUID            = $GPO.Guid
                    Linked          = $Linked
                    LinksCount      = $LinksCount
                    Changed         = [DateTime] $Key.changed
                    GPOSettingOrder = $Key.GPOSettingOrder
                    hive            = $Key.Properties.hive #: HKEY_LOCAL_MACHINE
                    key             = $Key.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                    name            = $Key.Properties.name #: AutoAdminLogon
                    type            = $Key.Properties.type #: REG_SZ
                    value           = $Key.Properties.value #
                    Filters         = $Key.Filters
                }
            }
        }
    }
}