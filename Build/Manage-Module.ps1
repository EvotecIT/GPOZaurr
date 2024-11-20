Clear-Host

Invoke-ModuleBuild -ModuleName 'GPOZaurr' {
    # Usual defaults as per standard module
    $Manifest = @{
        # Version number of this module.
        ModuleVersion        = '1.1.X'
        # Supported PSEditions
        CompatiblePSEditions = @('Desktop')
        # ID used to uniquely identify this module
        GUID                 = 'f7d4c9e4-0298-4f51-ad77-e8e3febebbde'
        # Author of this module
        Author               = 'Przemyslaw Klys'
        # Company or vendor of this module
        CompanyName          = 'Evotec'
        # Copyright statement for this module
        Copyright            = "(c) 2011 - $((Get-Date).Year) Przemyslaw Klys @ Evotec. All rights reserved."
        # Description of the functionality provided by this module
        Description          = 'Group Policy Eater is a PowerShell module that aims to gather information about Group Policies but also allows fixing issues that you may find in them.'
        # Minimum version of the Windows PowerShell engine required by this module
        PowerShellVersion    = '5.1'
        # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
        Tags                 = @('Windows', 'ActiveDirectory', 'GPO', 'GroupPolicy')
        #IconUri              = 'https://evotec.xyz/wp-content/uploads/2019/02/PSPublishModule.png'

        ProjectUri           = 'https://github.com/EvotecIT/GPOZaurr'
    }
    New-ConfigurationManifest @Manifest

    New-ConfigurationModule -Type RequiredModule -Name 'PSWriteColor', 'PSSharedGoods', 'ADEssentials', 'PSWriteHTML' -Guid Auto -Version Latest
    #New-ConfigurationModule -Type ExternalModule -Name 'Microsoft.PowerShell.Utility', 'Microsoft.PowerShell.Management','Microsoft.PowerShell.Security'
    New-ConfigurationModule -Type ApprovedModule -Name 'PSSharedGoods', 'PSWriteColor', 'Connectimo', 'PSUnifi', 'PSWebToolbox', 'PSMyPassword', 'ADEssentials'

    New-ConfigurationModule -Type ExternalModule -Name @(
        "CimCmdlets"
        'Microsoft.PowerShell.Management'
        'Microsoft.PowerShell.Utility'
        'Microsoft.PowerShell.Security'
    )

    New-ConfigurationModuleSkip -IgnoreModuleName @(
        # this are builtin into PowerShell, so not critical
        'powershellget'
        'GroupPolicy'
        'ScheduledTasks'
        'ActiveDirectory'
        'Microsoft.WSMan.Management'
        'NetConnection'
        'NetSecurity'
        'NetTCPIP'
    ) -IgnoreFunctionName @(
        'Select-Unique'
    )

    New-ConfigurationCommand -ModuleName 'ActiveDirectory' -CommandName @(
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
    New-ConfigurationCommand -ModuleName 'GroupPolicy' -CommandName @(
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


    $ConfigurationFormat = [ordered] @{
        RemoveComments                              = $true
        RemoveEmptyLines                            = $true

        PlaceOpenBraceEnable                        = $true
        PlaceOpenBraceOnSameLine                    = $true
        PlaceOpenBraceNewLineAfter                  = $true
        PlaceOpenBraceIgnoreOneLineBlock            = $false

        PlaceCloseBraceEnable                       = $true
        PlaceCloseBraceNewLineAfter                 = $true
        PlaceCloseBraceIgnoreOneLineBlock           = $false
        PlaceCloseBraceNoEmptyLineBefore            = $true

        UseConsistentIndentationEnable              = $true
        UseConsistentIndentationKind                = 'space'
        UseConsistentIndentationPipelineIndentation = 'IncreaseIndentationAfterEveryPipeline'
        UseConsistentIndentationIndentationSize     = 4

        UseConsistentWhitespaceEnable               = $true
        UseConsistentWhitespaceCheckInnerBrace      = $true
        UseConsistentWhitespaceCheckOpenBrace       = $true
        UseConsistentWhitespaceCheckOpenParen       = $true
        UseConsistentWhitespaceCheckOperator        = $true
        UseConsistentWhitespaceCheckPipe            = $true
        UseConsistentWhitespaceCheckSeparator       = $true

        AlignAssignmentStatementEnable              = $true
        AlignAssignmentStatementCheckHashtable      = $true

        UseCorrectCasingEnable                      = $true
    }
    # format PSD1 and PSM1 files when merging into a single file
    # enable formatting is not required as Configuration is provided
    New-ConfigurationFormat -ApplyTo 'OnMergePSM1', 'OnMergePSD1' -Sort None @ConfigurationFormat
    # format PSD1 and PSM1 files within the module
    # enable formatting is required to make sure that formatting is applied (with default settings)
    New-ConfigurationFormat -ApplyTo 'DefaultPSD1', 'DefaultPSM1' -EnableFormatting -Sort None
    # when creating PSD1 use special style without comments and with only required parameters
    New-ConfigurationFormat -ApplyTo 'DefaultPSD1', 'OnMergePSD1' -PSD1Style 'Minimal'
    # configuration for documentation, at the same time it enables documentation processing
    New-ConfigurationDocumentation -Enable:$false -StartClean -UpdateWhenNew -PathReadme 'Docs\Readme.md' -Path 'Docs'

    New-ConfigurationImportModule -ImportSelf

    New-ConfigurationBuild -Enable:$true -SignModule -MergeModuleOnBuild -MergeFunctionsFromApprovedModules -CertificateThumbprint '483292C9E317AA13B07BB7A96AE9D1A5ED9E7703'

    # New-ConfigurationTest -TestsPath "$PSScriptRoot\..\Tests" -Enable

    New-ConfigurationArtefact -Type Unpacked -Enable -Path "$PSScriptRoot\..\Artefacts\Unpacked" -AddRequiredModules
    New-ConfigurationArtefact -Type Packed -Enable -Path "$PSScriptRoot\..\Artefacts\Packed" -ArtefactName '<ModuleName>.v<ModuleVersion>.zip' -AddRequiredModules

    # options for publishing to github/psgallery
    #New-ConfigurationPublish -Type PowerShellGallery -FilePath 'C:\Support\Important\PowerShellGalleryAPI.txt' -Enabled:$true
    #New-ConfigurationPublish -Type GitHub -FilePath 'C:\Support\Important\GitHubAPI.txt' -UserName 'EvotecIT' -Enabled:$true
} -ExitCode