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
            if ($Registry.Properties) {
                if ($Limited) {
                    [PSCustomObject] @{
                        Collection      = $Collection
                        Description     = $Registry.descr
                        Changed         = try { [DateTime] $Registry.changed } catch { $Registry.changed };
                        GPOSettingOrder = $Registry.GPOSettingOrder
                        Action          = $Script:Actions[$Registry.Properties.action]
                        DisplayDecimal  = $Registry.Properties.displayDecimal
                        Default         = $Registry.Properties.default
                        Hive            = $Registry.Properties.hive #: HKEY_LOCAL_MACHINE
                        Key             = $Registry.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                        Name            = $Registry.Properties.name #: AutoAdminLogon
                        Type            = $Registry.Properties.type #: REG_SZ
                        Value           = $Registry.Properties.value #
                        Filters         = $Registry.Filters
                        BypassErrors    = $Registry.bypassErrors
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
                        Action          = $Script:Actions[$Registry.Properties.action]
                        DisplayDecimal  = $Registry.Properties.displayDecimal
                        Default         = $Registry.Properties.default
                        Hive            = $Registry.Properties.hive #: HKEY_LOCAL_MACHINE
                        Key             = $Registry.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                        Name            = $Registry.Properties.name #: AutoAdminLogon
                        Type            = $Registry.Properties.type #: REG_SZ
                        Value           = $Registry.Properties.value #
                        Filters         = $Registry.Filters
                        BypassErrors    = $Registry.bypassErrors
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
    foreach ($Name in @('Registry', 'Collection')) {
        foreach ($Registry in $DataSet.$Name) {
            if ($Registry.Properties) {
                if ($Limited) {
                    [PSCustomObject] @{
                        Collection      = $Collection
                        Description     = $Registry.descr
                        Changed         = try { [DateTime] $Registry.changed } catch { $Registry.changed };
                        GPOSettingOrder = $Registry.GPOSettingOrder
                        Action          = $Script:Actions[$Registry.Properties.action]
                        DisplayDecimal  = $Registry.Properties.displayDecimal
                        Default         = $Registry.Properties.default
                        Hive            = $Registry.Properties.hive #: HKEY_LOCAL_MACHINE
                        Key             = $Registry.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                        Name            = $Registry.Properties.name #: AutoAdminLogon
                        Type            = $Registry.Properties.type #: REG_SZ
                        Value           = $Registry.Properties.value #
                        Filters         = $Registry.Filters
                        BypassErrors    = $Registry.bypassErrors
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
                        Action          = $Script:Actions[$Registry.Properties.action]
                        DisplayDecimal  = $Registry.Properties.displayDecimal
                        Default         = $Registry.Properties.default
                        Hive            = $Registry.Properties.hive #: HKEY_LOCAL_MACHINE
                        Key             = $Registry.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                        Name            = $Registry.Properties.name #: AutoAdminLogon
                        Type            = $Registry.Properties.type #: REG_SZ
                        Value           = $Registry.Properties.value #
                        Filters         = $Registry.Filters
                        BypassErrors    = $Registry.bypassErrors

                        <#
                        action         : D
                        displayDecimal : 1
                        default        : 0
                        hive           : HKEY_LOCAL_MACHINE
                        key            : SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}
                        name           :
                        type           : REG_SZ
                        value          :
                        Values         :
                        #>

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