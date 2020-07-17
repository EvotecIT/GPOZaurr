$Script:GPODitionary = [ordered] @{
    AccountPolicies      = [ordered] @{
        Category   = 'SecuritySettings'
        Settings   = 'Account'
        GPOPath    = 'Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Account Policies'
        Code       = {
            ConvertTo-XMLAccountPolicies -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLAccountPolicies -GPO $GPO
        }
    }
    Audit                = [ordered] @{
        Category   = 'SecuritySettings'
        Settings   = 'Audit'
        GPOPath    = ''
        Code       = {
            ConvertTo-XMLAudit -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLAudit -GPO $GPO
        }
    }
    Autologon            = [ordered] @{
        Category   = 'RegistrySettings'
        Settings   = 'RegistrySettings'
        Code       = {
            ConvertTo-XMLRegistryAutologon -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLRegistryAutologon -GPO $GPO
        }
    }
    DriveMapping         = [ordered] @{
        Category   = 'DriveMapSettings'
        Settings   = 'DriveMapSettings'
        GPOPath    = ''
        Code       = {
            ConvertTo-XMLDriveMapSettings -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLDriveMapSettings -GPO $GPO -SingleObject
        }
    }
    EventLog             = [ordered] @{
        Category   = 'SecuritySettings'
        Settings   = 'EventLog'
        GPOPath    = ''
        Code       = {
            ConvertTo-XMLEventLog -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLEventLog -GPO $GPO
        }
    }
    LocalUsers           = [ordered] @{
        Category   = 'LugsSettings'
        Settings   = 'LocalUsersAndGroups'
        Code       = {
            ConvertTo-XMLLocalUser -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLLocalUser -GPO $GPO -SingleObject
        }
    }
    LocalGroups          = [ordered] @{
        Category   = 'LugsSettings'
        Settings   = 'LocalUsersAndGroups'
        Code       = {
            ConvertTo-XMLLocalGroups -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLLocalGroups -GPO $GPO -SingleObject
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
    Printers             = @{
        Category   = 'PrintersSettings'
        Settings   = 'Printers'
        Code       = {
            ConvertTo-XMLPrinters -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLPrinters -GPO $GPO -SingleObject
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
            ConvertTo-XMLSecurityOptions -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLSecurityOptions -GPO $GPO -SingleObject
        }
    }
    SoftwareInstallation = [ordered] @{
        Category   = 'SoftwareInstallationSettings'
        Settings   = 'MsiApplication'
        Code       = {
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
            ConvertTo-XMLSystemServicesNT -GPO $GPO
        }
        CodeSingle  = {
            ConvertTo-XMLSystemServicesNT -GPO $GPO -SingleObject
        }
    }
}