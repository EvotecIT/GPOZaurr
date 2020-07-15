function ConvertTo-RegistrySettingsCollection {
    [cmdletBinding()]
    param(
        [Array] $GPOList
    )
    foreach ($GPOEntry in $GPOList) {
        foreach ($Collection in $GPOEntry.Collection) {
            $OutputDictionaries = foreach ($Registry in $Collection.Registry) {
                [ordered] @{
                    #"$($Registry.Name)FieldName"       = $Registry.Name
                    #"$($Registry.Name)FieldStatus"     = $Registry.Status
                    "$($Registry.Name)BypassErrors"    = try { [bool]::Parse($Registry.BypassErrors) } catch { $null };
                    "$($Registry.Name)Changed"         = [DateTime] $Registry.Changed
                    "$($Registry.Name)UID"             = $Registry.UID
                    "$($Registry.Name)GPOSettingOrder" = $Registry.GPOSettingOrder
                    "$($Registry.Name)Action"          = $Registry.Properties.action
                    "$($Registry.Name)DisplayDecimal"  = $Registry.Properties.displayDecimal
                    "$($Registry.Name)Default"         = $Registry.Properties.default
                    "$($Registry.Name)Hive"            = $Registry.Properties.hive
                    "$($Registry.Name)Name"            = $Registry.Properties.name
                    "$($Registry.Name)Type"            = $Registry.Properties.type
                    "$($Registry.Name)Value"           = $Registry.Properties.value
                    "$($Registry.Name)Values"          = $Registry.Properties.Values
                }
            }
            $CreateGPO = [ordered]@{
                DisplayName = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
                DomainName  = $GPOEntry.DomainName    #: area1.local
                GUID        = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
                GpoType     = $GPOEntry.GpoType       #: Computer
                GpoCategory = $GPOEntry.GpoCategory   #: SecuritySettings
                GpoSettings = $GPOEntry.GpoSettings   #: SecurityOptions
            }
            foreach ($Dictionary in $OutputDictionaries) {
                $CreateGPO = $CreateGPO + $Dictionary
            }
            $CreateGPO['Linked'] = $GPOEntry.Linked        #: True
            $CreateGPO['LinksCount'] = $GPOEntry.LinksCount    #: 1
            $CreateGPO['Links'] = $GPOEntry.Links         #: area1.local
            [PSCustomObject] $CreateGPO
        }
    }
}