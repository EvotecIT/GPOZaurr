@{
    AliasesToExport      = ''
    Author               = 'Przemyslaw Klys'
    CompanyName          = 'Evotec'
    CompatiblePSEditions = 'Desktop'
    Copyright            = '(c) 2011 - 2020 Przemyslaw Klys @ Evotec. All rights reserved.'
    Description          = 'Group Policy Eater'
    FunctionsToExport    = 'Backup-GPOZaurr', 'Get-GPOZaurr', 'Get-GPOZaurrBackupInformation', 'Get-GPOZaurrPassword', 'Remove-GPOZaurr', 'Restore-GPOZaurr', 'Save-GPOZaurrFiles'
    GUID                 = 'f7d4c9e4-0298-4f51-ad77-e8e3febebbde'
    ModuleVersion        = '0.0.4'
    PowerShellVersion    = '5.1'
    PrivateData          = @{
        PSData = @{
            Tags                       = 'Windows', 'ActiveDirectory', 'GPO'
            ProjectUri                 = 'https://github.com/EvotecIT/GPOZaurr'
            ExternalModuleDependencies = 'ActiveDirectory', 'GroupPolicy'
        }
    }
    RequiredModules      = @{
        ModuleVersion = '0.0.132'
        ModuleName    = 'PSSharedGoods'
        Guid          = 'ee272aa8-baaa-4edf-9f45-b6d6f7d844fe'
    }, 'ActiveDirectory', 'GroupPolicy'
    RootModule           = 'GPOZaurr.psm1'
}