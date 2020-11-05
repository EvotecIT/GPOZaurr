$Script:GPOConfiguration = [ordered] @{
    GPOOrphans          = $GPOZaurrOrphans
    GPOOwners           = $GPOZaurrOwners
    GPOConsistency      = $GPOZaurrConsistency
    GPODuplicates       = $GPOZaurrDuplicates
    GPOList             = $GPOZaurrList
    GPOPassword         = $GPOZaurrPassword
    GPOPermissions      = $GPOZaurrPermissions
    GPOPermissionsRoot  = $GPOZaurrPermissionsRoot
    GPOFiles            = $GPOZaurrFiles
    GPOAnalysis         = $GPOZaurrAnalysis
    NetLogonPermissions = $GPOZaurrNetLogonPermissions
    SysVolLegacyFiles   = $GPOZaurrSysVolLegacyFiles
}