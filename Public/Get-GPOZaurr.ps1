function Get-GPOZaurr {
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath
    )

    if (-not $GPOPath) {
        if (-not $ExtendedForestInformation) {
            $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
        } else {
            $ForestInformation = $ExtendedForestInformation
        }

        foreach ($Domain in $ForestInformation.Domains) {
            Get-GPO -All -Server $ForestInformation.QueryServers[$Domain] -Domain $Domain | ForEach-Object {
               $XMLContent = Get-GPOReport -ID $_.ID -ReportType XML -Server $ForestInformation.QueryServers[$Domain] -Domain $Domain
               Get-XMLGPO -XMLContent $XMLContent
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
