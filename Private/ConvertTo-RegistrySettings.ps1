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