function Clear-GPOZaurrSysvolDFSR {
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