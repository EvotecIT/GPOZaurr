function Get-XMLNestedRegistry {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [System.Xml.XmlElement[]] $DataSet,
        [string] $Collection,
        [switch] $Limited
    )
    if ($DataSet.Properties) {
        $Registry = $DataSet
        foreach ($Registry in $DataSet) {
            if ($Limited) {
                [PSCustomObject] @{
                    Collection      = $Collection
                    Description     = $Registry.descr
                    Changed         = try { [DateTime] $Registry.changed } catch { $Registry.changed };
                    GPOSettingOrder = $Registry.GPOSettingOrder
                    Hive            = $Registry.Properties.hive #: HKEY_LOCAL_MACHINE
                    Key             = $Registry.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                    Name            = $Registry.Properties.name #: AutoAdminLogon
                    Type            = $Registry.Properties.type #: REG_SZ
                    Value           = $Registry.Properties.value #
                    Filters         = $Registry.Filters
                }
            } else {
                $CreateGPO = [ordered]@{
                    DisplayName     = $GPO.DisplayName
                    DomainName      = $GPO.DomainName
                    GUID            = $GPO.GUID
                    GpoType         = $GPO.GpoType
                    #GpoCategory = $GPOEntry.GpoCategory
                    #GpoSettings = $GPOEntry.GpoSettings
                    Collection      = $Collection
                    Description     = $Registry.descr
                    Changed         = try { [DateTime] $Registry.changed } catch { $Registry.changed };
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
        }
    }
    foreach ($Name in @('Registry', 'Collection')) {
        foreach ($Registry in $DataSet.$Name) {
            if ($Registry.Properties) {
                if ($Limited) {
                    [PSCustomObject] @{
                        Collection      = $Collection
                        Description     = $Registry.descr
                        Changed         = try { [DateTime] $Registry.changed } catch { $Registry.changed };
                        GPOSettingOrder = $Registry.GPOSettingOrder
                        Hive            = $Registry.Properties.hive #: HKEY_LOCAL_MACHINE
                        Key             = $Registry.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                        Name            = $Registry.Properties.name #: AutoAdminLogon
                        Type            = $Registry.Properties.type #: REG_SZ
                        Value           = $Registry.Properties.value #
                        Filters         = $Registry.Filters
                    }
                } else {
                    $CreateGPO = [ordered]@{
                        DisplayName     = $GPO.DisplayName
                        DomainName      = $GPO.DomainName
                        GUID            = $GPO.GUID
                        GpoType         = $GPO.GpoType
                        #GpoCategory = $GPOEntry.GpoCategory
                        #GpoSettings = $GPOEntry.GpoSettings
                        Collection      = $Collection
                        Description     = $Registry.descr
                        Changed         = try { [DateTime] $Registry.changed } catch { $Registry.changed };
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
            } else {
                if ($Registry.Registry) {
                    #$Collection = $Registry.name
                    $TempCollection = $Collection
                    if ($Collection) {
                        $Collection = "$Collection\$($Registry.name)"
                    } else {
                        $Collection = $Registry.name
                    }
                    Get-XMLNestedRegistry -GPO $GPO -DataSet $Registry.Registry -Collection $Collection
                    $Collection = $TempCollection
                }
                if ($Registry.Collection) {
                    if ($Collection) {
                        $Collection = "$Collection\$($Registry.Collection.name)"
                    } else {
                        $Collection = "$($Registry.name)\$($Registry.Collection.name)"
                    }
                    Get-XMLNestedRegistry -GPO $GPO -DataSet $Registry.Collection -Collection $Collection
                }
            }
        }

    }
}