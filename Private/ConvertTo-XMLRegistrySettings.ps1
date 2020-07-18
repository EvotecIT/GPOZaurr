function ConvertTo-XMLRegistrySettings {
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

        [Array] $CreateGPO['Settings'] = Get-XMLNestedRegistry -GPO $GPO -DataSet $GPO.DataSet
        <#
        [Array] $CreateGPO['Settings'] = foreach ($Registry in $GPO.DataSet.Registry) {
            [PSCustomObject] @{
                Changed         = [DateTime] $Registry.changed
                GPOSettingOrder = $Registry.GPOSettingOrder
                Hive            = $Registry.Properties.hive #: HKEY_LOCAL_MACHINE
                Key             = $Registry.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                Name            = $Registry.Properties.name #: AutoAdminLogon
                Type            = $Registry.Properties.type #: REG_SZ
                Value           = $Registry.Properties.value #
                Filters         = $Registry.Filters
            }
        }
        #>
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        <#
        if ($GPO.DataSet.Registry) {
            Get-XMLNestedRegistry -GPO $GPO -RegistryCollection $GPO.DataSet.Registry
        }
        if ($GPO.DataSet.Collection) {
            Get-XMLNestedRegistry -GPO $GPO -RegistryCollection $GPO.DataSet.Collection
        }
        #>
        Get-XMLNestedRegistry -GPO $GPO -DataSet $GPO.DataSet

        <#
        foreach ($Registry in $GPO.DataSet.Registry) {
            $CreateGPO = [ordered]@{
                DisplayName     = $GPO.DisplayName
                DomainName      = $GPO.DomainName
                GUID            = $GPO.GUID
                GpoType         = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
                Changed         = [DateTime] $Registry.changed
                GPOSettingOrder = $Registry.GPOSettingOrder
                Hive            = $Registry.Properties.hive #: HKEY_LOCAL_MACHINE
                Key             = $Registry.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                Name            = $Registry.Properties.name #: AutoAdminLogon
                Type            = $Registry.Properties.type #: REG_SZ
                Value           = $Registry.Properties.value #
                Filters         = $Registry.Filters
            }
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
        #>
    }
}