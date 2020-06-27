$SecuritySettingsSecurityOptions = @{
    # This is to make sure we're not loosing anything
    # We will detect this and if something is missing provide details
    PossibleProperties = @(
        'KeyName'
        'SettingNumber'
        'Display'
        'SystemAccessPolicyName'
        'SettingString'
    )
    Translate          = [ordered] @{
        'KeyName'                = 'KeyName'
        'KeyDisplayName'         = 'Display', 'Name'
        'KeyDisplayUnits'        = 'Display', 'Units'
        'KeyDisplayBoolean'      = 'Display', 'DisplayBoolean'
        'KeyDisplayString'       = 'Display', 'DisplayString'
        'SystemAccessPolicyName' = 'SystemAccessPolicyName'
        'SettingString'          = 'SettingString'
        'SettingNumber'          = 'SettingNumber'
    }
    Types              = [ordered] @{
        'KeyDisplayBoolean' = { try { [bool]::Parse($args) } catch { $null } }
    }
}