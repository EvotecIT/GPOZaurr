function ConvertTo-XMLRegistryAutologon {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO
    )
    $CreateGPO = [ordered]@{
        DisplayName                  = $GPO.DisplayName
        DomainName                   = $GPO.DomainName
        GUID                         = $GPO.GUID
        GpoType                      = $GPO.GpoType
        #GpoCategory = $GPOEntry.GpoCategory
        #GpoSettings = $GPOEntry.GpoSettings
        AutoAdminLogon               = $null
        DefaultDomainName            = $null
        DefaultUserName              = $null
        DefaultPassword              = $null
        DateChangedAutoAdminLogon    = $null
        DateChangedDefaultDomainName = $null
        DateChangedDefaultUserName   = $null
        DateChangedDefaultPassword   = $null
    }
    foreach ($Registry in $GPO.DataSet.Registry) {
        if ($Registry.Properties.Key -eq 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon') {
            if ($Registry.Properties.Name -eq 'AutoAdminLogon') {
                $CreateGPO['AutoAdminLogon'] = [bool] $Registry.Properties.value
                $CreateGPO['DateChangedAutoAdminLogon'] = [DateTime] $Registry.changed
            } elseif ($Registry.Properties.Name -eq 'DefaultDomainName') {
                $CreateGPO['DefaultDomainName'] = $Registry.Properties.value
                $CreateGPO['DateChangedDefaultDomainName'] = [DateTime] $Registry.changed
            } elseif ($Registry.Properties.Name -eq 'DefaultUserName') {
                $CreateGPO['DefaultUserName'] = $Registry.Properties.value
                $CreateGPO['DateChangedDefaultUserName'] = [DateTime] $Registry.changed
            } elseif ($Registry.Properties.Name -eq 'DefaultPassword') {
                $CreateGPO['DefaultPassword'] = $Registry.Properties.value
                $CreateGPO['DateChangedDefaultPassword'] = [DateTime] $Registry.changed
            }
        }
    }
    if ($null -ne $CreateGPO['AutoAdminLogon'] -or
        $null -ne $CreateGPO['DefaultDomainName'] -or
        $null -ne $CreateGPO['DefaultUserName'] -or
        $null -ne $CreateGPO['DefaultPassword']
    ) {
        $CreateGPO['Linked'] = $GPOEntry.Linked
        $CreateGPO['LinksCount'] = $GPOEntry.LinksCount
        $CreateGPO['Links'] = $GPOEntry.Links
        [PSCustomObject] $CreateGPO
    }
}