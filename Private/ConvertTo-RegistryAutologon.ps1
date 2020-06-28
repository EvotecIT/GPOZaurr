function ConvertTo-RegistryAutologon {
    [cmdletBinding()]
    param(
        [Array] $GPOList
    )
    foreach ($GPOEntry in $GPOList) {

        $CreateGPO = [ordered]@{
            DisplayName       = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
            DomainName        = $GPOEntry.DomainName    #: area1.local
            GUID              = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
            GpoType           = $GPOEntry.GpoType       #: Computer
            GpoCategory       = $GPOEntry.GpoCategory   #: SecuritySettings
            GpoSettings       = $GPOEntry.GpoSettings   #: SecurityOptions
            AutoAdminLogon    = $null
            DefaultDomainName = $null
            DefaultUserName   = $null
            DefaultPassword   = $null
        }

        foreach ($Registry in $GPOEntry.Registry) {
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
            $CreateGPO['Linked'] = $GPOEntry.Linked        #: True
            $CreateGPO['LinksCount'] = $GPOEntry.LinksCount    #: 1
            $CreateGPO['Links'] = $GPOEntry.Links         #: area1.local
            [PSCustomObject] $CreateGPO
        }
    }
}