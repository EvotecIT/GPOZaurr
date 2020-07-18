$Script:GPODitionary = [ordered] @{
    AccountPolicies      = [ordered] @{
        Types      = @(
            @{
                Category = 'SecuritySettings'
                Settings = 'Account'
            }
        )
        GPOPath    = 'Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Account Policies'
        Code       = {
            ConvertTo-XMLAccountPolicy -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLAccountPolicy -GPO $GPO
        }
    }
    Audit                = [ordered] @{
        Types      = @(
            @{
                Category = 'SecuritySettings'
                Settings = 'Audit'
            }
        )
        GPOPath    = ''
        Code       = {
            ConvertTo-XMLAudit -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLAudit -GPO $GPO
        }
    }
    Autologon            = [ordered] @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'RegistrySettings'
            }
        )
        Code       = {
            ConvertTo-XMLRegistryAutologon -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLRegistryAutologon -GPO $GPO
        }
    }
    DriveMapping         = [ordered] @{
        Types      = @(
            @{
                Category = 'DriveMapSettings'
                Settings = 'DriveMapSettings'
            }
        )
        GPOPath    = ''
        Code       = {
            ConvertTo-XMLDriveMapSettings -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLDriveMapSettings -GPO $GPO -SingleObject
        }
    }
    EventLog             = [ordered] @{
        Types      = @(
            @{
                Category = 'SecuritySettings'
                Settings = 'EventLog'
            }
        )
        GPOPath    = ''
        Code       = {
            ConvertTo-XMLEventLog -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLEventLog -GPO $GPO
        }
    }
    LocalUsers           = [ordered] @{
        Types      = @(
            @{
                Category = 'LugsSettings'
                Settings = 'LocalUsersAndGroups'
            }
        )
        Code       = {
            ConvertTo-XMLLocalUser -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLLocalUser -GPO $GPO -SingleObject
        }
    }
    LocalGroups          = [ordered] @{
        Types      = @(
            @{
                Category = 'LugsSettings'
                Settings = 'LocalUsersAndGroups'
            }
        )
        Code       = {
            ConvertTo-XMLLocalGroups -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLLocalGroups -GPO $GPO -SingleObject
        }
    }
    Policies             = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code       = {
            ConvertTo-XMLPolicies -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLPolicies -GPO $GPO -SingleObject
        }
    }
    Printers             = @{
        Types      = @(
            @{
                Category = 'PrintersSettings'
                Settings = 'Printers'
            }
            @{
                Category = 'PrinterConnectionSettings'
                Settings = 'PrinterConnection'
            }
        )
        Code       = {
            ConvertTo-XMLPrinter -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLPrinter -GPO $GPO -SingleObject
        }
    }
    RegistrySettings     = [ordered] @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'RegistrySettings'
            }
        )
        Code       = {
            ConvertTo-XMLRegistrySettings -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLRegistrySettings -GPO $GPO -SingleObject
        }
    }
    Scripts              = [ordered] @{
        Types      = @(
            @{
                Category = 'Scripts'
                Settings = 'Script'
            }
        )
        Code       = {
            ConvertTo-XMLScripts -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLScripts -GPO $GPO -SingleObject
        }
    }
    SecurityOptions      = [ordered] @{
        Types      = @(
            @{
                Category = 'SecuritySettings'
                Settings = 'SecurityOptions'
            }
        )
        Code       = {
            ConvertTo-XMLSecurityOptions -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLSecurityOptions -GPO $GPO -SingleObject
        }
    }
    SoftwareInstallation = [ordered] @{
        Types      = @(
            @{
                Category = 'SoftwareInstallationSettings'
                Settings = 'MsiApplication'
            }
        )
        Code       = {
            ConvertTo-XMLSoftwareInstallation -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLSoftwareInstallation -GPO $GPO -SingleObject
        }
    }
    SystemServices       = [ordered] @{
        Types       = @(
            @{
                Category = 'SecuritySettings'
                Settings = 'SystemServices'
            }
        )
        Description = ''
        GPOPath     = 'Computer Configuration -> Policies -> Windows Settings -> Security Settings -> System Services'
        Code        = {
            ConvertTo-XMLSystemServices -GPO $GPO
        }
        CodeSingle  = {
            ConvertTo-XMLSystemServices -GPO $GPO -SingleObject
        }
    }
    SystemServicesNT     = [ordered] @{
        Types       = @(
            @{
                Category = 'ServiceSettings'
                Settings = 'NTServices'
            }
        )
        Description = ''
        GPOPath     = 'Computer Configuration -> Preferences -> Control Pannel Settings -> Services'
        Code        = {
            ConvertTo-XMLSystemServicesNT -GPO $GPO
        }
        CodeSingle  = {
            ConvertTo-XMLSystemServicesNT -GPO $GPO -SingleObject
        }
    }
    TaskScheduler        = [ordered] @{
        Types       = @(
            @{
                Category = 'ScheduledTasksSettings'
                Settings = 'ScheduledTasks'
            }
        )
        Description = ''
        GPOPath     = ''
        Code        = {
            ConvertTo-XMLTaskScheduler -GPO $GPO
        }
        CodeSingle  = {
            ConvertTo-XMLTaskScheduler -GPO $GPO -SingleObject
        }
    }
}