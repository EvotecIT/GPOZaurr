function Skip-GroupPolicy {
    <#
    .SYNOPSIS
    Used within ScriptBlocks only. Allows to exclude Group Policy from being affected by fixes

    .DESCRIPTION
    Used within ScriptBlocks only. Allows to exclude Group Policy from being affected by fixes. Only some commands support it. The goal is to support all cmdlets.

    .PARAMETER Name
    Define Group Policy Name to skip

    .PARAMETER DomaiName
    Define DomainName where Group Policy is located. Otherwise each domain will be checked and skipped if found with same name.

    .EXAMPLE
    Optimize-GPOZaurr -All -WhatIf -Verbose -LimitProcessing 2 {
        Skip-GroupPolicy -Name 'TEST | Drive Mapping 1'
        Skip-GroupPolicy -Name 'TEST | Drive Mapping 2'
    }

    .EXAMPLE
    Remove-GPOZaurr -Type Empty, Unlinked -BackupPath "$Env:UserProfile\Desktop\GPO" -BackupDated -LimitProcessing 2 -Verbose -WhatIf {
        Skip-GroupPolicy -Name 'TEST | Drive Mapping 1'
        Skip-GroupPolicy -Name 'TEST | Drive Mapping 2' -DomaiName 'ad.evotec.pl'
    }

    .NOTES
    General notes
    #>
    [cmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        #[ValidateSet('GPOList')][string] $Type,
        [parameter(ParameterSetName = 'Name')][alias('GpoName', 'DisplayName')][string] $Name,
        [parameter(ParameterSetName = 'Guid')]
        [alias('ID')][string] $GUID,
        [parameter(ParameterSetName = 'Name')]
        [parameter(ParameterSetName = 'Guid')]
        [string] $DomaiName
    )
    $Output = @{
        Name       = $Name
        ID         = $GUID
        DomainName = $DomaiName
    }
    Remove-EmptyValue -Hashtable $Output
    [PSCustomObject] $Output
}