function Remove-GPOZaurrWMI {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Guid[]] $Guid,
        [string[]] $Name,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    if (-not $Forest -and -not $ExcludeDomains -and -not $IncludeDomains -and -not $ExtendedForestInformation) {
        $IncludeDomains = $Env:USERDNSDOMAIN
    }
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
        [Array] $Objects = @(
            if ($Guid) {
                Get-GPOZaurrWMI -Guid $Guid -ExtendedForestInformation $ForestInformation -IncludeDomains $Domain
            }
            if ($Name) {
                Get-GPOZaurrWMI -Name $Name -ExtendedForestInformation $ForestInformation -IncludeDomains $Domain
            }
        )
        $Objects | ForEach-Object -Process {
            if ($_.DistinguishedName) {
                Write-Verbose "Remove-GPOZaurrWMI - Removing WMI Filter $($_.DistinguishedName)"
                Remove-ADObject $_.DistinguishedName -Confirm:$false -Server $QueryServer
            }
        }
    }
}