# TODO: #2 Identical to ConvertTo-EventLog - decide what to do later on

function ConvertTo-AccountPolicies {
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

function ConvertTo-XMLAccountPolicies {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO
    )
    $CreateGPO = [ordered]@{
        DisplayName           = $GPO.DisplayName
        DomainName            = $GPO.DomainName
        GUID                  = $GPO.GUID
        GpoType               = $GPO.GpoType
        #GpoCategory = $GPOEntry.GpoCategory
        #GpoSettings = $GPOEntry.GpoSettings
        ClearTextPassword     = 'Not Set'
        LockoutBadCount       = 'Not Set'
        LockoutDuration       = 'Not Set'
        MaximumPasswordAge    = 'Not Set'
        MinimumPasswordAge    = 'Not Set'
        MinimumPasswordLength = 'Not Set'
        PasswordComplexity    = 'Not Set'
        PasswordHistorySize   = 'Not Set'
        ResetLockoutCount     = 'Not Set'
        MaxClockSkew          = 'Not Set'
        MaxRenewAge           = 'Not Set'
        MaxServiceAge         = 'Not Set'
        MaxTicketAge          = 'Not Set'
        TicketValidateClient  = 'Not Set'
    }
    foreach ($GPOEntry in $GPO.DataSet) {
        if ($GPOEntry.SettingBoolean) {
            $CreateGPO[$($GPOEntry.Name)] = if ($GPOEntry.SettingBoolean -eq 'true') { 'Enabled' } elseif ($GPOEntry.SettingBoolean -eq 'false') { 'Disabled' } else { 'Not set' };
        } elseif ($GPOEntry.SettingNumber) {
            $CreateGPO[$($GPOEntry.Name)] = $GPOEntry.SettingNumber
        }
    }
    $CreateGPO['Linked'] = $GPO.Linked
    $CreateGPO['LinksCount'] = $GPO.LinksCount
    $CreateGPO['Links'] = $GPO.Links
    [PSCustomObject] $CreateGPO
}