$Script:GPOConfiguration = [ordered] @{
    GPOOrphans          = $GPOZaurrOrphans
    GPOOwners           = $GPOZaurrOwners
    GPOConsistency      = $GPOZaurrConsistency
    GPOList             = $GPOZaurrList
    GPOPermissions      = $GPOZaurrPermissions
    GPOPermissionsRoot  = $GPOZaurrPermissionsRoot
    GPOFiles            = $GPOZaurrFiles
    GPOAnalysis         = $GPOZaurrAnalysis
    NetLogonPermissions = $GPOZaurrNetLogonPermissions
    SysVolLegacyFiles   = $GPOZaurrSysVolLegacyFiles
}