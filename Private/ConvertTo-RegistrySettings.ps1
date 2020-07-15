function ConvertTo-RegistrySettings {
    [cmdletBinding()]
    param(
        [Array] $GPOList
    )
    foreach ($GPOEntry in $GPOList) {
        foreach ($Registry in $GPOEntry.Registry) {
            $CreateGPO = [ordered]@{
                DisplayName     = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
                DomainName      = $GPOEntry.DomainName    #: area1.local
                GUID            = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
                GpoType         = $GPOEntry.GpoType       #: Computer
                GpoCategory     = $GPOEntry.GpoCategory   #: SecuritySettings
                GpoSettings     = $GPOEntry.GpoSettings   #: SecurityOptions
                Changed         = [DateTime] $Registry.changed
                GPOSettingOrder = $Registry.GPOSettingOrder
                Hive            = $Registry.Properties.hive #: HKEY_LOCAL_MACHINE
                Key             = $Registry.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                Name            = $Registry.Properties.name #: AutoAdminLogon
                Type            = $Registry.Properties.type #: REG_SZ
                Value           = $Registry.Properties.value #
                Filters         = $Registry.Filters
            }
            $CreateGPO['Linked'] = $GPOEntry.Linked        #: True
            $CreateGPO['LinksCount'] = $GPOEntry.LinksCount    #: 1
            $CreateGPO['Links'] = $GPOEntry.Links         #: area1.local
            [PSCustomObject] $CreateGPO
        }
    }
}


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
                    Changed         = [DateTime] $Registry.changed
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
        }
    }
    foreach ($Name in @('Registry', 'Collection')) {
        foreach ($Registry in $DataSet.$Name) {
            if ($Registry.Properties) {
                if ($Limited) {
                    [PSCustomObject] @{
                        Collection      = $Collection
                        Changed         = [DateTime] $Registry.changed
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