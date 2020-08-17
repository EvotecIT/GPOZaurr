@{
    AliasesToExport      = 'Get-GPOZaurrFilesPolicyDefinitions', 'Find-GPO'
    Author               = 'Przemyslaw Klys'
    CompanyName          = 'Evotec'
    CompatiblePSEditions = 'Desktop'
    Copyright            = '(c) 2011 - 2020 Przemyslaw Klys @ Evotec. All rights reserved.'
    Description          = 'Group Policy Eater is a PowerShell module that aims to gather information about Group Policies but also allows fixing issues that you may find in them.'
    FunctionsToExport    = 'Add-GPOPermission', 'Add-GPOZaurrPermission', 'Backup-GPOZaurr', 'Clear-GPOZaurrSysvolDFSR', 'ConvertFrom-CSExtension', 'Find-CSExtension', 'Get-GPOZaurr', 'Get-GPOZaurrAD', 'Get-GPOZaurrBackupInformation', 'Get-GPOZaurrDictionary', 'Get-GPOZaurrFiles', 'Get-GPOZaurrFilesPolicyDefinition', 'Get-GPOZaurrFolders', 'Get-GPOZaurrInheritance', 'Get-GPOZaurrLegacyFiles', 'Get-GPOZaurrLink', 'Get-GPOZaurrLinkSummary', 'Get-GPOZaurrOwner', 'Get-GPOZaurrPassword', 'Get-GPOZaurrPermission', 'Get-GPOZaurrPermissionConsistency', 'Get-GPOZaurrSysvol', 'Get-GPOZaurrSysvolDFSR', 'Get-GPOZaurrWMI', 'Invoke-GPOZaurr', 'Invoke-GPOZaurrPermission', 'Invoke-GPOZaurrSupport', 'New-GPOZaurrWMI', 'Remove-GPOPermission', 'Remove-GPOZaurr', 'Remove-GPOZaurrFolders', 'Remove-GPOZaurrLegacyFiles', 'Remove-GPOZaurrOrphanedSysvolFolders', 'Remove-GPOZaurrPermission', 'Remove-GPOZaurrWMI', 'Repair-GPOZaurrPermissionConsistency', 'Restore-GPOZaurr', 'Save-GPOZaurrFiles', 'Set-GPOOwner', 'Set-GPOZaurrOwner'
    GUID                 = 'f7d4c9e4-0298-4f51-ad77-e8e3febebbde'
    ModuleVersion        = '0.0.55'
    PowerShellVersion    = '5.1'
    PrivateData          = @{
        PSData = @{
            Tags                       = 'Windows', 'ActiveDirectory', 'GPO', 'GroupPolicy'
            ProjectUri                 = 'https://github.com/EvotecIT/GPOZaurr'
            ExternalModuleDependencies = 'ActiveDirectory', 'GroupPolicy', 'CimCmdlets', 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility'
        }
    }
    RequiredModules      = @{
        ModuleVersion = '0.0.166'
        ModuleName    = 'PSSharedGoods'
        Guid          = 'ee272aa8-baaa-4edf-9f45-b6d6f7d844fe'
    }, @{
        ModuleVersion = '0.0.66'
        ModuleName    = 'ADEssentials'
        Guid          = '9fc9fd61-7f11-4f4b-a527-084086f1905f'
    }, 'ActiveDirectory', 'GroupPolicy', 'CimCmdlets', 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility'
    RootModule           = 'GPOZaurr.psm1'
}