function Get-GPOZaurrSysvol {
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [string[]] $ExcludeDomainControllers,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [alias('DomainControllers')][string[]] $IncludeDomainControllers,
        [switch] $SkipRODC,
        [Array] $GPOs,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [switch] $VerifyDomainControllers
    )
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExcludeDomainControllers $ExcludeDomainControllers -IncludeDomainControllers $IncludeDomainControllers -SkipRODC:$SkipRODC -ExtendedForestInformation $ExtendedForestInformation
    if (-not $VerifyDomainControllers) {
        foreach ($Domain in $ForestInformation.Domains) {
            Write-Verbose "Get-WinADGPOSysvolFolders - Processing $Domain"
            $QueryServer = $ForestInformation['QueryServers']["$Domain"].HostName[0]
            [Array]$GPOs = @(Get-GPO -All -Domain $Domain -Server $QueryServer)
            Test-SysVolFolders -GPOs $GPOs -Server $Domain -Domain $Domain
        }
    } else {
        foreach ($Domain in $ForestInformation.Domains) {
            Write-Verbose "Get-WinADGPOSysvolFolders - Processing $Domain"
            $QueryServer = $ForestInformation['QueryServers']["$Domain"].HostName[0]
            [Array]$GPOs = @(Get-GPO -All -Domain $Domain -Server $QueryServer)
            foreach ($Server in $ForestInformation['DomainDomainControllers']["$Domain"]) {
                Write-Verbose "Get-WinADGPOSysvolFolders - Processing $Domain \ $($Server.HostName.Trim())"
                Test-SysVolFolders -GPOs $GPOs -Server $Server.Hostname -Domain $Domain
            }
        }
    }
}

