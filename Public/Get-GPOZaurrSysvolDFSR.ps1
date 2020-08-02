function Get-GPOZaurrSysvolDFSR {
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string] $SearchDFSR = 'SYSVOL Share'
    )
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        Write-Verbose "Get-GPOZaurrSysvolDFSR - Processing $Domain"
        $QueryServer = $ForestInformation['QueryServers']["$Domain"].HostName[0]

        $DFSRConfig = Get-CimInstance -Namespace 'root\microsoftdfs' -Class 'dfsrreplicatedfolderconfig' -ComputerName $QueryServer | Where-Object { $_.ReplicatedFolderName -eq $SearchDFSR }
        $DFSR = Get-CimInstance -Namespace 'root\microsoftdfs' -Class 'dfsrreplicatedfolderinfo' -ComputerName $QueryServer | Where-Object { $_.ReplicatedFolderName -eq $SearchDFSR }
        if ($DFSR -and $DFSRConfig -and ($DFSR.ReplicatedFolderGuid -eq $DFSRConfig.ReplicatedFolderGuid)) {
            [PSCustomObject] @{
                ComputerName             = $DFSR.PSComputerName
                DomainName               = $Domain
                ConflictPath             = $DFSRConfig.ConflictPath
                LastConflictCleanupTime  = $DFSR.LastConflictCleanupTime
                CurrentConflictSizeInMb  = $DFSR.CurrentConflictSizeInMb
                MaximumConflictSizeInMb  = $DFSRConfig.ConflictSizeInMb
                LastErrorCode            = $DFSR.LastErrorCode
                LastErrorMessageId       = $DFSR.LastErrorMessageId
                LastTombstoneCleanupTime = $DFSR.LastTombstoneCleanupTime
                ReplicatedFolderGuid     = $DFSR.ReplicatedFolderGuid
                DFSRConfig               = $DFSRConfig
                DFSR                     = $DFSR
            }
        }
    }
}