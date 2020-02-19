function Save-GPOZaurrFiles {
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath
    )
    if ($GPOPath) {
        if (-not $ExtendedForestInformation) {
            $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
        } else {
            $ForestInformation = $ExtendedForestInformation
        }
        $null = New-Item -ItemType Directory -Path $GPOPath -Force
        foreach ($Domain in $ForestInformation.Domains) {
            Get-GPO -All -Server $ForestInformation.QueryServers[$Domain].HostName[0] -Domain $Domain | ForEach-Object {
                $XMLContent = Get-GPOReport -ID $_.ID.Guid -ReportType XML -Server $ForestInformation.QueryServers[$Domain].HostName[0] -Domain $Domain
                $Path = [io.path]::Combine($GPOPath, "$($_.ID.Guid).xml")

                $XMLContent | Set-Content -LiteralPath $Path -Force -Encoding Unicode
            }
        }
    }
}