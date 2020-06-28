$RegistrySettingsCollection = [ordered] @{
    Category           = 'RegistrySettings'
    Settings           = 'RegistrySettings'
    # This is to make sure we're not loosing anything
    # We will detect this and if something is missing provide details
    PossibleProperties = @(
        'clsid', 'Registry', 'Collection'
    )
    LoopOver           = [ordered] @{
        Collection = [ordered] @{
            'Changed'         = 'Changed'
            'GPOSettingOrder' = 'GPOSettingOrder'
            'Filters'         = 'Filters'
            'BypassErrors'    = 'bypassErrors'
            Registry          = [ordered] @{
                'Hive'           = 'Properties', 'Hive'
                'Key'            = 'Properties', 'Key'
                'Name'           = 'Properties', 'Name'
                'Type'           = 'Properties', 'Type'
                'action'         = 'Properties', 'action'
                'displayDecimal' = 'Properties', 'displayDecimal'
                'default'        = 'Properties', 'default'
                'Value'          = 'Properties', 'Value'
            }
        }
    }
    Translate          = [ordered] @{

    }
    Types              = [ordered] @{
        'Changed' = { try { [datetime]::Parse($args) } catch { $null } }
    }
}