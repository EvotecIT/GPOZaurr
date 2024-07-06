function Clear-GPOZaurrSysvolDFSR {
    <#
    .SYNOPSIS
    Clears the ConflictAndDeleted folder in DFSR for specified GPOs.

    .DESCRIPTION
    This function clears the ConflictAndDeleted folder in DFSR for specified Group Policy Objects (GPOs) within a given forest. It allows excluding specific domains and domain controllers if needed.

    .PARAMETER Forest
    Specifies the forest name where the GPOs are located.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from the cleanup process.

    .PARAMETER ExcludeDomainControllers
    Specifies an array of domain controllers to exclude from the cleanup process.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include in the cleanup process.

    .PARAMETER IncludeDomainControllers
    Specifies an array of domain controllers to include in the cleanup process.

    .PARAMETER SkipRODC
    Indicates whether Read-Only Domain Controllers (RODCs) should be skipped during cleanup.

    .PARAMETER ExtendedForestInformation
    Specifies additional forest information if needed.

    .PARAMETER LimitProcessing
    Specifies the maximum number of GPOs to process.

    .EXAMPLE
    Clear-GPOZaurrSysvolDFSR -Forest "contoso.com" -IncludeDomains "child.contoso.com" -ExcludeDomainControllers "dc1.contoso.com" -SkipRODC
    Clears the ConflictAndDeleted folder in DFSR for GPOs in the "contoso.com" forest, including only the "child.contoso.com" domain and excluding the "dc1.contoso.com" domain controller.

    .EXAMPLE
    Clear-GPOZaurrSysvolDFSR -Forest "contoso.com" -IncludeDomains "child.contoso.com" -LimitProcessing 5
    Clears the ConflictAndDeleted folder in DFSR for GPOs in the "contoso.com" forest, including only the "child.contoso.com" domain, and processes a maximum of 5 GPOs.

    #>
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [string[]] $ExcludeDomainControllers,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [alias('DomainControllers')][string[]] $IncludeDomainControllers,
        [switch] $SkipRODC,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [int] $LimitProcessing = [int32]::MaxValue
    )
    # Based on https://techcommunity.microsoft.com/t5/ask-the-directory-services-team/manually-clearing-the-conflictanddeleted-folder-in-dfsr/ba-p/395711
    $StatusCodes = @{
        '0' = 'Success' # MONITOR_STATUS_SUCCESS
        '1' = 'Generic database error' #MONITOR_STATUS_GENERIC_DB_ERROR
        '2' = 'ID record not found' # MONITOR_STATUS_IDRECORD_NOT_FOUND
        '3' = 'Volume not found' # MONITOR_STATUS_VOLUME_NOT_FOUND
        '4' = 'Access denied' #MONITOR_STATUS_ACCESS_DENIED
        '5' = 'Generic error' #MONITOR_STATUS_GENERIC_ERROR
    }

    #WMIC.EXE /namespace:\\root\microsoftdfs path dfsrreplicatedfolderconfig get replicatedfolderguid, replicatedfoldername
    #WMIC.EXE /namespace:\\root\microsoftdfs path dfsrreplicatedfolderinfo where "replicatedfolderguid='<RF GUID>'" call cleanupconflictdirectory
    #WMIC.EXE /namespace:\\root\microsoftdfs path dfsrreplicatedfolderinfo where "replicatedfolderguid='70bebd41-d5ae-4524-b7df-4eadb89e511e'" call cleanupconflictdirectory

    # https://docs.microsoft.com/en-us/previous-versions/windows/desktop/dfsr/dfsrreplicatedfolderinfo
    $getGPOZaurrSysvolDFSRSplat = @{
        Forest                    = $Forest
        IncludeDomains            = $IncludeDomains
        ExcludeDomains            = $ExcludeDomains
        ExtendedForestInformation = $ExtendedForestInformation
        ExcludeDomainControllers  = $ExcludeDomainControllers
        IncludeDomainControllers  = $IncludeDomainControllers
        SkipRODC                  = $SkipRODC
    }
    Get-GPOZaurrSysvolDFSR @getGPOZaurrSysvolDFSRSplat | Select-Object -First $LimitProcessing | ForEach-Object {
        $Executed = Invoke-CimMethod -InputObject $_.DFSR -MethodName 'cleanupconflictdirectory' -CimSession $_.ComputerName
        if ($Executed) {
            [PSCustomObject] @{
                Status       = $StatusCodes["$($Executed.ReturnValue)"]
                ComputerName = $Executed.PSComputerName
            }
        }
    }
}