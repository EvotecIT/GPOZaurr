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
        if ($DeleteExisting) {
            $Test = Test-Path -LiteralPath $GPOPath
            if ($Test) {
                Write-Verbose "Save-GPOZaurrFiles - Removing existing content in $GPOPath"
                Remove-Item -LiteralPath $GPOPath -Recurse
            }
        }
        $null = New-Item -ItemType Directory -Path $GPOPath -Force
        Write-Verbose "Save-GPOZaurrFiles - Gathering GPO data"
        $Count = 0
        $GPOs = Get-GPOZaurrAD -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        foreach ($GPO in $GPOS) {
            $Count++
            Write-Verbose "Save-GPOZaurrFiles - Processing GPO ($Count/$($GPOS.Count)) $($GPO.DomainName) | $($GPO.DisplayName)"
            $XMLContent = Get-GPOReport -ID $GPO.Guid -ReportType XML -Domain $GPO.DomainName
            $GPODOmainFolder = [io.path]::Combine($GPOPath, $GPO.DomainName)
            if (-not (Test-Path -Path $GPODOmainFolder)) {
                $null = New-Item -ItemType Directory -Path $GPODOmainFolder -Force
            }
            $Path = [io.path]::Combine($GPODOmainFolder, "$($GPO.Guid).xml")
            $XMLContent | Set-Content -LiteralPath $Path -Force -Encoding Unicode
        }
        $GPOListPath = [io.path]::Combine($GPOPath, "GPOList.xml")
        $GPOs | Export-Clixml -Depth 5 -Path $GPOListPath
    }
}