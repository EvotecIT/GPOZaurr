function Get-GPOZaurr {
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath
    )
    Begin {
        if (-not $GPOPath) {
            $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        }
    }
    Process {
        if (-not $GPOPath) {
            foreach ($Domain in $ForestInformation.Domains) {
                Get-GPO -All -Server $ForestInformation.QueryServers[$Domain].HostName[0] -Domain $Domain | ForEach-Object {
                    Write-Verbose "Get-GPOZaurr - Getting GPO $($_.DisplayName) / ID: $($_.ID) from $Domain"
                    $XMLContent = Get-GPOReport -ID $_.ID -ReportType XML -Server $ForestInformation.QueryServers[$Domain].HostName[0] -Domain $Domain
                    Get-XMLGPO -XMLContent $XMLContent -GPO $_
                }
            }
        } else {
            foreach ($Path in $GPOPath) {
                Get-ChildItem -LiteralPath $Path -Recurse -Filter *.xml | ForEach-Object {
                    $XMLContent = [XML]::new()
                    $XMLContent.Load($_.FullName)
                    Get-XMLGPO -XMLContent $XMLContent
                }
            }
        }
    }
    End {

    }
}