function Get-GPOZaurrInheritance {
    [cmdletBinding()]
    param(
        [switch] $IncludeBlockedObjects,
        [switch] $OnlyBlockedInheritance,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Begin {
        $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    }
    Process {
        foreach ($Domain in $ForestInformation.Domains) {
            $OrganizationalUnits = Get-ADOrganizationalUnit -Filter * -Properties gpOptions, canonicalName -Server $ForestInformation['QueryServers'][$Domain]['HostName'][0]
            foreach ($OU in $OrganizationalUnits) {
                $InheritanceInformation = [Ordered] @{
                    DistinguishedName  = $OU.DistinguishedName
                    CanonicalName      = $OU.canonicalName
                    BlockedInheritance = if ($OU.gpOptions -eq 1) { $true } else { $false }
                }
                if (-not $IncludeBlockedObjects) {
                    if ($OnlyBlockedInheritance) {
                        if ($InheritanceInformation.BlockedInheritance -eq $true) {
                            [PSCustomObject] $InheritanceInformation
                        }
                    } else {
                        [PSCustomObject] $InheritanceInformation
                    }
                } else {
                    if ($InheritanceInformation) {
                        if ($InheritanceInformation.BlockedInheritance -eq $true) {
                            $InheritanceInformation['UsersCount'] = $null
                            $InheritanceInformation['ComputersCount'] = $null
                            $InheritanceInformation['Users'] = Get-ADUser -SearchBase $InheritanceInformation.DistinguishedName -Server $ForestInformation['QueryServers'][$Domain]['HostName'][0] -Filter *
                            $InheritanceInformation['Computers'] = Get-ADComputer -SearchBase $InheritanceInformation.DistinguishedName -Server $ForestInformation['QueryServers'][$Domain]['HostName'][0] -Filter *
                            $InheritanceInformation['UsersCount'] = $InheritanceInformation['Users'].Count
                            $InheritanceInformation['ComputersCount'] = $InheritanceInformation['Computers'].Count
                        } else {
                            $InheritanceInformation['UsersCount'] = $null
                            $InheritanceInformation['ComputersCount'] = $null
                            $InheritanceInformation['Users'] = $null
                            $InheritanceInformation['Computers'] = $null
                        }
                    }
                    if ($OnlyBlockedInheritance) {
                        if ($InheritanceInformation.BlockedInheritance -eq $true) {
                            [PSCustomObject] $InheritanceInformation
                        }
                    } else {
                        [PSCustomObject] $InheritanceInformation
                    }
                }
            }
        }
    }
}

<#

$OrganizationalUnits = Get-ADOrganizationalUnit -Filter *
$Output = foreach ($OU in $OrganizationalUnits) {
    Get-GPInheritance -Target $OU.DistinguishedName
}
$Output | Format-Table
#>