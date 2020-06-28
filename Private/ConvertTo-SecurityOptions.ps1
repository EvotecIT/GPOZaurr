function ConvertTo-SecurityOptions {
    [cmdletBinding()]
    param(
        [Array] $GPOList
    )
    foreach ($GPOEntry in $GPOList) {
        $CreateGPO = [ordered]@{
            DisplayName            = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
            DomainName             = $GPOEntry.DomainName    #: area1.local
            GUID                   = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
            GpoType                = $GPOEntry.GpoType       #: Computer
            GpoCategory            = $GPOEntry.GpoCategory   #: SecuritySettings
            GpoSettings            = $GPOEntry.GpoSettings   #: SecurityOptions
            KeyName                = $GPOEntry.KeyName
            KeyDisplayName         = $GPOEntry.Display.Name
            KeyDisplayUnits        = $GPOEntry.Display.Units
            KeyDisplayBoolean      = try { [bool]::Parse($GPOEntry.Display.DisplayBoolean) } catch { $null };
            KeyDisplayString       = $GPOEntry.Display.DisplayString
            SystemAccessPolicyName = $GPOEntry.SystemAccessPolicyName
            SettingString          = $GPOEntry.SettingString
            SettingNumber          = $GPOEntry.SettingNumber
        }
        $CreateGPO['Linked'] = $GPOEntry.Linked        #: True
        $CreateGPO['LinksCount'] = $GPOEntry.LinksCount    #: 1
        $CreateGPO['Links'] = $GPOEntry.Links         #: area1.local
        [PSCustomObject] $CreateGPO
    }
}