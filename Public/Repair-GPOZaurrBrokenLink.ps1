function Repair-GPOZaurrBrokenLink {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [int] $LimitProcessing
    )
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -Extended
    $Links = Get-GPOZaurrBrokenLink -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ForestInformation
    $Cache = @{}
    foreach ($Link in $Links) {
        if (-not $Cache[$Link.DistinguishedName]) {
            $Cache[$Link.DistinguishedName] = [System.Collections.Generic.List[PSCustomObject]]::new()
        }
        $Cache[$Link.DistinguishedName].Add($Link)
    }
    $Count = 0
    foreach ($Key in $Cache.Keys) {
        $Count++
        Write-Verbose "Repair-GPOZaurrBrokenLink - processing [$Count/$($Cache.Keys.Count)] $Key "
        $Domain = ConvertFrom-DistinguishedName -ToDomainCN -DistinguishedName $Key
        $Server = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
        $Object = Get-ADObject -Identity $Key -Server $Server -Properties gpLink
        #$MatchLinks = [Regex]::Matches($Object.gpLink, '(?<=\[)(.*?)(?=\])').Value
        $MatchLinks = [Regex]::Matches($Object.gpLink, '(?<=LDAP:\/\/)(.*?)(?=])').Value
        $Found = $false
        $FixedLinks = foreach ($Match in $MatchLinks) {
            $SplittedValue = $Match -split ';'
            $GPODN = $SplittedValue[0]
            # Check if list of non-existing GPOs contains legitimate GPO
            if ($Cache[$Key].GPODistinguishedName -notcontains $GPODN) {
                "[LDAP://$Match]"
                Write-Verbose "Repair-GPOZaurrBrokenLink - legitimate link to GPO $GPODN ($Key)"
            } else {
                $Found = $true
                Write-Verbose "Repair-GPOZaurrBrokenLink - preparing for removal link to $GPODN ($Key)"
            }
        }
        #
        if ($Found) {
            $NewGpLink = $($FixedLinks -join '')
            try {
                Write-Verbose "Repair-GPOZaurrBrokenLink - setting gpLink to $Key - $NewGPLink"
                Set-ADObject -Identity $Key -Server $Server -Replace @{ gPLink = $NewGpLink } -ErrorAction Stop
            } catch {
                Write-Warning "Repair-GPOZaurrBrokenLink - couldn't replace gpLink at $Key with $NewGpLink"
            }
            if ($LimitProcessing -eq $Count) {
                break
            }
        }
    }
}