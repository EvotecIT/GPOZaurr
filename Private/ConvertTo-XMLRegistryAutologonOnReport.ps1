function ConvertTo-XMLRegistryAutologonOnReport {
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
    foreach ($Registry in $GPO.Settings) {
        if ($Registry.Key -eq 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon') {
            if ($Registry.Name -eq 'AutoAdminLogon') {
                $CreateGPO['AutoAdminLogon'] = [bool] $Registry.value
                $CreateGPO['DateChangedAutoAdminLogon'] = [DateTime] $Registry.changed
            } elseif ($Registry.Name -eq 'DefaultDomainName') {
                $CreateGPO['DefaultDomainName'] = $Registry.value
                $CreateGPO['DateChangedDefaultDomainName'] = [DateTime] $Registry.changed
            } elseif ($Registry.Name -eq 'DefaultUserName') {
                $CreateGPO['DefaultUserName'] = $Registry.value
                $CreateGPO['DateChangedDefaultUserName'] = [DateTime] $Registry.changed
            } elseif ($Registry.Name -eq 'DefaultPassword') {
                $CreateGPO['DefaultPassword'] = $Registry.value
                $CreateGPO['DateChangedDefaultPassword'] = [DateTime] $Registry.changed
            }
        }
    }
    if ($null -ne $CreateGPO['AutoAdminLogon'] -or
        $null -ne $CreateGPO['DefaultDomainName'] -or
        $null -ne $CreateGPO['DefaultUserName'] -or
        $null -ne $CreateGPO['DefaultPassword']
    ) {
        $CreateGPO['Linked'] = $GPO.Linked        #: True
        $CreateGPO['LinksCount'] = $GPO.LinksCount    #: 1
        $CreateGPO['Links'] = $GPO.Links         #: area1.local
        [PSCustomObject] $CreateGPO
    }
}