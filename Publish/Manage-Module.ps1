Clear-Host
Import-Module "C:\Users\przemyslaw.klys\OneDrive - Evotec\Support\GitHub\PSPublishModule\PSPublishModule.psd1" -Force

$Configuration = @{
    Information = @{
        ModuleName        = 'GPOZaurr'
        DirectoryProjects = 'C:\Support\GitHub'

        FunctionsToExport = 'Public'
        AliasesToExport   = 'Public'

        Manifest          = @{
            # Version number of this module.
            ModuleVersion              = '0.0.X'
            # Supported PSEditions
            CompatiblePSEditions       = @('Desktop')
            # ID used to uniquely identify this module
            GUID                       = 'f7d4c9e4-0298-4f51-ad77-e8e3febebbde'
            # Author of this module
            Author                     = 'Przemyslaw Klys'
            # Company or vendor of this module
            CompanyName                = 'Evotec'
            # Copyright statement for this module
            Copyright                  = "(c) 2011 - $((Get-Date).Year) Przemyslaw Klys @ Evotec. All rights reserved."
            # Description of the functionality provided by this module
            Description                = 'Group Policy Eater is a PowerShell module that aims to gather information about Group Policies but also allows fixing issues that you may find in them.'
            # Minimum version of the Windows PowerShell engine required by this module
            PowerShellVersion          = '5.1'
            # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
            Tags                       = @('Windows', 'ActiveDirectory', 'GPO', 'GroupPolicy')
            #IconUri              = 'https://evotec.xyz/wp-content/uploads/2019/02/PSPublishModule.png'

            ProjectUri                 = 'https://github.com/EvotecIT/GPOZaurr'

            RequiredModules            = @(
                @{ ModuleName = 'PSSharedGoods'; ModuleVersion = 'Latest'; Guid = 'ee272aa8-baaa-4edf-9f45-b6d6f7d844fe' }
                @{ ModuleName = 'ADEssentials'; ModuleVersion = 'Latest'; Guid = '9fc9fd61-7f11-4f4b-a527-084086f1905f' }
                @{ ModuleName = 'PSWriteHTML'; ModuleVersion = "Latest"; Guid = 'a7bdf640-f5cb-4acf-9de0-365b322d245c' }
            )
            ExternalModuleDependencies = @(
                #"ActiveDirectory"
                #"GroupPolicy"
                "CimCmdlets"
                'Microsoft.PowerShell.Management'
                'Microsoft.PowerShell.Utility'
                'Microsoft.PowerShell.Security'
            )
            CommandModuleDependencies  = @{
                ActiveDirectory = @(
                    'Add-GPOPermission'
                    'Add-GPOZaurrPermission'
                    'Backup-GPOZaurr'
                    'Clear-GPOZaurrSysvolDFSR'
                    'ConvertFrom-CSExtension'
                    'Find-CSExtension'
                    'Get-GPOZaurr'
                    'Get-GPOZaurrAD'
                    'Get-GPOZaurrBackupInformation'
                    'Get-GPOZaurrBroken'
                    'Get-GPOZaurrDictionary'
                    'Get-GPOZaurrDuplicateObject'
                    'Get-GPOZaurrFiles'
                    'Get-GPOZaurrFilesPolicyDefinition'
                    'Get-GPOZaurrFolders'
                    'Get-GPOZaurrInheritance'
                    'Get-GPOZaurrLegacyFiles'
                    'Get-GPOZaurrLink'
                    'Get-GPOZaurrLinkSummary'
                    'Get-GPOZaurrNetLogon'
                    'Get-GPOZaurrOwner'
                    'Get-GPOZaurrPassword'
                    'Get-GPOZaurrPermission'
                    'Get-GPOZaurrPermissionConsistency'
                    'Get-GPOZaurrPermissionRoot'
                    'Get-GPOZaurrPermissionSummary'
                    'Get-GPOZaurrSysvolDFSR'
                    'Get-GPOZaurrWMI'
                    'Invoke-GPOZaurr'
                    #'Invoke-GPOZaurrContent'
                    'Invoke-GPOZaurrPermission'
                    'Invoke-GPOZaurrSupport'
                    'New-GPOZaurrWMI'
                    'Optimize-GPOZaurr'
                    'Remove-GPOPermission'
                    'Remove-GPOZaurr'
                    'Remove-GPOZaurrBroken'
                    'Remove-GPOZaurrDuplicateObject'
                    'Remove-GPOZaurrFolders'
                    'Remove-GPOZaurrLegacyFiles'
                    'Remove-GPOZaurrPermission'
                    'Remove-GPOZaurrWMI'
                    'Repair-GPOZaurrNetLogonOwner'
                    'Repair-GPOZaurrPermissionConsistency'
                    'Restore-GPOZaurr'
                    'Save-GPOZaurrFiles'
                    'Set-GPOOwner'
                    'Set-GPOZaurrOwner'
                    'Find-GPO'
                    'Get-GPOZaurrFilesPolicyDefinitions'
                    'Get-GPOZaurrSysvol'
                    'Remove-GPOZaurrOrphaned'
                    'Show-GPO'
                    'Show-GPOZaurr'
                )
                GroupPolicy     = @(
                    'Add-GPOPermission'
                    'Add-GPOZaurrPermission'
                    'Backup-GPOZaurr'
                    'Clear-GPOZaurrSysvolDFSR'
                    'ConvertFrom-CSExtension'
                    'Find-CSExtension'
                    'Get-GPOZaurr'
                    'Get-GPOZaurrAD'
                    'Get-GPOZaurrBackupInformation'
                    'Get-GPOZaurrBroken'
                    'Get-GPOZaurrDictionary'
                    'Get-GPOZaurrDuplicateObject'
                    'Get-GPOZaurrFiles'
                    'Get-GPOZaurrFilesPolicyDefinition'
                    'Get-GPOZaurrFolders'
                    'Get-GPOZaurrInheritance'
                    'Get-GPOZaurrLegacyFiles'
                    'Get-GPOZaurrLink'
                    'Get-GPOZaurrLinkSummary'
                    'Get-GPOZaurrNetLogon'
                    'Get-GPOZaurrOwner'
                    'Get-GPOZaurrPassword'
                    'Get-GPOZaurrPermission'
                    'Get-GPOZaurrPermissionConsistency'
                    'Get-GPOZaurrPermissionRoot'
                    'Get-GPOZaurrPermissionSummary'
                    'Get-GPOZaurrSysvolDFSR'
                    'Get-GPOZaurrWMI'
                    'Invoke-GPOZaurr'
                    #'Invoke-GPOZaurrContent'
                    'Invoke-GPOZaurrPermission'
                    'Invoke-GPOZaurrSupport'
                    'New-GPOZaurrWMI'
                    'Optimize-GPOZaurr'
                    'Remove-GPOPermission'
                    'Remove-GPOZaurr'
                    'Remove-GPOZaurrBroken'
                    'Remove-GPOZaurrDuplicateObject'
                    'Remove-GPOZaurrFolders'
                    'Remove-GPOZaurrLegacyFiles'
                    'Remove-GPOZaurrPermission'
                    'Remove-GPOZaurrWMI'
                    'Repair-GPOZaurrNetLogonOwner'
                    'Repair-GPOZaurrPermissionConsistency'
                    'Restore-GPOZaurr'
                    'Save-GPOZaurrFiles'
                    'Set-GPOOwner'
                    'Set-GPOZaurrOwner'
                    'Find-GPO'
                    'Get-GPOZaurrFilesPolicyDefinitions'
                    'Get-GPOZaurrSysvol'
                    'Remove-GPOZaurrOrphaned'
                    'Show-GPO'
                    'Show-GPOZaurr'
                )
            }
        }
    }
    Options     = @{
        Merge             = @{
            Sort           = 'None'
            FormatCodePSM1 = @{
                Enabled           = $true
                RemoveComments    = $false
                FormatterSettings = @{
                    IncludeRules = @(
                        'PSPlaceOpenBrace',
                        'PSPlaceCloseBrace',
                        'PSUseConsistentWhitespace',
                        'PSUseConsistentIndentation',
                        'PSAlignAssignmentStatement',
                        'PSUseCorrectCasing'
                    )

                    Rules        = @{
                        PSPlaceOpenBrace           = @{
                            Enable             = $true
                            OnSameLine         = $true
                            NewLineAfter       = $true
                            IgnoreOneLineBlock = $true
                        }

                        PSPlaceCloseBrace          = @{
                            Enable             = $true
                            NewLineAfter       = $false
                            IgnoreOneLineBlock = $true
                            NoEmptyLineBefore  = $false
                        }

                        PSUseConsistentIndentation = @{
                            Enable              = $true
                            Kind                = 'space'
                            PipelineIndentation = 'IncreaseIndentationAfterEveryPipeline'
                            IndentationSize     = 4
                        }

                        PSUseConsistentWhitespace  = @{
                            Enable          = $true
                            CheckInnerBrace = $true
                            CheckOpenBrace  = $true
                            CheckOpenParen  = $true
                            CheckOperator   = $true
                            CheckPipe       = $true
                            CheckSeparator  = $true
                        }

                        PSAlignAssignmentStatement = @{
                            Enable         = $true
                            CheckHashtable = $true
                        }

                        PSUseCorrectCasing         = @{
                            Enable = $true
                        }
                    }
                }
            }
            FormatCodePSD1 = @{
                Enabled        = $true
                RemoveComments = $false
            }
            Integrate      = @{
                ApprovedModules = 'PSSharedGoods', 'PSWriteColor', 'Connectimo', 'PSUnifi', 'PSWebToolbox', 'PSMyPassword', 'ADEssentials'
            }
        }
        Standard          = @{
            FormatCodePSM1 = @{

            }
            FormatCodePSD1 = @{
                Enabled = $true
                #RemoveComments = $true
            }
        }
        PowerShellGallery = @{
            ApiKey   = 'C:\Support\Important\PowerShellGalleryAPI.txt'
            FromFile = $true
        }
        GitHub            = @{
            ApiKey   = 'C:\Support\Important\GithubAPI.txt'
            FromFile = $true
            UserName = 'EvotecIT'
            #RepositoryName = 'PSPublishModule' # not required, uses project name
        }
        Documentation     = @{
            Path       = 'Docs'
            PathReadme = 'Docs\Readme.md'
        }
        Style             = @{
            PSD1 = 'Minimal' # Native
        }
    }
    Steps       = @{
        BuildModule        = @{  # requires Enable to be on to process all of that
            Enable           = $true
            DeleteBefore     = $false
            Merge            = $true
            MergeMissing     = $true
            SignMerged       = $true
            Releases         = $true
            ReleasesUnpacked = $false
            RefreshPSD1Only  = $false
        }
        BuildDocumentation = @{
            Enable        = $false # enables documentation processing
            StartClean    = $true # always starts clean
            UpdateWhenNew = $true # always updates right after new
        }
        ImportModules      = @{
            Self            = $true
            RequiredModules = $false
            Verbose         = $false
        }
        PublishModule      = @{  # requires Enable to be on to process all of that
            Enabled      = $true
            Prerelease   = ''
            RequireForce = $false
            GitHub       = $true
        }
    }
}

New-PrepareModule -Configuration $Configuration