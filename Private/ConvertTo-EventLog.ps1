function ConvertTo-EventLog {
    [cmdletBinding()]
    param(
        [Array] $GPOList
    )
    foreach ($GPOEntry in $GPOList) {
        $CreateGPO = [ordered]@{
            DisplayName = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
            DomainName  = $GPOEntry.DomainName    #: area1.local
            GUID        = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
            GpoType     = $GPOEntry.GpoType       #: Computer
            GpoCategory = $GPOEntry.GpoCategory   #: SecuritySettings
            GpoSettings = $GPOEntry.GpoSettings   #: SecurityOptions
            Type        = $GPOEntry.Type
            Policy      = $GPOEntry.Name

        }
        if ($GPOEntry.SettingBoolean) {
            $CreateGPO['Setting'] = if ($GPOEntry.SettingBoolean -eq 'true') { 'Enabled' } elseif ($GPOEntry.SettingBoolean -eq 'false') { 'Disabled' } else { $null };
            #try { [bool]::Parse($GPOEntry.SettingBoolean) } catch { $null };
        } elseif ($GPOEntry.SettingNumber) {
            $CreateGPO['Setting'] = $GPOEntry.SettingNumber
        }
        $CreateGPO['Linked'] = $GPOEntry.Linked        #: True
        $CreateGPO['LinksCount'] = $GPOEntry.LinksCount    #: 1
        $CreateGPO['Links'] = $GPOEntry.Links         #: area1.local
        [PSCustomObject] $CreateGPO
    }
}