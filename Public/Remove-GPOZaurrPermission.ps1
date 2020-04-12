function Remove-GPOZaurrPermission {
    [cmdletBinding()]
    param(
        [string] $Type,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Get-GPOZaurrPermission -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation | ForEach-Object -Process {
        Write-Verbose "Remove-GPOZaurrPermission - Test"
    }
}