function Clear-GPOZaurrSysvolDFSR {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
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
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        Write-Verbose "Clear-GPOZaurrSysvolDFSR - Processing $Domain"
        $QueryServer = $ForestInformation['QueryServers']["$Domain"].HostName[0]
        $DFSR = Get-GPOZaurrSysvolDFSR -IncludeDomains $Domain -ExtendedForestInformation $ForestInformation
        $Executed = Invoke-CimMethod -InputObject $DFSR.DFSR -MethodName 'cleanupconflictdirectory' -CimSession $QueryServer
        if ($Executed) {
            [PSCustomObject] @{
                Status       = $StatusCodes["$($Executed.ReturnValue)"]
                ComputerName = $Executed.PSComputerName
            }
        }
    }
}