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
                        Disabled        = if ($Registry.disabled -eq '1') { $true } else { $false };
                        GPOSettingOrder = [int] $Registry.GPOSettingOrder
                        Action          = $Script:Actions[$Registry.Properties.action]
                        DisplayDecimal  = if ($Registry.Properties.displayDecimal -eq '1') { $true } else { $false };
                        Default         = if ($Registry.Properties.default -eq '1') { $true } else { $false };
                        Hive            = $Registry.Properties.hive #: HKEY_LOCAL_MACHINE
                        Key             = $Registry.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                        Name            = $Registry.Properties.name #: AutoAdminLogon
                        Type            = $Registry.Properties.type #: REG_SZ
                        Value           = $Registry.Properties.value #
                        Filters         = $Registry.Filters
                        BypassErrors    = if ($Registry.bypassErrors -eq '1') { $true } else { $false };
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
                        Disabled        = if ($Registry.disabled -eq '1') { $true } else { $false };
                        GPOSettingOrder = [int] $Registry.GPOSettingOrder
                        Action          = $Script:Actions[$Registry.Properties.action]
                        DisplayDecimal  = if ($Registry.Properties.displayDecimal -eq '1') { $true } else { $false };
                        Default         = if ($Registry.Properties.default -eq '1') { $true } else { $false };
                        Hive            = $Registry.Properties.hive #: HKEY_LOCAL_MACHINE
                        Key             = $Registry.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                        Name            = $Registry.Properties.name #: AutoAdminLogon
                        Type            = $Registry.Properties.type #: REG_SZ
                        Value           = $Registry.Properties.value #
                        Filters         = $Registry.Filters
                        BypassErrors    = if ($Registry.bypassErrors -eq '1') { $true } else { $false };
                    }
                    $CreateGPO['Linked'] = $GPO.Linked
                    $CreateGPO['LinksCount'] = $GPO.LinksCount
                    $CreateGPO['Links'] = $GPO.Links
                    [PSCustomObject] $CreateGPO
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
                        Disabled        = if ($Registry.disabled -eq '1') { $true } else { $false };
                        GPOSettingOrder = [int] $Registry.GPOSettingOrder
                        Action          = $Script:Actions[$Registry.Properties.action]
                        DisplayDecimal  = if ($Registry.Properties.displayDecimal -eq '1') { $true } else { $false };
                        Default         = if ($Registry.Properties.default -eq '1') { $true } else { $false };
                        Hive            = $Registry.Properties.hive #: HKEY_LOCAL_MACHINE
                        Key             = $Registry.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                        Name            = $Registry.Properties.name #: AutoAdminLogon
                        Type            = $Registry.Properties.type #: REG_SZ
                        Value           = $Registry.Properties.value #
                        Filters         = $Registry.Filters
                        BypassErrors    = if ($Registry.bypassErrors -eq '1') { $true } else { $false };
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
                        Disabled        = if ($Registry.disabled -eq '1') { $true } else { $false };
                        GPOSettingOrder = [int] $Registry.GPOSettingOrder
                        Action          = $Script:Actions[$Registry.Properties.action]
                        DisplayDecimal  = if ($Registry.Properties.displayDecimal -eq '1') { $true } else { $false }; ;
                        Default         = if ($Registry.Properties.default -eq '1') { $true } else { $false };
                        Hive            = $Registry.Properties.hive #: HKEY_LOCAL_MACHINE
                        Key             = $Registry.Properties.key  #: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
                        Name            = $Registry.Properties.name #: AutoAdminLogon
                        Type            = $Registry.Properties.type #: REG_SZ
                        Value           = $Registry.Properties.value #
                        Filters         = $Registry.Filters
                        BypassErrors    = if ($Registry.bypassErrors -eq '1') { $true } else { $false };
                    }
                    $CreateGPO['Linked'] = $GPO.Linked
                    $CreateGPO['LinksCount'] = $GPO.LinksCount
                    $CreateGPO['Links'] = $GPO.Links
                    [PSCustomObject] $CreateGPO
                }
            } else {
                if ($Registry.Registry) {
                    #if ($Registry.Name.Count -gt 1) {
                    #Write-Verbose "Registry Name count more than 1"
                    #}
                    $TempCollection = $Collection
                    if ($Collection) {
                        $Collection = "$Collection/$($Registry.name)"
                    } else {
                        $Collection = $Registry.name
                    }
                    Get-XMLNestedRegistry -GPO $GPO -DataSet $Registry.Registry -Collection $Collection
                    $Collection = $TempCollection
                }
                if ($Registry.Collection) {
                    $TempCollection = $Collection
                    #if ($Registry.Collection.Count -gt 1) {
                    # Write-Verbose "Registry collection count more than 1"
                    #}
                    foreach ($MyCollection in $Registry.Collection) {
                        if ($Collection) {
                            #Write-Verbose "Collection1: $Collection - $($Registry.name) - $($MyCollection.name) - $($($MyCollection.name).Count)"
                            $Collection = "$Collection/$($Registry.name)/$($MyCollection.name)"
                            #Write-Verbose "Collection2: $Collection"
                        } else {
                            #Write-Verbose "Collection3: $Collection - $($Registry.name) - $($MyCollection.name)"
                            $Collection = "$($Registry.name)/$($MyCollection.name)"
                            #Write-Verbose "Collection4: $Collection"
                        }

                        Get-XMLNestedRegistry -GPO $GPO -DataSet $MyCollection -Collection $Collection
                        $Collection = $TempCollection
                    }
                }
            }
        }

    }
}