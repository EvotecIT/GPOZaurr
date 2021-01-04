function Get-GPOZaurrBrokenLink {
    <#
    .SYNOPSIS
    Finds any GPO link that doesn't have a matching GPO (already removed GPO).

    .DESCRIPTION
    Finds any GPO link that doesn't have a matching GPO (already removed GPO).

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .EXAMPLE
    Get-GPOZaurrBrokenLink -Verbose | Format-Table -AutoSize *

    .EXAMPLE
    Get-GPOZaurrBrokenLink -Verbose -IncludeDomains ad.evotec.pl | Format-Table -AutoSize *

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $PoliciesAD = @{}
    # We need to request all GPOS from Forest. Requesting just for any domain won't be enough
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -Extended # -Extended
    foreach ($Domain in $ForestInformation.Domains) {
        $QueryServer = $ForestInformation['QueryServers']["$Domain"].HostName[0]
        $SystemsContainer = $ForestInformation['DomainsExtended'][$Domain].SystemsContainer
        if ($SystemsContainer) {
            $PoliciesSearchBase = -join ("CN=Policies,", $SystemsContainer)
            $PoliciesInAD = Get-ADObject -SearchBase $PoliciesSearchBase -SearchScope OneLevel -Filter * -Server $QueryServer -Properties Name, gPCFileSysPath, DisplayName, DistinguishedName, Description, Created, Modified, ObjectClass, ObjectGUID
            foreach ($Policy in $PoliciesInAD) {
                $GUIDFromDN = ConvertFrom-DistinguishedName -DistinguishedName $Policy.DistinguishedName
                # $Key = "$($Domain)$($GuidFromDN)"
                $Key = $Policy.DistinguishedName
                if ($Policy.ObjectClass -eq 'Container') {
                    # This usually means GPO deletion process somehow failed and while object itself stayed it isn't groupPolicyContainer anymore
                    $PoliciesAD[$Key] = 'ObjectClass issue'
                } else {
                    $GUID = $Policy.Name
                    if ($GUID -and $GUIDFromDN) {
                        $PoliciesAD[$Key] = 'Exists'
                    } else {
                        $PoliciesAD[$Key] = 'Permissions issue'
                    }
                }
            }
        } else {
            Write-Warning "Get-GPOZaurrBroken - Couldn't get GPOs from $Domain. Skipping"
        }
    }
    # In case of links we can request here whatever user requested.
    # This will search for broken links in domain user requested
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -Extended -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    $Links = Get-GPOZaurrLinkLoop -Linked 'All' -ForestInformation $ForestInformation
    foreach ($Link in $Links) {
        if (-not $PoliciesAD[$Link.GPODistinguishedName]) {
            $Link
        }
    }
}