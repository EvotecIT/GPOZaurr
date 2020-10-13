$Script:GPODitionary = [ordered] @{
    AccountPolicies                   = [ordered] @{
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
            ConvertTo-XMLAccountPolicy -GPO $GPO -SingleObject
        }
    }
    Audit                             = [ordered] @{
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
            ConvertTo-XMLAudit -GPO $GPO -SingleObject
        }
    }
    Autologon                         = [ordered] @{
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
    AutoPlay                          = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/AutoPlay Policies'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/AutoPlay Policies*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/AutoPlay Policies*' -SingleObject
        }
    }
    Biometrics                        = @{
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
    Bitlocker                         = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/BitLocker Drive Encryption'
        Code       = {
            #ConvertTo-XMLBitlocker -GPO $GPO
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/BitLocker Drive Encryption*'
        }
        CodeSingle = {
            #ConvertTo-XMLBitlocker -GPO $GPO
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/BitLocker Drive Encryption*' -SingleObject
        }
    }
    ControlPanel                      = [ordered]@{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Controol Panel'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel' -SingleObject
        }
    }
    ControlPanelAddRemove             = [ordered]@{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Control Panel/Add or Remove Programs'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Add or Remove Programs'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Add or Remove Programs' -SingleObject
        }
    }
    ControlPanelDisplay               = [ordered]@{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Control Panel/Display'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Display'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Display' -SingleObject
        }
    }
    ControlPanelPersonalization       = [ordered]@{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Control Panel/Personalization'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Personalization'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Personalization' -SingleObject
        }
    }
    ControlPanelPrinters              = [ordered]@{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Control Panel/Printers'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Printers'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Printers' -SingleObject
        }
    }
    ControlPanelPrograms              = [ordered]@{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Control Panel/Programs'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Programs'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Programs' -SingleObject
        }
    }
    ControlPanelRegional              = [ordered]@{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Control Panel/Regional and Language Options'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Regional and Language Options'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Control Panel/Regional and Language Options' -SingleObject
        }
    }
    CredentialsDelegation             = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> System/Credentials Delegation'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Credentials Delegation*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Credentials Delegation*' -SingleObject
        }
    }
    CustomInternationalSettings       = [ordered]@{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Custom International Settings'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Custom International Settings*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Custom International Settings*' -SingleObject
        }
    }
    Desktop                           = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Desktop'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Desktop*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Desktop*' -SingleObject
        }
    }
    DnsClient                         = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Network/DNS Client'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Network/DNS Client*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Network/DNS Client*' -SingleObject
        }
    }
    DriveMapping                      = [ordered] @{
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
    EventLog                          = [ordered] @{
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
    EventForwarding                   = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Event Forwarding'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Event Forwarding*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Event Forwarding*' -SingleObject
        }
    }
    EventLogService                   = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Event Log Service'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Event Log Service*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Event Log Service*' -SingleObject
        }
    }
    FileExplorer                      = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/File Explorer'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/File Explorer*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/File Explorer*' -SingleObject
        }
    }
    FolderRedirection                 = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> System/Folder Redirection'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Folder Redirection'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Folder Redirection' -SingleObject
        }
    }
    FSLogix                           = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> FSLogix'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'FSLogix'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'FSLogix' -SingleObject
        }
    }
    GoogleChrome                      = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = @(
            'Policies -> Administrative Templates -> Google Chrome'
            'Policies -> Administrative Templates -> Google/Google Chrome'
            'Policies -> Administrative Templates -> Google Chrome - Default Settings (users can override)'
        )
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Google Chrome', 'Google/Google Chrome', 'Google Chrome - Default Settings (users can override)'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Google Chrome', 'Google/Google Chrome', 'Google Chrome - Default Settings (users can override)' -SingleObject
        }
    }
    GroupPolicy                       = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> System/Group Policy'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Group Policy*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Group Policy*' -SingleObject
        }
    }
    InternetCommunicationManagement   = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> System/Internet Communication Management'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Internet Communication Management*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Internet Communication Management*' -SingleObject
        }
    }
    InternetExplorer                  = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Internet Explorer'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Internet Explorer*', 'Composants Windows/Celle Internet Explorer'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Internet Explorer*', 'Composants Windows/Celle Internet Explorer' -SingleObject
        }
    }
    InternetExplorerZones             = [ordered] @{
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
    KDC                               = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> System/KDC'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/KDC'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/KDC' -SingleObject
        }
    }
    LAPS                              = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> LAPS'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'LAPS'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'LAPS' -SingleObject
        }
    }
    Lithnet                           = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Lithnet/Password Protection for Active Directory'
        Code       = {
            #ConvertTo-XMLLithnetFilter -GPO $GPO
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Lithnet/Password Protection for Active Directory*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Lithnet/Password Protection for Active Directory*' -SingleObject
        }
    }
    LocalUsers                        = [ordered] @{
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
    LocalGroups                       = [ordered] @{
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
    Logon                             = @{
        Types      = @(
            @{ Category = 'RegistrySettings'; Settings = 'Policy' }
        )
        GPOPath    = 'Policies -> Administrative Templates -> System/Logon'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Logon*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Logon*' -SingleObject
        }
    }
    MicrosoftOutlook2002              = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Microsoft Outlook 2002'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2002*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2002*' -SingleObject
        }
    }
    MicrosoftEdge                     = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = @(
            'Policies -> Administrative Templates -> Microsoft Edge'
            'Policies -> Administrative Templates -> Windows Components/Edge UI'
            'Policies -> Administrative Templates -> Windows Components/Microsoft Edge'
        )
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Edge*', 'Windows Components/Microsoft Edge', 'Windows Components/Edge UI'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Edge*', 'Windows Components/Microsoft Edge', 'Windows Components/Edge UI' -SingleObject
        }
    }
    MicrosoftOutlook2003              = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = @(
            'Policies -> Administrative Templates -> Microsoft Office Outlook 2003'
            'Policies -> Administrative Templates -> Outlook 2003 RPC Encryption'
        )
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Office Outlook 2003*', 'Outlook 2003 RPC Encryption'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Office Outlook 2003*', 'Outlook 2003 RPC Encryption' -SingleObject
        }
    }
    MicrosoftOutlook2010              = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Microsoft Outlook 2010'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2010*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2010*' -SingleObject
        }
    }
    MicrosoftOutlook2013              = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Microsoft Outlook 2013'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2013*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2013*' -SingleObject
        }
    }
    MicrosoftOutlook2016              = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Microsoft Outlook 2016'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2016*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Microsoft Outlook 2016*' -SingleObject
        }
    }
    MicrosoftManagementConsole        = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Microsoft Management Console'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Microsoft Management Console*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Microsoft Management Console*' -SingleObject
        }
    }
    NetMeeting                        = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/NetMeeting'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/NetMeeting*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/NetMeeting*' -SingleObject
        }
    }
    MSSLegacy                         = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> MSS (Legacy)'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'MSS (Legacy)'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'MSS (Legacy)' -SingleObject
        }
    }
    MSSecurityGuide                   = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> MS Security Guide'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'MS Security Guide'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'MS Security Guide' -SingleObject
        }
    }
    OneDrive                          = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/OneDrive'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/OneDrive*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/OneDrive*' -SingleObject
        }
    }
    Policies                          = @{
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
    Printers                          = @{
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
    PrintersPolicies                  = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = @(
            'Policies -> Administrative Templates -> Printers'
            'Policies -> Administrative Templates -> Control Panel/Printers'
        )
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Printers*', 'Control Panel/Printers*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Printers*', 'Control Panel/Printers*' -SingleObject
        }
    }
    PublicKeyPoliciesCertificates     = [ordered] @{
        Types      = @(
            @{
                Category = 'PublicKeySettings'
                Settings = 'RootCertificate'
            }
            @{
                Category = 'PublicKeySettings'
                Settings = 'IntermediateCACertificate'
            }
            @{
                Category = 'PublicKeySettings'
                Settings = 'TrustedPeopleCertificate'
            }
            @{
                Category = 'PublicKeySettings'
                Settings = 'UntrustedCertificate'
            }
        )
        GPOPath    = 'Policies -> Windows Settings -> Security Settings -> Public Key Policies'
        Code       = {
            ConvertTo-XMLGenericPublicKey -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLGenericPublicKey -GPO $GPO -SingleObject
        }
    }
    <#
    PublicKeyPoliciesAll              = [ordered] @{
        Types      = @(
            @{
                Category = 'PublicKeySettings'
                Settings = 'AutoEnrollmentSettings'
            }
            @{
                Category = 'PublicKeySettings'
                Settings = 'EFSSettings'
            }
            @{
                Category = 'PublicKeySettings'
                Settings = 'RootCertificateSettings'
            }
        )
        GPOPath    = 'Policies -> Windows Settings -> Security Settings -> Public Key Policies'
        Code       = {
            ConvertTo-XMLGenericPublicKey -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLGenericPublicKey -GPO $GPO -SingleObject
        }
    }
    #>
    PublicKeyPoliciesAutoEnrollment   = [ordered] @{
        Types      = @(
            @{
                Category = 'PublicKeySettings'
                Settings = 'AutoEnrollmentSettings'
            }
        )
        GPOPath    = 'Policies -> Windows Settings -> Security Settings -> Public Key Policies'
        Code       = {
            ConvertTo-XMLGenericPublicKey -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLGenericPublicKey -GPO $GPO -SingleObject
        }
    }
    PublicKeyPoliciesEFS              = [ordered] @{
        Types      = @(
            @{
                Category = 'PublicKeySettings'
                Settings = 'EFSSettings'
            }
        )
        GPOPath    = 'Policies -> Windows Settings -> Security Settings -> Public Key Policies'
        Code       = {
            ConvertTo-XMLGenericPublicKey -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLGenericPublicKey -GPO $GPO -SingleObject
        }
    }
    PublicKeyPoliciesRootCA           = [ordered] @{
        Types      = @(
            @{
                Category = 'PublicKeySettings'
                Settings = 'RootCertificateSettings'
            }
        )
        GPOPath    = 'Policies -> Windows Settings -> Security Settings -> Public Key Policies'
        Code       = {
            ConvertTo-XMLGenericPublicKey -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLGenericPublicKey -GPO $GPO -SingleObject
        }
    }
    PublicKeyPoliciesEnrollmentPolicy = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = @(
            'Policies -> Windows Settings -> Security Settings -> Public Key Policies'
        )
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Internet Communication Management*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Internet Communication Management*' -SingleObject
        }
    }
    RegistrySetting                   = [ordered] @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'RegistrySetting'
            }
        )
        GPOPath    = "Mixed - missing ADMX?"
        Code       = {
            ConvertTo-XMLGenericPublicKey -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLGenericPublicKey -GPO $GPO -SingleObject
        }
    }
    RegistrySettings                  = [ordered] @{
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
    OnlineAssistance                  = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Online Assistance'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Online Assistance*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Online Assistance*' -SingleObject
        }
    }
    RemoteAssistance                  = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> System/Remote Assistance'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Remote Assistance*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'System/Remote Assistance*' -SingleObject
        }
    }
    RemoteDesktopServices             = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Remote Desktop Services'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Remote Desktop Services*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Remote Desktop Services*' -SingleObject
        }
    }
    RSSFeeds                          = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/RSS Feeds'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/RSS Feeds*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/RSS Feeds*' -SingleObject
        }
    }
    Scripts                           = [ordered] @{
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
    SecurityOptions                   = [ordered] @{
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
    SoftwareInstallation              = [ordered] @{
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
    SystemServices                    = [ordered] @{
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
    SystemServicesNT                  = [ordered] @{
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
    TaskScheduler                     = [ordered] @{
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
    TaskSchedulerPolicies             = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Task Scheduler'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Task Scheduler*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Task Scheduler*' -SingleObject
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
    UserRightsAssignment              = [ordered] @{
        Types      = @(
            @{
                Category = 'SecuritySettings'
                Settings = 'UserRightsAssignment'
            }
        )
        GPOPath    = 'Policies -> Windows Settings -> Security Settings -> Local Policies -> User Rights Assignment'
        Code       = {
            ConvertTo-XMLUserRightsAssignment -GPO $GPO
        }
        CodeSingle = {
            ConvertTo-XMLUserRightsAssignment -GPO $GPO -SingleObject
        }
    }
    WindowsDefender                   = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Windows Defender'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Defender*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Defender*' -SingleObject
        }
    }
    WindowsDefenderExploitGuard       = @{
        # this needs improvements because of DropDownList
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Microsoft Defender Antivirus/Microsoft Defender Exploit Guard'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Microsoft Defender Antivirus/Microsoft Defender Exploit Guard*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Microsoft Defender Antivirus/Microsoft Defender Exploit Guard*' -SingleObject
        }
    }
    WindowsHelloForBusiness           = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Windows Hello For Business'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Hello For Business*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Hello For Business*' -SingleObject
        }
    }
    WindowsInstaller                  = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Windows Installer'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Installer*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Installer*' -SingleObject
        }
    }
    WindowsLogon                      = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Windows Logon Options'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Logon Options*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Logon Options*' -SingleObject
        }
    }
    WindowsMediaPlayer                = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Windows Media Player'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Media Player*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Media Player*' -SingleObject
        }
    }
    WindowsMessenger                  = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Windows Messenger'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Messenger*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Messenger*' -SingleObject
        }
    }
    WindowsPowerShell                 = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Windows PowerShell'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows PowerShell*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows PowerShell*' -SingleObject
        }
    }
    WindowsRemoteManagement           = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = 'Policies -> Administrative Templates -> Windows Components/Windows Remote Management (WinRM)'
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Remote Management (WinRM)*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Remote Management (WinRM)*' -SingleObject
        }
    }
    WindowsUpdate                     = @{
        Types      = @(
            @{
                Category = 'RegistrySettings'
                Settings = 'Policy'
            }
        )
        GPOPath    = @(
            'Policies -> Administrative Templates -> Windows Components/Windows Update'
            #'Policies -> Administrative Templates -> Windows Components/Delivery Optimization'
        )
        Code       = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Update*', 'Windows Components/Delivery Optimization*'
        }
        CodeSingle = {
            ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'Windows Components/Windows Update*', 'Windows Components/Delivery Optimization*' -SingleObject
        }
    }
}