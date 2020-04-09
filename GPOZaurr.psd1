@{
    AliasesToExport      = ''
    Author               = 'Przemyslaw Klys'
    CompanyName          = 'Evotec'
    CompatiblePSEditions = 'Desktop'
    Copyright            = '(c) 2011 - 2020 Przemyslaw Klys @ Evotec. All rights reserved.'
    Description          = 'Group Policy Eater'
    FunctionsToExport    = 'Backup-GPOZaurr', 'Get-GPOZaurr', 'Get-GPOZaurrBackupInformation', 'Get-GPOZaurrPassword', 'Get-GPOZaurrWMI', 'New-GPOZaurrWMI', 'Remove-GPOZaurr', 'Remove-GPOZaurrWMI', 'Restore-GPOZaurr', 'Save-GPOZaurrFiles'
    GUID                 = 'f7d4c9e4-0298-4f51-ad77-e8e3febebbde'
    ModuleVersion        = '0.0.6'
    PowerShellVersion    = '5.1'
    PrivateData          = @{
        PSData = @{
            Tags                       = 'Windows', 'ActiveDirectory', 'GPO'
            ProjectUri                 = 'https://github.com/EvotecIT/GPOZaurr'
            ExternalModuleDependencies = 'ActiveDirectory', 'GroupPolicy', 'CimCmdlets', 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility'
        }
    }
    RequiredModules      = @{
        ModuleVersion = '0.0.134'
        ModuleName    = 'PSSharedGoods'
        Guid          = 'ee272aa8-baaa-4edf-9f45-b6d6f7d844fe'
    }, 'ActiveDirectory', 'GroupPolicy', 'CimCmdlets', 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility'
    RootModule           = 'GPOZaurr.psm1'
}