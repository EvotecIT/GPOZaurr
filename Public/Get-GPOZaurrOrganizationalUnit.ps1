function Get-GPOZaurrOrganizationalUnit {
    <#
    .SYNOPSIS
    Retrieves information about Group Policy Objects (GPOs) linked to Organizational Units (OUs) within a specified forest.

    .DESCRIPTION
    This function retrieves detailed information about the GPOs linked to OUs within a specified forest. It provides information on linked GPOs, objects within OUs, and counts of objects at different levels.

    .PARAMETER Forest
    Specifies the name of the forest to retrieve information from.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from processing.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include for processing.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest.

    .PARAMETER Option
    Specifies the action to perform on the retrieved data. Valid values are 'OK', 'Unlink', or 'Delete'.

    .PARAMETER ExcludeOrganizationalUnit
    Specifies an array of OUs to exclude from processing.

    .EXAMPLE
    Get-GPOZaurrOrganizationalUnit -Forest "contoso.com" -IncludeDomains "child.contoso.com" -ExcludeDomains "test.contoso.com" -ExtendedForestInformation $ExtendedInfo -Option "OK" -ExcludeOrganizationalUnit "OU=Test,DC=contoso,DC=com"
    Retrieves information about GPOs linked to OUs in the "contoso.com" forest, including the "child.contoso.com" domain, excluding the "test.contoso.com" domain, with additional forest information, performing the 'OK' action, and excluding the "OU=Test,DC=contoso,DC=com" OU.

    #>
    [CmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [ValidateSet('OK', 'Unlink', 'Delete')][string[]] $Option,
        [alias('ExcludeOU', 'Exclusions')][string[]] $ExcludeOrganizationalUnit
    )
    $CachedOu = [ordered] @{}
    $CachedGPO = [ordered] @{}

    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    $DefaultFolders = Get-WellKnownFolders -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    $GroupPolicies = Get-GPOZaurrAD -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($GPO in $GroupPolicies) {
        $CachedGPO[$GPO.GPODistinguishedName] = $GPO
    }
    foreach ($Domain in $ForestInformation.Domains) {
        Write-Verbose "Get-GPOZaurrOrganizationalUnit - Processing $($Domain)"
        $CountTop = 0
        [Array] $TopOrganizationalUnits = Get-ADOrganizationalUnit -Filter * -Properties LinkedGroupPolicyObjects, DistinguishedName, ntSecurityDescriptor -Server $ForestInformation['QueryServers'][$Domain]['hostname'][0] -SearchScope OneLevel
        foreach ($TopOU in $TopOrganizationalUnits) {
            $CountTop++
            Write-Verbose "Get-GPOZaurrOrganizationalUnit - Processing $($Domain) / $($TOPOU.DistinguishedName) [$CountTop/$($TopOrganizationalUnits.Count)]"
            # cache top ou
            if ($TopOU.LinkedGroupPolicyObjects) {
                $LinkedGPOs = $CachedGPO[$TopOU.LinkedGroupPolicyObjects]
            } else {
                $LinkedGPOs = $null
            }
            $CachedOu[$TopOU.DistinguishedName] = [ordered]@{
                'LinkedGroupPolicyObjects' = $TopOU.LinkedGroupPolicyObjects
                'LinkedGroupPolicy'        = $LinkedGPOs
                'Objects'                  = [ordered] @{}
                'ObjectsClasses'           = [ordered] @{}
                'ObjectsCountDirect'       = 0
                'ObjectsCountIndirect'     = 0
                'ObjectsCountTotal'        = 0
                'Level'                    = 'Top'
                'RootLevel'                = $TopOU.Name
                'Domain'                   = $Domain
            }

            # cache children OUs
            [Array] $OUs = Get-ADOrganizationalUnit -SearchScope Subtree -SearchBase $TopOU.DistinguishedName -Server $ForestInformation['QueryServers'][$Domain]['hostname'][0] -Properties LinkedGroupPolicyObjects, DistinguishedName -Filter *
            Write-Verbose "Get-GPOZaurrOrganizationalUnit - Processing $($Domain) / $($TOPOU.DistinguishedName) [$CountTop/$($TopOrganizationalUnits.Count)], found $($OUs.Count) OU's to process."
            foreach ($OU in $OUs) {
                if (-not $CachedOu[$OU.DistinguishedName]) {
                    if ($OU.LinkedGroupPolicyObjects) {
                        $LinkedGPOs = $CachedGPO[$OU.LinkedGroupPolicyObjects]
                    } else {
                        $LinkedGPOs = $null
                    }
                    $CachedOu[$OU.DistinguishedName] = [ordered]@{
                        'LinkedGroupPolicyObjects' = $OU.LinkedGroupPolicyObjects
                        'LinkedGroupPolicy'        = $LinkedGPOs
                        'Objects'                  = [ordered] @{}
                        'ObjectsClasses'           = [ordered] @{}
                        'ObjectsCountDirect'       = 0
                        'ObjectsCountIndirect'     = 0
                        'ObjectsCountTotal'        = 0
                        'Level'                    = 'Child'
                        'RootLevel'                = $TopOU.Name
                        'Domain'                   = $Domain
                    }
                }
            }
            # Find all objects in those OUs
            $ObjectsInOu = Get-ADObject -LDAPFilter "(|(ObjectClass=user)(ObjectClass=contact)(ObjectClass=computer)(ObjectClass=group)(objectClass=inetOrgPerson)(ObjectClass=PrintQueue))" -SearchBase $TopOU.distinguishedName -Server $ForestInformation['QueryServers'][$Domain]['hostname'][0]
            Write-Verbose "Get-GPOZaurrOrganizationalUnit - Processing $($Domain) / $($TOPOU.DistinguishedName) [$CountTop/$($TopOrganizationalUnits.Count)], found $($ObjectsInOu.Count) objects to process."
            foreach ($Object in $ObjectsInOu) {
                $Place = ConvertFrom-DistinguishedName -ToOrganizationalUnit -DistinguishedName $Object.DistinguishedName
                [Array] $AllOUs = ConvertFrom-DistinguishedName -ToMultipleOrganizationalUnit -IncludeParent -DistinguishedName $Place
                foreach ($OU in $AllOUs) {
                    if (-not $CachedOu[$OU]) {
                        Write-Warning "Get-GPOZaurrOrganizationalUnit - Object $($Object.DistinguishedName) is in OU $($OU) but it's not in cache. This should not happen. Please report this issue."
                        Write-Warning "Get-GPOZaurrOrganizationalUnit - Debug information: Place: $($Place), AllOUs: $($AllOUs.Count)"
                        continue
                    }
                    if ($OU -eq $Place) {
                        $CachedOu[$OU]['Objects'][$Object.DistinguishedName] = $Object
                        $CachedOu[$OU]['ObjectsClasses'][$Object.ObjectClass] = ''
                        $CachedOu[$OU]['ObjectsCountDirect']++
                    } else {
                        $CachedOu[$OU]['ObjectsClasses'][$Object.ObjectClass] = ''
                        $CachedOu[$OU]['ObjectsCountIndirect']++
                    }
                    $CachedOu[$OU]['ObjectsCountTotal']++
                }
            }
        }
    }
    foreach ($OU in $CachedOu.Keys) {
        $ObjectClasses = [string[]] $CachedOu[$OU]['ObjectsClasses'].Keys

        if ($CachedOu[$OU]['ObjectsCountTotal'] -eq 0 -and $CachedOu[$OU]['LinkedGroupPolicyObjects'].Count -gt 0) {
            $Status = "Unlink GPO", 'Delete OU'
        } elseif ($CachedOu[$OU]['ObjectsCountTotal'] -eq 0 -and $CachedOu[$OU]['LinkedGroupPolicyObjects'].Count -eq 0) {
            $Status = 'Delete OU'
        } elseif ($CachedOU[$Ou]['ObjectsCountTotal'] -gt 0 -and $CachedOu[$OU]['LinkedGroupPolicyObjects'].Count -gt 0 -and $ObjectClasses -notcontains 'User' -and $ObjectClasses -notcontains 'Computer' ) {
            $Status = "Unlink GPO"
        } else {
            $Status = 'OK'
        }

        if ($Option) {
            $Found = $false
            if ($Option -contains 'Ok' -and $Status -contains 'OK') {
                $Found = $true
            } elseif ($Option -contains 'Unlink' -and $Status -contains 'Unlink GPO') {
                $Found = $true
            } elseif ($Option -contains 'Delete' -and $Status -contains 'Delete OU') {
                $Found = $true
            }
            if ($ExcludeOrganizationalUnit) {
                foreach ($ExcludedOU in $ExcludeOrganizationalUnit) {
                    if ($OU -like $ExcludedOU) {
                        $Found = $false
                        break
                    }
                }
            }
            foreach ($Exclude in $DefaultFolders) {
                if ($OU -eq "$Exclude") {
                    $Found = $false
                    break
                }
            }
            if (-not $Found) {
                continue
            }
        } else {
            if ($ExcludeOrganizationalUnit) {
                foreach ($ExcludedOU in $ExcludeOrganizationalUnit) {
                    if ($OU -like $ExcludedOU) {
                        $Status = 'Excluded'
                        break
                    }
                }
            }
            foreach ($Exclude in $DefaultFolders) {
                if ($OU -eq "$Exclude") {
                    $Status = 'Excluded, Default OU'
                    break
                }
            }
        }

        [PSCustomObject] @{
            Organizationalunit  = $OU
            Level               = $CachedOu[$OU]['Level']
            RootLevel           = $CachedOu[$OU]['RootLevel']
            DomainName          = $CachedOu[$OU]['Domain']
            Status              = $Status
            GPOCount            = $CachedOu[$OU]['LinkedGroupPolicyObjects'].Count
            ObjectCountDirect   = $CachedOu[$OU]['ObjectsCountDirect']
            ObjectCountIndirect = $CachedOu[$OU]['ObjectsCountIndirect']
            ObjectCountTotal    = $CachedOu[$OU]['ObjectsCountTotal']
            ObjectClasses       = $ObjectClasses
            GPONames            = $CachedOu[$OU]['LinkedGroupPolicy'].DisplayName
            Objects             = $CachedOu[$OU]['Objects'].Values.Name
            GPO                 = $CachedOu[$OU]['LinkedGroupPolicy']
        }
    }
}