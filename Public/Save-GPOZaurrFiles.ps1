function Save-GPOZaurrFiles {
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath,
        [switch] $DeleteExisting
    )
    if ($GPOPath) {
        if (-not $ExtendedForestInformation) {
            $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
        } else {
            $ForestInformation = $ExtendedForestInformation
        }

        if ($DeleteExisting) {
            $Test = Test-Path -LiteralPath $GPOPath
            if ($Test) {
                Write-Verbose "Save-GPOZaurrFiles - Removing existing content in $GPOPath"
                Remove-Item -LiteralPath $GPOPath -Recurse
            }
        }

        $null = New-Item -ItemType Directory -Path $GPOPath -Force
        foreach ($Domain in $ForestInformation.Domains) {
            Write-Verbose "Save-GPOZaurrFiles - Processing GPO for $Domain"
            Get-GPO -All -Server $ForestInformation.QueryServers[$Domain].HostName[0] -Domain $Domain | ForEach-Object {
                $XMLContent = Get-GPOReport -ID $_.ID.Guid -ReportType XML -Server $ForestInformation.QueryServers[$Domain].HostName[0] -Domain $Domain
                $Path = [io.path]::Combine($GPOPath, "$($_.ID.Guid).xml")

                $XMLContent | Set-Content -LiteralPath $Path -Force -Encoding Unicode
            }
        }
    }
}