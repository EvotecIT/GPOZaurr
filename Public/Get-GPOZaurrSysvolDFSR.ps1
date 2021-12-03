function Get-GPOZaurrSysvolDFSR {
    <#
    .SYNOPSIS
    Gets DFSR information from the SYSVOL DFSR

    .DESCRIPTION
    Gets DFSR information from the SYSVOL DFSR

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER ExcludeDomainControllers
    Exclude specific domain controllers, by default there are no exclusions, as long as VerifyDomainControllers switch is enabled. Otherwise this parameter is ignored.

    .PARAMETER IncludeDomainControllers
    Include only specific domain controllers, by default all domain controllers are included, as long as VerifyDomainControllers switch is enabled. Otherwise this parameter is ignored.

    .PARAMETER SkipRODC
    Skip Read-Only Domain Controllers. By default all domain controllers are included.

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .PARAMETER SearchDFSR
    Define DFSR Share. By default it uses SYSVOL Share

    .EXAMPLE
    $DFSR = Get-GPOZaurrSysvolDFSR
    $DFSR | Format-Table *

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [string[]] $ExcludeDomainControllers,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [alias('DomainControllers')][string[]] $IncludeDomainControllers,
        [switch] $SkipRODC,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string] $SearchDFSR = 'SYSVOL Share'
    )
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExcludeDomainControllers $ExcludeDomainControllers -IncludeDomainControllers $IncludeDomainControllers -SkipRODC:$SkipRODC -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        Write-Verbose "Get-GPOZaurrSysvolDFSR - Processing $Domain"
        foreach ($DC in $ForestInformation.DomainDomainControllers[$Domain]) {
            Write-Verbose "Get-GPOZaurrSysvolDFSR - Processing $Domain \ $($DC.HostName)"
            #$QueryServer = $ForestInformation['QueryServers']["$Domain"].HostName[0]
            $DFSRConfig = Get-CimInstance -Namespace 'root\microsoftdfs' -Class 'dfsrreplicatedfolderconfig' -ComputerName $($DC.HostName) | Where-Object { $_.ReplicatedFolderName -eq $SearchDFSR }
            $DFSR = Get-CimInstance -Namespace 'root\microsoftdfs' -Class 'dfsrreplicatedfolderinfo' -ComputerName $($DC.HostName) | Where-Object { $_.ReplicatedFolderName -eq $SearchDFSR }
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
            } else {
                Write-Warning "Get-GPOZaurrSysvolDFSR - Couldn't process $($DC.HostName). Conditions not met."
            }
        }
    }
}