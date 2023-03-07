function Get-ADOrganizationalUnitObject {
    <#
    .SYNOPSIS
    Gets number of objects in a given OU/OUs with ability to find only those being affected by GPOs.

    .DESCRIPTION
    Gets number of objects in a given OU/OUs with ability to find only those being affected by GPOs.

    .PARAMETER OrganizationalUnit
    One or more organizational units to get the number of objects in.

    .PARAMETER Extended
    Adds all objects affected for better understanding

    .PARAMETER Summary
    Returns only summary for given OU/OUs

    .PARAMETER IncludeAffectedOnly
    Ignores any object types that are not Users or Computers

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER AsHashTable
    Returns results in form of hashtable

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .EXAMPLE
    $OUs = @(
        'OU=SE,OU=ITR01,DC=ad,DC=evotec,DC=xyz'
        'OU=US,OU=ITR01,DC=ad,DC=evotec,DC=xyz'
        'OU=ITR01,DC=ad,DC=evotec,DC=xyz'
        'OU=Users,OU=User,OU=SE1,OU=SE,OU=ITR01,DC=ad,DC=evotec,DC=xyz'
    )

    Get-ADOrganizationalUnitObject -OrganizationalUnit $OUs -IncludeAffectedOnly | Format-Table

    .EXAMPLE
    $OUs = @(
        'OU=SE,OU=ITR01,DC=ad,DC=evotec,DC=xyz'
        'OU=US,OU=ITR01,DC=ad,DC=evotec,DC=xyz'
        'OU=ITR01,DC=ad,DC=evotec,DC=xyz'
        'OU=Users,OU=User,OU=SE1,OU=SE,OU=ITR01,DC=ad,DC=evotec,DC=xyz'
    )

    Get-ADOrganizationalUnitObject -OrganizationalUnit $OUs | Format-Table

    .EXAMPLE
    $OUs = @(
        #'OU=SE,OU=ITR01,DC=ad,DC=evotec,DC=xyz'
        #'OU=US,OU=ITR01,DC=ad,DC=evotec,DC=xyz'
        'OU=Users,OU=User,OU=SE1,OU=SE,OU=ITR01,DC=ad,DC=evotec,DC=xyz'
        'OU=ITR01,DC=ad,DC=evotec,DC=xyz'
    )

    Get-ADOrganizationalUnitObject -OrganizationalUnit $OUs -Summary -IncludeAffectedOnly | Format-List

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [parameter(Mandatory)][Array] $OrganizationalUnit,
        [switch] $Extended,
        [switch] $Summary,
        [switch] $IncludeAffectedOnly,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [switch] $AsHashTable,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )

    $CachedOu = [ordered] @{}
    $ListOU = @(
        foreach ($OU in $OrganizationalUnit) {
            if ($OU.DistinguishedName) {
                $OU.DistinguishedName
            } else {
                $OU
            }
        }
    )
    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    $OUCache = Get-GPOBlockedInheritance -AsHashTable -ExtendedForestInformation $ForestInformation

    if ($Summary) {
        $SummaryData = [ordered] @{
            ObjectsClasses                 = [ordered] @{}
            ObjectsTotalCount              = 0
            ObjectsBlockedInheritanceCount = 0
            ObjectsTotal                   = [ordered] @{}
            ObjectsBlockedInheritance      = [ordered] @{}
            DistinguishedName              = [System.Collections.Generic.List[string]]::new()
        }
    }

    foreach ($OU in $ListOU) {
        $Domain = ConvertFrom-DistinguishedName -ToDomainCN -DistinguishedName $OU
        $ObjectsInOu = Get-ADObject -LDAPFilter "(|(ObjectClass=user)(ObjectClass=contact)(ObjectClass=computer)(ObjectClass=group)(objectClass=inetOrgPerson)(ObjectClass=PrintQueue))" -SearchBase $OU -Server $ForestInformation['QueryServers'][$Domain]['hostname'][0]
        #Write-Verbose "Get-GPOZaurrOrganizationalUnit - Processing $($Domain) / $($TOPOU.DistinguishedName) [$CountTop/$($TopOrganizationalUnits.Count)], found $($ObjectsInOu.Count) objects to process."
        if (-not $CachedOu[$OU]) {
            $CachedOu[$OU] = [ordered] @{
                DistinguishedName                   = $OU
                Domain                              = $Domain
                'ObjectsClasses'                    = [ordered] @{} # only direct, indirect, but not with blocked inheritance
                'ObjectsDirectCount'                = 0
                'ObjectsIndirectCount'              = 0
                'ObjectsTotalCount'                 = 0
                'ObjectsTotalIncludingBlockedCount' = 0
                'ObjectsBlockedInheritanceCount'    = 0
            }
            if ($Extended) {
                $CachedOu[$OU]['ObjectsDirect'] = [ordered] @{}
                $CachedOu[$OU]['ObjectsIndirect'] = [ordered] @{}
                $CachedOu[$OU]['ObjectsTotal'] = [ordered] @{}
                $CachedOu[$OU]['ObjectsTotalIncludingBlocked'] = [ordered] @{}
                $CachedOu[$OU]['ObjectsBlockedInheritance'] = [ordered] @{}
            }
        }
        foreach ($Object in $ObjectsInOu) {
            if ($IncludeAffectedOnly) {
                if ($Object.ObjectClass -notin 'User', 'computer') {
                    continue
                }
            }

            $Place = ConvertFrom-DistinguishedName -ToOrganizationalUnit -DistinguishedName $Object.DistinguishedName
            if (-not $Place) {
                # Write-Verbose -Message "Get-OrganizationalUnitObject - Processing object in container/root $($Object.DistinguishedName)"
            }

            if ($Place -and $OUCache[$Place]) {
                $BlockedInheritance = $OUCache[$Place].BlockedInheritance
            } else {
                $BlockedInheritance = $false
            }

            if ($Summary) {
                $SummaryData['DistinguishedName'].Add($OU)
                $SummaryData['ObjectsClasses'][$Object.ObjectClass] = ''
                if (-not $Place -or $Place -eq $OU) {
                    $SummaryData['ObjectsTotal'][$Object.DistinguishedName] = $Object
                } else {
                    if ($BlockedInheritance) {
                        $SummaryData['ObjectsBlockedInheritance'][$Object.DistinguishedName] = $Object
                    } else {
                        $SummaryData['ObjectsTotal'][$Object.DistinguishedName] = $Object
                    }
                }
            } else {
                # This is standard way of finding OU's
                if (-not $Place -or $Place -eq $OU) {
                    $CachedOu[$OU]['ObjectsDirectCount']++
                    $CachedOu[$OU]['ObjectsTotalCount']++
                    # using hashtable to avoid duplicates
                    $CachedOu[$OU]['ObjectsClasses'][$Object.ObjectClass] = ''
                    # adding all objects to the list, excluding blocked inheritance
                    if ($Extended) {
                        $CachedOu[$OU]['ObjectsTotal'][$Object.DistinguishedName] = $Object
                        $CachedOu[$OU]['ObjectsDirect'][$Object.DistinguishedName] = $Object
                    }
                } else {
                    if ($BlockedInheritance) {
                        # We only check for blocked inheritance if the object is not in the same OU
                        $CachedOu[$OU]['ObjectsBlockedInheritanceCount']++
                        if ($Extended) {
                            $CachedOu[$OU]['ObjectsBlockedInheritance'][$Object.DistinguishedName] = $Object
                        }
                    } else {
                        $CachedOu[$OU]['ObjectsIndirectCount']++
                        $CachedOu[$OU]['ObjectsTotalCount']++

                        # using hashtable to avoid duplicates
                        $CachedOu[$OU]['ObjectsClasses'][$Object.ObjectClass] = ''
                        # adding all objects to the list excluding blocked inheritance
                        if ($Extended) {
                            $CachedOu[$OU]['ObjectsTotal'][$Object.DistinguishedName] = $Object
                            $CachedOu[$OU]['ObjectsIndirect'][$Object.DistinguishedName] = $Object
                        }
                    }
                }
                $CachedOu[$OU]['ObjectsTotalIncludingBlockedCount']++
                if ($Extended) {
                    $CachedOu[$OU]['ObjectsTotalIncludingBlocked'][$Object.DistinguishedName] = $Object
                }
            }
        }

    }
    if ($Summary) {
        foreach ($ObjectDistinguishedName in [string[]] $SummaryData['ObjectsBlockedInheritance'].Keys) {
            if ($SummaryData['ObjectsTotal'][$ObjectDistinguishedName]) {
                $SummaryData['ObjectsBlockedInheritance'].Remove($ObjectDistinguishedName)
            }
        }
        $SummaryData['ObjectsTotalCount'] = $SummaryData['ObjectsTotal'].Count
        $SummaryData['ObjectsBlockedInheritanceCount'] = $SummaryData['ObjectsBlockedInheritance'].Count
        if (-not $Extended) {
            $SummaryData.Remove('ObjectsTotal')
            $SummaryData.Remove('ObjectsBlockedInheritance')
        }
        [PSCustomObject] $SummaryData
    } else {
        if ($AsHashTable) {
            $CachedOu
        } else {
            $CachedOu.Values | ForEach-Object { [PSCustomObject] $_ }
        }
    }
}