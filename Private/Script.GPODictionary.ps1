$Script:GPODitionary = [ordered] @{
    AccountPolicies      = [ordered] @{
        Category   = 'SecuritySettings'
        Settings   = 'Account'
        GPOPath    = 'Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Account Policies'
        Code       = {
            #ConvertTo-AccountPolicies -GPOList $GPOList
            ConvertTo-XMLAccountPolicies -GPO $GPO
        }
        CodeSingle = {
            #ConvertTo-AccountPolicies -GPOList $GPOList
            ConvertTo-XMLAccountPolicies -GPO $GPO
        }
    }
    Audit                = [ordered] @{
        Category   = 'SecuritySettings'
        Settings   = 'Audit'
        #GPOPath  = 'Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Account Policies'
        Code       = {
            ConvertTo-XMLAudit -GPO $GPO
            #ConvertTo-Audit -GPOList $GPOList
        }
        CodeSingle = {
            ConvertTo-XMLAudit -GPO $GPO
            #ConvertTo-Audit -GPOList $GPOList
        }
    }
    Autologon            = [ordered] @{
        Category   = 'RegistrySettings'
        Settings   = 'RegistrySettings'
        Code       = {
            #ConvertTo-RegistryAutologon -GPOList $GPOList
            ConvertTo-XMLRegistryAutologon -GPO $GPO
        }
        CodeSingle = {
            #ConvertTo-AccountPolicies -GPOList $GPOList
            ConvertTo-XMLRegistryAutologon -GPO $GPO
        }
    }
    EventLog             = [ordered] @{
        Category   = 'SecuritySettings'
        Settings   = 'EventLog'
        #GPOPath  = 'Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Account Policies'
        Code       = {
            #ConvertTo-EventLog -GPOList $GPOList
            ConvertTo-XMLEventLog -GPO $GPO
        }
        CodeSingle = {
            #ConvertTo-EventLog -GPOList $GPOList
            ConvertTo-XMLEventLog -GPO $GPO
        }
    }
    <#
    LocalUsersAndGroups = [ordered] @{
        Category = 'LugsSettings'
        Settings = 'LocalUsersAndGroups'
        Code     = {
            #ConvertTo-LocalUserAndGroups -GPOList $GPOList
            ConvertTo-XMLLocalUserAndGroups -GPO $GPO
        }
    }
    #>
    <#
    Policies                   = @{
        Category = 'RegistrySettings'
        Settings = 'Policy'
        Code     = {
            ConvertTo-Policies -GPOList $GPOList
        }
    }
    RegistrySettings           = [ordered] @{
        Category = 'RegistrySettings'
        Settings = 'RegistrySettings'
        Code     = {
            ConvertTo-RegistrySettings -GPOList $GPOList
        }
    }
    RegistrySettingsCollection = [ordered] @{
        Category = 'RegistrySettings'
        Settings = 'RegistrySettings'
        Code     = {
            ConvertTo-RegistrySettingsCollection -GPOList $GPOList
        }
    }
    #>
    Scripts              = [ordered] @{
        Category   = 'Scripts'
        Settings   = 'Script'
        Code       = {
            #ConvertTo-Scripts -GPOList $GPOList
            ConvertTo-XMLScripts -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLScripts -GPO $GPO -SingleObject
        }
    }
    <#
    SecurityOptions            = [ordered] @{
        Category = 'SecuritySettings'
        Settings = 'SecurityOptions'
        Code     = {
            ConvertTo-SecurityOptions -GPOList $GPOList
        }
    }
    #>
    SoftwareInstallation = [ordered] @{
        Category   = 'SoftwareInstallationSettings'
        Settings   = 'MsiApplication'
        Code       = {
            # ConvertTo-SoftwareInstallation -GPOList $GPOList
            ConvertTo-XMLSoftwareInstallation -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLSoftwareInstallation -GPO $GPO -SingleObject
        }
    }
    <#
    SystemServices             = [ordered] @{
        Description = ''
        GPOPath     = 'Computer Configuration -> Policies -> Windows Settings -> Security Settings -> System Services'
        Category    = 'SecuritySettings'
        Settings    = 'SystemServices'
        Code        = {
            ConvertTo-SystemServices -GPOList $GPOList
        }
    }
    SystemServicesNT           = [ordered] @{
        Description = ''
        GPOPath     = 'Computer Configuration -> Preferences -> Control Pannel Settings -> Services'
        Category    = 'ServiceSettings'
        Settings    = 'NTServices'
        Code        = {
            ConvertTo-SystemServicesNT -GPOList $GPOList
        }
    }
    #>
}