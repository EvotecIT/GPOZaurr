function Get-GPOZaurrBrokenLink {
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $PoliciesAD = @{}
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExcludeDomainControllers $ExcludeDomainControllers -IncludeDomainControllers $IncludeDomainControllers -SkipRODC:$SkipRODC -ExtendedForestInformation $ExtendedForestInformation -Extended
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
    $Links = Get-GPOZaurrLinkLoop -Linked 'All' -ForestInformation $ForestInformation
    foreach ($Link in $Links) {
        if (-not $PoliciesAD[$Link.GPODistinguishedName]) {
            $Link
        }
    }
}