$Script:GPOConfiguration = [ordered] @{
    GPOOrphans                   = $GPOZaurrOrphans
    GPOOwners                    = $GPOZaurrOwners
    GPOConsistency               = $GPOZaurrConsistency
    GPODuplicates                = $GPOZaurrDuplicates
    GPOList                      = $GPOZaurrList
    GPOPassword                  = $GPOZaurrPassword
    GPOPermissions               = $GPOZaurrPermissions
    GPOPermissionsRead           = $GPOZaurrPermissionsRead
    GPOPermissionsRoot           = $GPOZaurrPermissionsRoot
    GPOPermissionsAdministrative = $GPOZaurrPermissionsAdministrative
    GPOFiles                     = $GPOZaurrFiles
    GPOBlockedInheritance        = $GPOZaurrBlockedInheritance
    GPOAnalysis                  = $GPOZaurrAnalysis
    NetLogonOwners               = $GPOZaurrNetLogonOwners
    NetLogonPermissions          = $GPOZaurrNetLogonPermissions
    SysVolLegacyFiles            = $GPOZaurrSysVolLegacyFiles
}