$Script:GPODitionary = [ordered] @{
    AccountPolicies         = [ordered] @{
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
    Audit                   = [ordered] @{
        Types      = @(
            @{
                Category = 'SecuritySettings'
                Settings = 'Audit'
            }
            @{
                Category = 'AuditSettings'
                Settings = 'AuditSetting'
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
    Autologon               = [ordered] @{
        # We want to process this based on other report called RegistrySettings
        # This is because registry settings can be stored in Collections or nested within other registry settings
        # The original function ConvertTo-XMLRegistryAutologon was processing it in limited ordered and potentially would skip some entries.
        <#
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'RegistrySettings'
            }
        )
        #>
        ByReports  = @(
            @{
                Report = 'RegistrySettings'
            }
        )
        <#
        Code       = {
            ConvertTo-XMLRegistryAutologon -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLRegistryAutologon -GPO $GPO
        }
        #>
        CodeReport = {
            ConvertTo-XMLRegistryAutologonOnReport -GPO $GPO
        }
    }
    Biometrics              = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            #ConvertTo-XMLBitlocker -GPO $GPO
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Biometrics*'
        }
    }
    Bitlocker               = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            #ConvertTo-XMLBitlocker -GPO $GPO
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/BitLocker Drive Encryption*'
        }
    }
    CredentialsDelegation   = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Credentials Delegation*'
        }
    }
    Desktop                 = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Desktop*'
        }
    }
    DnsClient               = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Network/DNS Client*'
        }
    }
    DriveMapping            = [ordered] @{
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
    EventLog                = [ordered] @{
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
    FileExplorer            = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/File Explorer*'
        }
    }
    GroupPolicy             = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Group Policy*'
        }
    }
    InternetExplorer        = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Internet Explorer*'
        }
    }
    LAPS                    = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            #ConvertTo-XMLLaps -GPO $GPO
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'LAPS'
        }
    }
    Lithnet                 = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            #ConvertTo-XMLLithnetFilter -GPO $GPO
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Lithnet/Password Protection for Active Directory*'
        }
    }
    LocalUsers              = [ordered] @{
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
    LocalGroups             = [ordered] @{
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
    Logon                   = @{
        Types = @(
            @{ Category = 'RegistrySettings'; Settings = 'Policy' }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Logon*'
        }
    }
    MicrosoftOutlook2010    = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2010*'
        }
    }
    MicrosoftOutlook2016    = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2016*'
        }
    }
    Policies                = @{
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
    Printers                = @{
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
    PrintersPolicies        = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Printers*', 'Control Panel/Printers*'
        }
    }
    RegistrySettings        = [ordered] @{
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
    RemoteDesktopServices   = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Remote Desktop Services*'
        }
    }
    Scripts                 = [ordered] @{
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
    SecurityOptions         = [ordered] @{
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
    SoftwareInstallation    = [ordered] @{
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
    SystemServices          = [ordered] @{
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
    SystemServicesNT        = [ordered] @{
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
    TaskScheduler           = [ordered] @{
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
    WindowsHelloForBusiness = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Hello For Business*'
        }
    }
    WindowsRemoteManagement = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Remote Management (WinRM)*'
        }
    }
    WindowsUpdate           = @{
        Types = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        Code  = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Update*', 'Windows Components/Delivery Optimization*'
        }
    }
}