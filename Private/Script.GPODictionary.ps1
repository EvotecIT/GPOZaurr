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

    LocalUsersAndGroups  = [ordered] @{
        Category   = 'LugsSettings'
        Settings   = 'LocalUsersAndGroups'
        Code       = {
            #ConvertTo-LocalUserAndGroups -GPOList $GPOList
            ConvertTo-XMLLocalUserAndGroups -GPO $GPO
        }
        CodeSingle = {
            #ConvertTo-EventLog -GPOList $GPOList
            ConvertTo-XMLLocalUserAndGroups -GPO $GPO -SingleObject
        }
    }

    Policies             = @{
        Category   = 'RegistrySettings'
        Settings   = 'Policy'
        Code       = {
            ConvertTo-XMLPolicies -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLPolicies -GPO $GPO -SingleObject
        }
    }
    RegistrySettings     = [ordered] @{
        Category   = 'RegistrySettings'
        Settings   = 'RegistrySettings'
        Code       = {
            ConvertTo-XMLRegistrySettings -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLRegistrySettings -GPO $GPO -SingleObject
        }
    }
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
    SecurityOptions      = [ordered] @{
        Category   = 'SecuritySettings'
        Settings   = 'SecurityOptions'
        Code       = {
            #ConvertTo-SecurityOptions -GPOList $GPOList
            ConvertTo-XMLSecurityOptions -GPO $GPO
        }
        CodeSingle = {
            #ConvertTo-SecurityOptions -GPOList $GPOList
            ConvertTo-XMLSecurityOptions -GPO $GPO -SingleObject
        }
    }
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
    SystemServices       = [ordered] @{
        Description = ''
        GPOPath     = 'Computer Configuration -> Policies -> Windows Settings -> Security Settings -> System Services'
        Category    = 'SecuritySettings'
        Settings    = 'SystemServices'
        Code        = {
            # ConvertTo-SoftwareInstallation -GPOList $GPOList
            ConvertTo-XMLSystemServices -GPO $GPO
        }
        CodeSingle  = {
            ConvertTo-XMLSystemServices -GPO $GPO -SingleObject
        }
    }
    SystemServicesNT     = [ordered] @{
        Description = ''
        GPOPath     = 'Computer Configuration -> Preferences -> Control Pannel Settings -> Services'
        Category    = 'ServiceSettings'
        Settings    = 'NTServices'
        Code        = {
            # ConvertTo-SoftwareInstallation -GPOList $GPOList
            ConvertTo-XMLSystemServicesNT -GPO $GPO
        }
        CodeSingle  = {
            ConvertTo-XMLSystemServicesNT -GPO $GPO -SingleObject
        }
    }
}