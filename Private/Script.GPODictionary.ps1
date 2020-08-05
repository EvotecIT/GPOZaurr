$Script:GPODitionary = [ordered] @{
    AccountPolicies                 = [ordered] @{
        Types      = @(
            @{
                Category = 'SecuritySettings'
                Settings = 'Account'
            }
        )
        GPOPath    = 'Policies -> Windows Settings -> Security Settings -> Account Policies'
        Code       = {
            ConvertTo-XMLAccountPolicy -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLAccountPolicy -GPO $GPO
        }
    }
    Audit                           = [ordered] @{
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
        GPOPath    = @(
            'Policies -> Windows Settings -> Security Settings -> Advanced Audit Policy Configuration -> Audit Policies'
            'Policies -> Windows Settings -> Security Settings -> Local Policies -> Audit Policy'
        )
        Code       = {
            ConvertTo-XMLAudit -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLAudit -GPO $GPO
        }
    }
    Autologon                       = [ordered] @{
        # We want to process this based on other report called RegistrySettings
        # This is because registry settings can be stored in Collections or nested within other registry settings
        # The original function ConvertTo-XMLRegistryAutologon was processing it in limited ordered and potentially would skip some entries.
        ByReports  = @(
            @{
                Report = 'RegistrySettings'
            }
        )
        GPOPath    = 'Preferences -> Windows Settings -> Registry'
        CodeReport = {
            ConvertTo-XMLRegistryAutologonOnReport -GPO $GPO
        }
    }
    AutoPlay                        = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/AutoPlay Policies'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/AutoPlay Policies*'
        }
    }
    Biometrics                      = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Biometrics'
        Code    = {
            #ConvertTo-XMLBitlocker -GPO $GPO
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Biometrics*'
        }
    }
    Bitlocker                       = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/BitLocker Drive Encryption'
        Code    = {
            #ConvertTo-XMLBitlocker -GPO $GPO
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/BitLocker Drive Encryption*'
        }
    }
    ControlPanel                    = [ordered]@{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Controol Panel'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel'
        }
    }
    ControlPanelAddRemove           = [ordered]@{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Control Panel/Add or Remove Programs'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Add or Remove Programs'
        }
    }
    ControlPanelDisplay             = [ordered]@{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Control Panel/Display'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Display'
        }
    }
    ControlPanelPersonalization     = [ordered]@{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Control Panel/Personalization'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Personalization'
        }
    }
    ControlPanelPrinters            = [ordered]@{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Control Panel/Printers'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Printers'
        }
    }
    ControlPanelPrograms            = [ordered]@{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Control Panel/Programs'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Programs'
        }
    }
    ControlPanelRegional            = [ordered]@{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Control Panel/Regional and Language Options'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Regional and Language Options'
        }
    }
    CredentialsDelegation           = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> System/Credentials Delegation'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Credentials Delegation*'
        }
    }
    CustomInternationalSettings     = [ordered]@{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Custom International Settings'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Custom International Settings*'
        }
    }
    Desktop                         = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Desktop'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Desktop*'
        }
    }
    DnsClient                       = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Network/DNS Client'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Network/DNS Client*'
        }
    }
    DriveMapping                    = [ordered] @{
        Types      = @(
            @{
                Category = 'DriveMapSettings'
                Settings = 'DriveMapSettings'
            }
        )
        GPOPath    = 'Preferences -> Windows Settings -> Drive Maps'
        Code       = {
            ConvertTo-XMLDriveMapSettings -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLDriveMapSettings -GPO $GPO -SingleObject
        }
    }
    EventLog                        = [ordered] @{
        Types      = @(
            @{
                Category = 'SecuritySettings'
                Settings = 'EventLog'
            }
        )
        GPOPath    = 'Policies -> Windows Settings -> Security Settings -> Event Log'
        Code       = {
            ConvertTo-XMLEventLog -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLEventLog -GPO $GPO
        }
    }
    EventForwarding                 = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Event Forwarding'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Event Forwarding*'
        }
    }
    EventLogService                 = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Event Log Service'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Event Log Service*'
        }
    }
    FileExplorer                    = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/File Explorer'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/File Explorer*'
        }
    }
    FolderRedirection               = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> System/Folder Redirection'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Folder Redirection'
        }
    }
    FSLogix                         = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> FSLogix'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'FSLogix'
        }
    }
    GoogleChrome                    = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = @(
            'Policies -> Administrative Templates -> Google Chrome'
            'Policies -> Administrative Templates -> Google/Google Chrome'
            'Policies -> Administrative Templates -> Google Chrome - Default Settings (users can override)'
        )
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Google Chrome', 'Google/Google Chrome', 'Google Chrome - Default Settings (users can override)'
        }
    }
    GroupPolicy                     = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> System/Group Policy'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Group Policy*'
        }
    }
    InternetCommunicationManagement = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> System/Internet Communication Management'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Internet Communication Management*'
        }
    }
    InternetExplorer                = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Internet Explorer'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Internet Explorer*', 'Composants Windows/Celle Internet Explorer'
        }
    }
    InternetExplorerZones           = [ordered] @{
        ByReports  = @(
            @{
                Report = 'RegistrySettings'
            }
        )
        GPOPath    = 'Preferences -> Windows Settings -> Registry'
        CodeReport = {
            ConvertTo-XMLRegistryInternetExplorerZones -GPO $GPO
        }
    }
    KDC                             = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> System/KDC'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/KDC'
        }
    }
    LAPS                            = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> LAPS'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'LAPS'
        }
    }
    Lithnet                         = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Lithnet/Password Protection for Active Directory'
        Code    = {
            #ConvertTo-XMLLithnetFilter -GPO $GPO
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Lithnet/Password Protection for Active Directory*'
        }
    }
    LocalUsers                      = [ordered] @{
        Types      = @(
            @{
                Category = 'LugsSettings'
                Settings = 'LocalUsersAndGroups'
            }
        )
        GPOPath    = 'Preferences -> Control Panel Settings -> Local Users and Groups'
        Code       = {
            ConvertTo-XMLLocalUser -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLLocalUser -GPO $GPO -SingleObject
        }
    }
    LocalGroups                     = [ordered] @{
        Types      = @(
            @{
                Category = 'LugsSettings'
                Settings = 'LocalUsersAndGroups'
            }
        )
        GPOPath    = 'Preferences -> Control Panel Settings -> Local Users and Groups'
        Code       = {
            ConvertTo-XMLLocalGroups -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLLocalGroups -GPO $GPO -SingleObject
        }
    }
    Logon                           = @{
        Types   = @(
            @{ Category = 'RegistrySettings'; Settings = 'Policy' }
        )
        GPOPath = 'Policies -> Administrative Templates -> System/Logon'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Logon*'
        }
    }
    MicrosoftOutlook2002            = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Microsoft Outlook 2002'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2002*'
        }
    }
    MicrosoftEdge                   = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = @(
            'Policies -> Administrative Templates -> Microsoft Edge'
            'Policies -> Administrative Templates -> Windows Components/Edge UI'
            'Policies -> Administrative Templates -> Windows Components/Microsoft Edge'
        )
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Edge*', 'Windows Components/Microsoft Edge', 'Windows Components/Edge UI'
        }
    }
    MicrosoftOutlook2003            = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = @(
            'Policies -> Administrative Templates -> Microsoft Office Outlook 2003'
            'Policies -> Administrative Templates -> Outlook 2003 RPC Encryption'
        )
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Office Outlook 2003*', 'Outlook 2003 RPC Encryption'
        }
    }
    MicrosoftOutlook2010            = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Microsoft Outlook 2010'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2010*'
        }
    }
    MicrosoftOutlook2013            = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Microsoft Outlook 2013'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2013*'
        }
    }
    MicrosoftOutlook2016            = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Microsoft Outlook 2016'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2016*'
        }
    }
    MicrosoftManagementConsole      = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Microsoft Management Console'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Microsoft Management Console*'
        }
    }
    NetMeeting                      = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/NetMeeting'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/NetMeeting*'
        }
    }
    MSSLegacy                       = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> MSS (Legacy)'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'MSS (Legacy)'
        }
    }
    MSSecurityGuide                 = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> MS Security Guide'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'MS Security Guide'
        }
    }
    OneDrive                        = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/OneDrive'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/OneDrive*'
        }
    }
    Policies                        = @{
        Comment    = "This isn't really translated"
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates'
        Code       = {
            ConvertTo-XMLPolicies -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLPolicies -GPO $GPO -SingleObject
        }
    }
    Printers                        = @{
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
        GPOPath    = 'Preferences -> Control Panel Settings -> Printers'
        Code       = {
            ConvertTo-XMLPrinter -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLPrinter -GPO $GPO -SingleObject
        }
    }
    PrintersPolicies                = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = @(
            'Policies -> Administrative Templates -> Printers'
            'Policies -> Administrative Templates -> Control Panel/Printers'
        )
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Printers*', 'Control Panel/Printers*'
        }
    }
    RegistrySettings                = [ordered] @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'RegistrySettings'
            }
        )
        GPOPath    = 'Preferences -> Windows Settings -> Registry'
        Code       = {
            ConvertTo-XMLRegistrySettings -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLRegistrySettings -GPO $GPO -SingleObject
        }
    }
    OnlineAssistance                = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Online Assistance'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Online Assistance*'
        }
    }
    RemoteAssistance                = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> System/Remote Assistance'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Remote Assistance*'
        }
    }
    RemoteDesktopServices           = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Remote Desktop Services'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Remote Desktop Services*'
        }
    }
    RSSFeeds                        = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/RSS Feeds'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/RSS Feeds*'
        }
    }
    Scripts                         = [ordered] @{
        Types      = @(
            @{
                Category = 'Scripts'
                Settings = 'Script'
            }
        )
        GPOPath    = 'Policies -> Windows Settings -> Scripts'
        Code       = {
            ConvertTo-XMLScripts -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLScripts -GPO $GPO -SingleObject
        }
    }
    SecurityOptions                 = [ordered] @{
        Types      = @(
            @{
                Category = 'SecuritySettings'
                Settings = 'SecurityOptions'
            }
        )
        GPOPath    = 'Policies -> Windows Settings -> Security Settings -> Local Policies -> Security Options'
        Code       = {
            ConvertTo-XMLSecurityOptions -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLSecurityOptions -GPO $GPO -SingleObject
        }
    }
    SoftwareInstallation            = [ordered] @{
        Types      = @(
            @{
                Category = 'SoftwareInstallationSettings'
                Settings = 'MsiApplication'
            }
        )
        GPOPath    = 'Policies -> Software Settings -> Software Installation'
        Code       = {
            ConvertTo-XMLSoftwareInstallation -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLSoftwareInstallation -GPO $GPO -SingleObject
        }
    }
    SystemServices                  = [ordered] @{
        Types       = @(
            @{
                Category = 'SecuritySettings'
                Settings = 'SystemServices'
            }
        )
        Description = ''
        GPOPath     = 'Policies -> Windows Settings -> Security Settings -> System Services'
        Code        = {
            ConvertTo-XMLSystemServices -GPO $GPO
        }
        CodeSingle  = {
            ConvertTo-XMLSystemServices -GPO $GPO -SingleObject
        }
    }
    SystemServicesNT                = [ordered] @{
        Types       = @(
            @{
                Category = 'ServiceSettings'
                Settings = 'NTServices'
            }
        )
        Description = ''
        GPOPath     = 'Preferences -> Control Pannel Settings -> Services'
        Code        = {
            ConvertTo-XMLSystemServicesNT -GPO $GPO
        }
        CodeSingle  = {
            ConvertTo-XMLSystemServicesNT -GPO $GPO -SingleObject
        }
    }
    <#
    SystemServicesNT1       = [ordered] @{
        Types       = @(
            @{
                Category = 'ServiceSettings'
                Settings = 'NTServices'
            }
        )
        Description = ''
        GPOPath     = 'Preferences -> Control Pannel Settings -> Services'
        Code        = {
            ConvertTo-XMLSecuritySettings -GPO $GPO -Category 'NTService'
        }
        CodeSingle  = {
            ConvertTo-XMLSecuritySettings -GPO $GPO -SingleObject
        }
    }
    #>
    TaskScheduler                   = [ordered] @{
        Types       = @(
            @{
                Category = 'ScheduledTasksSettings'
                Settings = 'ScheduledTasks'
            }
        )
        Description = ''
        GPOPath     = 'Preferences -> Control Pannel Settings -> Scheduled Tasks'
        Code        = {
            ConvertTo-XMLTaskScheduler -GPO $GPO
        }
        CodeSingle  = {
            ConvertTo-XMLTaskScheduler -GPO $GPO -SingleObject
        }
    }
    TaskSchedulerPolicies           = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Task Scheduler'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Task Scheduler*'
        }
    }
    <#
    TaskScheduler1           = [ordered] @{
        Types       = @(
            @{
                Category = 'ScheduledTasksSettings'
                Settings = 'ScheduledTasks'
            }
        )
        Description = ''
        GPOPath     = ''
        Code        = {
            ConvertTo-XMLSecuritySettings -GPO $GPO -Category 'TaskV2', 'Task', 'ImmediateTaskV2', 'ImmediateTask'
        }
        CodeSingle  = {
            ConvertTo-XMLTaskScheduler -GPO $GPO -SingleObject
        }
    }
    #>
    WindowsDefender                 = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Windows Defender'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Defender*'
        }
    }
    WindowsHelloForBusiness         = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Windows Hello For Business'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Hello For Business*'
        }
    }
    WindowsInstaller                = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Windows Installer'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Installer*'
        }
    }
    WindowsLogon                    = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Windows Logon Options'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Logon Options*'
        }
    }
    WindowsMediaPlayer              = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Windows Media Player'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Media Player*'
        }
    }
    WindowsMessenger                = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Windows Messenger'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Messenger*'
        }
    }
    WindowsPowerShell               = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Windows PowerShell'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows PowerShell*'
        }
    }
    WindowsRemoteManagement         = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = 'Policies -> Administrative Templates -> Windows Components/Windows Remote Management (WinRM)'
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Remote Management (WinRM)*'
        }
    }
    WindowsUpdate                   = @{
        Types   = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath = @(
            'Policies -> Administrative Templates -> Windows Components/Windows Update'
            #'Policies -> Administrative Templates -> Windows Components/Delivery Optimization'
        )
        Code    = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Update*', 'Windows Components/Delivery Optimization*'
        }
    }
}