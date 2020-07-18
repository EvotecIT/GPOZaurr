function ConvertTo-XMLEventLog {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO
    )
    $RetionPeriod = @{
        '0' = 'Overwrite events as needed'
        '1' = 'Overwrite events by days'
        '2' = 'Do not overwrite events (Clear logs manually)'
    }
    $CreateGPO = [ordered]@{
        DisplayName                        = $GPO.DisplayName
        DomainName                         = $GPO.DomainName
        GUID                               = $GPO.GUID
        GpoType                            = $GPO.GpoType
        #GpoCategory = $GPOEntry.GpoCategory
        #GpoSettings = $GPOEntry.GpoSettings
        ApplicationAuditLogRetentionPeriod = $null
        ApplicationMaximumLogSize          = $null
        ApplicationRestrictGuestAccess     = $null
        ApplicationRetentionDays           = $null
        SystemAuditLogRetentionPeriod      = $null
        SystemMaximumLogSize               = $null
        SystemRestrictGuestAccess          = $null
        SystemRetentionDays                = $null
        SecurityAuditLogRetentionPeriod    = $null
        SecurityMaximumLogSize             = $null
        SecurityRestrictGuestAccess        = $null
        SecurityRetentionDays              = $null
    }
    foreach ($GPOEntry in $GPO.DataSet) {
        if ($GPOEntry.SettingBoolean) {
            $CreateGPO["$($GPOEntry.Log)$($GPOEntry.Name)"] = if ($GPOEntry.SettingBoolean -eq 'true') { 'Enabled' } elseif ($GPOEntry.SettingBoolean -eq 'false') { 'Disabled' } else { 'Not set' };
        } elseif ($GPOEntry.SettingNumber) {
            if ($GPOEntry.Name -eq 'AuditLogRetentionPeriod') {
                if ($GPOEntry.SettingNumber) {
                    $CreateGPO["$($GPOEntry.Log)$($GPOEntry.Name)"] = $RetionPeriod[$($GPOEntry.SettingNumber)]
                } else {
                    # Won't happen?
                    $CreateGPO["$($GPOEntry.Log)$($GPOEntry.Name)"] = $GPOEntry.SettingNumber
                }
            } else {
                $CreateGPO["$($GPOEntry.Log)$($GPOEntry.Name)"] = $GPOEntry.SettingNumber
            }
        }
    }
    $CreateGPO['Linked'] = $GPO.Linked
    $CreateGPO['LinksCount'] = $GPO.LinksCount
    $CreateGPO['Links'] = $GPO.Links
    [PSCustomObject] $CreateGPO
}