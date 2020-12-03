@{
    AliasesToExport      = @('Get-GPOZaurrSysvol', 'Get-GPOZaurrFilesPolicyDefinitions', 'Show-GPOZaurr', 'Show-GPO', 'Find-GPO', 'Remove-GPOZaurrOrphaned')
    Author               = 'Przemyslaw Klys'
    CmdletsToExport      = @()
    CompanyName          = 'Evotec'
    CompatiblePSEditions = @('Desktop')
    Copyright            = '(c) 2011 - 2020 Przemyslaw Klys @ Evotec. All rights reserved.'
    Description          = 'Group Policy Eater is a PowerShell module that aims to gather information about Group Policies but also allows fixing issues that you may find in them.'
    FunctionsToExport    = @('Add-GPOPermission', 'Add-GPOZaurrPermission', 'Backup-GPOZaurr', 'Clear-GPOZaurrSysvolDFSR', 'ConvertFrom-CSExtension', 'Find-CSExtension', 'Get-GPOZaurr', 'Get-GPOZaurrAD', 'Get-GPOZaurrBackupInformation', 'Get-GPOZaurrBroken', 'Get-GPOZaurrDictionary', 'Get-GPOZaurrDuplicateObject', 'Get-GPOZaurrFiles', 'Get-GPOZaurrFilesPolicyDefinition', 'Get-GPOZaurrFolders', 'Get-GPOZaurrInheritance', 'Get-GPOZaurrLegacyFiles', 'Get-GPOZaurrLink', 'Get-GPOZaurrLinkSummary', 'Get-GPOZaurrNetLogon', 'Get-GPOZaurrOwner', 'Get-GPOZaurrPassword', 'Get-GPOZaurrPermission', 'Get-GPOZaurrPermissionConsistency', 'Get-GPOZaurrPermissionIssue', 'Get-GPOZaurrPermissionRoot', 'Get-GPOZaurrPermissionSummary', 'Get-GPOZaurrSysvolDFSR', 'Get-GPOZaurrWMI', 'Invoke-GPOZaurr', 'Invoke-GPOZaurrContent', 'Invoke-GPOZaurrPermission', 'Invoke-GPOZaurrSupport', 'New-GPOZaurrWMI', 'Optimize-GPOZaurr', 'Remove-GPOPermission', 'Remove-GPOZaurr', 'Remove-GPOZaurrBroken', 'Remove-GPOZaurrDuplicateObject', 'Remove-GPOZaurrFolders', 'Remove-GPOZaurrLegacyFiles', 'Remove-GPOZaurrPermission', 'Remove-GPOZaurrWMI', 'Repair-GPOZaurrNetLogonOwner', 'Repair-GPOZaurrPermissionConsistency', 'Restore-GPOZaurr', 'Save-GPOZaurrFiles', 'Set-GPOOwner', 'Set-GPOZaurrOwner', 'Skip-GroupPolicy')
    GUID                 = 'f7d4c9e4-0298-4f51-ad77-e8e3febebbde'
    ModuleVersion        = '0.0.94'
    PowerShellVersion    = '5.1'
    PrivateData          = @{
        PSData = @{
            Tags                       = @('Windows', 'ActiveDirectory', 'GPO', 'GroupPolicy')
            ProjectUri                 = 'https://github.com/EvotecIT/GPOZaurr'
            ExternalModuleDependencies = @('CimCmdlets', 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility', 'Microsoft.PowerShell.Security')
        }
    }
    RequiredModules      = @(@{
            ModuleVersion = '0.0.189'
            ModuleName    = 'PSSharedGoods'
            Guid          = 'ee272aa8-baaa-4edf-9f45-b6d6f7d844fe'
        }, @{
            ModuleVersion = '0.0.103'
            ModuleName    = 'ADEssentials'
            Guid          = '9fc9fd61-7f11-4f4b-a527-084086f1905f'
        }, @{
            ModuleVersion = '0.0.122'
            ModuleName    = 'PSWriteHTML'
            Guid          = 'a7bdf640-f5cb-4acf-9de0-365b322d245c'
        }, 'CimCmdlets', 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility', 'Microsoft.PowerShell.Security')
    RootModule           = 'GPOZaurr.psm1'
}