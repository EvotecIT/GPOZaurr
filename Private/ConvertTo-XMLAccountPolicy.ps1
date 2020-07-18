function ConvertTo-XMLAccountPolicy {
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