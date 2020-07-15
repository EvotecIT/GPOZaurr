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

function ConvertTo-XMLSecurityOptions {
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
        [Array] $CreateGPO['Settings'] = foreach ($Entry in $GPO.DataSet) {
            $Object = [ordered] @{}
            $Object['KeyName'] = $Entry.KeyName
            $Object['KeyDisplayName'] = $Entry.Display.Name
            $Object['KeyDisplayUnits'] = $Entry.Display.Units
            $Object['KeyDisplayBoolean'] = try { [bool]::Parse($Entry.Display.DisplayBoolean) } catch { $null };
            $Object['KeyDisplayString'] = $Entry.Display.DisplayString
            $Object['SystemAccessPolicyName'] = $Entry.SystemAccessPolicyName
            if ($Entry.SettingString) {
                $Object['KeyValue'] = $Entry.SettingString
            } else {
                $Object['KeyValue'] = $Entry.SettingNumber
            }
            [PSCustomObject] $Object
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Entry in $GPO.DataSet) {
            $CreateGPO = [ordered]@{
                DisplayName = $GPO.DisplayName
                DomainName  = $GPO.DomainName
                GUID        = $GPO.GUID
                GpoType     = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
            }
            $CreateGPO['KeyName'] = $Entry.KeyName
            $CreateGPO['KeyDisplayName'] = $Entry.Display.Name
            $CreateGPO['KeyDisplayUnits'] = $Entry.Display.Units
            $CreateGPO['KeyDisplayBoolean'] = try { [bool]::Parse($Entry.Display.DisplayBoolean) } catch { $null };
            $CreateGPO['KeyDisplayString'] = $Entry.Display.DisplayString
            $CreateGPO['SystemAccessPolicyName'] = $Entry.SystemAccessPolicyName
            if ($Entry.SettingString) {
                $CreateGPO['KeyValue'] = $Entry.SettingString
            } else {
                $CreateGPO['KeyValue'] = $Entry.SettingNumber
            }
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
    }
}