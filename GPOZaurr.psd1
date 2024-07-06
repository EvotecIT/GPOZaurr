@{
    AliasesToExport      = @('Get-GPOZaurrSysvol', 'Get-GPOZaurrFilesPolicyDefinitions', 'Show-GPOZaurr', 'Show-GPO', 'Find-GPO', 'Remove-GPOZaurrOrphaned')
    Author               = 'Przemyslaw Klys'
    CmdletsToExport      = @()
    CompanyName          = 'Evotec'
    CompatiblePSEditions = @('Desktop')
    Copyright            = '(c) 2011 - 2024 Przemyslaw Klys @ Evotec. All rights reserved.'
    Description          = 'Group Policy Eater is a PowerShell module that aims to gather information about Group Policies but also allows fixing issues that you may find in them.'
    FunctionsToExport    = @('Add-GPOPermission', 'Add-GPOZaurrPermission', 'Backup-GPOZaurr', 'Clear-GPOZaurrSysvolDFSR', 'ConvertFrom-CSExtension', 'Export-GPOZaurrContent', 'Find-CSExtension', 'Get-GPOZaurr', 'Get-GPOZaurrAD', 'Get-GPOZaurrBackupInformation', 'Get-GPOZaurrBroken', 'Get-GPOZaurrBrokenLink', 'Get-GPOZaurrDictionary', 'Get-GPOZaurrDuplicateObject', 'Get-GPOZaurrFiles', 'Get-GPOZaurrFilesPolicyDefinition', 'Get-GPOZaurrFolders', 'Get-GPOZaurrInheritance', 'Get-GPOZaurrLegacyFiles', 'Get-GPOZaurrLink', 'Get-GPOZaurrLinkSummary', 'Get-GPOZaurrMissingFiles', 'Get-GPOZaurrNetLogon', 'Get-GPOZaurrOrganizationalUnit', 'Get-GPOZaurrOwner', 'Get-GPOZaurrPassword', 'Get-GPOZaurrPermission', 'Get-GPOZaurrPermissionAnalysis', 'Get-GPOZaurrPermissionConsistency', 'Get-GPOZaurrPermissionIssue', 'Get-GPOZaurrPermissionRoot', 'Get-GPOZaurrPermissionSummary', 'Get-GPOZaurrRedirect', 'Get-GPOZaurrSysvolDFSR', 'Get-GPOZaurrUpdates', 'Get-GPOZaurrWMI', 'Invoke-GPOZaurr', 'Invoke-GPOZaurrContent', 'Invoke-GPOZaurrPermission', 'Invoke-GPOZaurrSupport', 'New-GPOZaurrWMI', 'Optimize-GPOZaurr', 'Remove-GPOPermission', 'Remove-GPOZaurr', 'Remove-GPOZaurrBroken', 'Remove-GPOZaurrDuplicateObject', 'Remove-GPOZaurrFolders', 'Remove-GPOZaurrLegacyFiles', 'Remove-GPOZaurrLinkEmptyOU', 'Remove-GPOZaurrPermission', 'Remove-GPOZaurrWMI', 'Repair-GPOZaurrBrokenLink', 'Repair-GPOZaurrNetLogonOwner', 'Repair-GPOZaurrPermission', 'Repair-GPOZaurrPermissionConsistency', 'Restore-GPOZaurr', 'Save-GPOZaurrFiles', 'Set-GPOOwner', 'Set-GPOZaurrOwner', 'Set-GPOZaurrStatus', 'Skip-GroupPolicy')
    GUID                 = 'f7d4c9e4-0298-4f51-ad77-e8e3febebbde'
    ModuleVersion        = '1.1.5'
    PowerShellVersion    = '5.1'
    PrivateData          = @{
        PSData = @{
            ExternalModuleDependencies = @('CimCmdlets', 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility', 'Microsoft.PowerShell.Security')
            ProjectUri                 = 'https://github.com/EvotecIT/GPOZaurr'
            Tags                       = @('Windows', 'ActiveDirectory', 'GPO', 'GroupPolicy')
        }
    }
    RequiredModules      = @(@{
            Guid          = '0b0ba5c5-ec85-4c2b-a718-874e55a8bc3f'
            ModuleName    = 'PSWriteColor'
            ModuleVersion = '1.0.1'
        }, @{
            Guid          = 'ee272aa8-baaa-4edf-9f45-b6d6f7d844fe'
            ModuleName    = 'PSSharedGoods'
            ModuleVersion = '0.0.294'
        }, @{
            Guid          = '9fc9fd61-7f11-4f4b-a527-084086f1905f'
            ModuleName    = 'ADEssentials'
            ModuleVersion = '0.0.216'
        }, @{
            Guid          = 'a7bdf640-f5cb-4acf-9de0-365b322d245c'
            ModuleName    = 'PSWriteHTML'
            ModuleVersion = '1.26.0'
        }, 'CimCmdlets', 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility', 'Microsoft.PowerShell.Security')
    RootModule           = 'GPOZaurr.psm1'
}