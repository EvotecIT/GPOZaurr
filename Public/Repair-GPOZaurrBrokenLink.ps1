function Repair-GPOZaurrBrokenLink {
    <#
    .SYNOPSIS
    Removes any link to GPO that no longer exists.

    .DESCRIPTION
    Removes any link to GPO that no longer exists. It scans all site, organizational unit or domain root making sure every single link that may be linking to GPO that doesn't exists anymore is gone.

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .PARAMETER LimitProcessing
    Allows to specify maximum number of items that will be fixed in a single run. It doesn't affect amount of GPOs processed

    .EXAMPLE
    Repair-GPOZaurrBrokenLink -Verbose -LimitProcessing 1 -WhatIf

    .EXAMPLE
    Repair-GPOZaurrBrokenLink -Verbose -IncludeDomains ad.evotec.pl -LimitProcessing 1 -WhatIf

    .NOTES
    General notes
    #>
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [int] $LimitProcessing
    )
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -Extended
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
        if ($Found) {
            $NewGpLink = $($FixedLinks -join '')
            if ($NewGpLink) {
                try {
                    Write-Verbose "Repair-GPOZaurrBrokenLink - setting gpLink to $Key - $NewGPLink"
                    Set-ADObject -Identity $Key -Server $Server -Replace @{ gPLink = $NewGpLink } -ErrorAction Stop
                } catch {
                    Write-Warning "Repair-GPOZaurrBrokenLink - setting gpLink to $Key - $NewGpLink failed! Error $($_.Exception.Message)"
                }
            } else {
                try {
                    Write-Verbose "Repair-GPOZaurrBrokenLink - clearing gpLink for $Key (no other links)"
                    Set-ADObject -Identity $Key -Server $Server -Clear gPLink -ErrorAction Stop
                } catch {
                    Write-Warning "Repair-GPOZaurrBrokenLink - clearing gpLink for $Key failed! Error $($_.Exception.Message)"
                }
            }
            if ($LimitProcessing -eq $Count) {
                break
            }
        }
    }
}