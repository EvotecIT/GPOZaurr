function Get-GPOZaurrInheritance {
    <#
    .SYNOPSIS
    Retrieves inheritance information for Group Policy Objects (GPOs) within specified Organizational Units (OUs).

    .DESCRIPTION
    This function retrieves and displays inheritance information for GPOs within specified OUs. It provides details on blocked inheritance, excluded objects, and group policies associated with blocked objects.

    .PARAMETER IncludeBlockedObjects
    Specifies whether to include OUs with blocked inheritance. By default, this is disabled.

    .PARAMETER OnlyBlockedInheritance
    Specifies whether to show only OUs with blocked inheritance.

    .PARAMETER IncludeExcludedObjects
    Specifies whether to show excluded objects. By default, this is disabled.

    .PARAMETER IncludeGroupPoliciesForBlockedObjects
    Specifies whether to include Group Policies for blocked objects. By default, this is disabled.

    .PARAMETER Exclusions
    Specifies the OUs approved by IT to be excluded. You can provide OUs by canonical name or distinguishedName.

    .PARAMETER Forest
    Specifies the target forest. By default, the current forest is used.

    .PARAMETER ExcludeDomains
    Specifies the domain to exclude from the search. By default, the entire forest is scanned.

    .PARAMETER IncludeDomains
    Specifies specific domains to include. By default, the entire forest is scanned.

    .PARAMETER ExtendedForestInformation
    Allows providing Forest Information from another command to speed up processing.

    .EXAMPLE
    $Objects = Get-GPOZaurrInheritance -IncludeBlockedObjects -IncludeExcludedObjects -OnlyBlockedInheritance -Exclusions $ExcludedOU
    $Objects | Format-Table

    .NOTES
    These are general notes about the function.
    #>
    [cmdletBinding()]
    param(
        [switch] $IncludeBlockedObjects,
        [switch] $OnlyBlockedInheritance,
        [switch] $IncludeExcludedObjects,
        [switch] $IncludeGroupPoliciesForBlockedObjects,
        [string[]] $Exclusions,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Begin {
        $ExclusionsCache = @{}
        $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        foreach ($Exclusion in $Exclusions) {
            $ExclusionsCache[$Exclusion] = $true
        }
    }
    Process {
        foreach ($Domain in $ForestInformation.Domains) {
            $OrganizationalUnits = Get-ADOrganizationalUnit -Filter * -Properties gpOptions, canonicalName -Server $ForestInformation['QueryServers'][$Domain]['HostName'][0]
            foreach ($OU in $OrganizationalUnits) {
                $InheritanceInformation = [Ordered] @{
                    CanonicalName      = $OU.canonicalName
                    BlockedInheritance = if ($OU.gpOptions -eq 1) { $true } else { $false }
                    Exclude            = $false
                    DomainName         = ConvertFrom-DistinguishedName -ToDomainCN -DistinguishedName $OU.DistinguishedName
                }
                if ($InheritanceInformation.BlockedInheritance -and $IncludeGroupPoliciesForBlockedObjects.IsPresent) {
                    try {
                        $GPInheritance = Get-GPInheritance -Target $OU.distinguishedName -ErrorAction Stop -Domain $InheritanceInformation.DomainName
                    } catch {
                        Write-Warning -Message "Get-GPOZaurrInheritance - Can't get GPInheritance for $($OU.distinguishedName). Error: $($_.Exception.Message)"
                        continue
                    }
                    $ActiveGroupPolicies = foreach ($GPO in $GPInheritance.InheritedGpoLinks) {
                        [PSCustomObject] @{
                            OrganizationalUnit   = $OU.canonicalName
                            DisplayName          = $GPO.DisplayName
                            DomainName           = $GPO.GpoDomainName
                            LinkedDirectly       = if ($OU.DistinguishedName -eq $GPO.Target) { $true } else { $false }
                            GPOID                = $GPO.GPOID
                            Enabled              = $GPO.Enabled
                            Enforced             = $GPO.Enforced
                            Order                = $GPO.Order
                            LinkedTo             = $GPO.Target
                            OrganizationalUnitDN = $OU.DistinguishedName
                        }
                    }
                } else {
                    $ActiveGroupPolicies = $null
                }
                if ($Exclusions) {
                    if ($ExclusionsCache[$OU.canonicalName]) {
                        $InheritanceInformation['Exclude'] = $true
                    } elseif ($ExclusionsCache[$OU.DistinguishedName]) {
                        $InheritanceInformation['Exclude'] = $true
                    }
                }
                if (-not $IncludeExcludedObjects -and $InheritanceInformation['Exclude']) {
                    continue
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
                            [Array] $InheritanceInformation['Users'] = (Get-ADUser -SearchBase $OU.DistinguishedName -Server $ForestInformation['QueryServers'][$Domain]['HostName'][0] -Filter *).SamAccountName
                            [Array] $InheritanceInformation['Computers'] = (Get-ADComputer -SearchBase $OU.DistinguishedName -Server $ForestInformation['QueryServers'][$Domain]['HostName'][0] -Filter *).SamAccountName
                            $InheritanceInformation['UsersCount'] = $InheritanceInformation['Users'].Count
                            $InheritanceInformation['ComputersCount'] = $InheritanceInformation['Computers'].Count
                        } else {
                            $InheritanceInformation['UsersCount'] = $null
                            $InheritanceInformation['ComputersCount'] = $null
                            $InheritanceInformation['Users'] = $null
                            $InheritanceInformation['Computers'] = $null
                        }
                    }
                    $InheritanceInformation['DistinguishedName'] = $OU.DistinguishedName
                    $InheritanceInformation['GroupPolicies'] = $ActiveGroupPolicies
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