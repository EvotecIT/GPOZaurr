function Get-GPOZaurrOrganizationalUnit {
    [CmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $CachedOu = [ordered] @{}
    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        $TopOrganizationalUnits = Get-ADOrganizationalUnit -Filter * -Properties LinkedGroupPolicyObjects, DistinguishedName, ntSecurityDescriptor -Server $ForestInformation['QueryServers'][$Domain]['hostname'][0] -SearchScope OneLevel
        foreach ($TopOU in $TopOrganizationalUnits) {
            # cache top ou
            $CachedOu[$TopOU.DistinguishedName] = [ordered]@{
                'LinkedGroupPolicyObjects' = $TopOU.LinkedGroupPolicyObjects
                'Objects'                  = [ordered] @{}
                'ObjectsClasses'           = [ordered] @{}
                'ObjectsCountDirect'       = 0
                'ObjectsCountIndirect'     = 0
                'ObjectsCountTotal'        = 0
                'Level'                    = 'Top'
                'Domain'                   = $Domain
            }

            # cache children OUs
            $OUs = Get-ADOrganizationalUnit -SearchScope Subtree -SearchBase $TopOU.DistinguishedName -Server $ForestInformation['QueryServers'][$Domain]['hostname'][0] -Properties LinkedGroupPolicyObjects, DistinguishedName -Filter *
            foreach ($OU in $OUs) {
                if (-not $CachedOu[$OU.DistinguishedName]) {
                    $CachedOu[$OU.DistinguishedName] = [ordered]@{
                        'LinkedGroupPolicyObjects' = $OU.LinkedGroupPolicyObjects
                        'Objects'                  = [ordered] @{}
                        'ObjectsClasses'           = [ordered] @{}
                        'ObjectsCountDirect'       = 0
                        'ObjectsCountIndirect'     = 0
                        'ObjectsCountTotal'        = 0
                        'Level'                    = 'Child'
                        'Domain'                   = $Domain
                    }
                }
            }
            # Find all objects in those OUs
            $ObjectsInOu = Get-ADObject -LDAPFilter "(|(ObjectClass=user)(ObjectClass=contact)(ObjectClass=computer)(ObjectClass=group)(objectClass=inetOrgPerson))" -SearchBase $TopOU.distinguishedName -Server $ForestInformation['QueryServers'][$Domain]['hostname'][0]
            foreach ($Object in $ObjectsInOu) {
                $Place = ConvertFrom-DistinguishedName -ToOrganizationalUnit -DistinguishedName $Object.DistinguishedName
                $AllOUs = ConvertFrom-DistinguishedName -ToMultipleOrganizationalUnit -IncludeParent -DistinguishedName $Place
                foreach ($OU in $AllOUs) {
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


        [PSCustomObject] @{
            Organizationalunit  = $OU
            Level               = $CachedOu[$OU]['Level']
            DomainName          = $CachedOu[$OU]['Domain']
            Status              = $Status
            GPOCount            = $CachedOu[$OU]['LinkedGroupPolicyObjects'].Count
            ObjectCountDirect   = $CachedOu[$OU]['ObjectsCountDirect']
            ObjectCountIndirect = $CachedOu[$OU]['ObjectsCountIndirect']
            ObjectCountTotal    = $CachedOu[$OU]['ObjectsCountTotal']
            ObjectClasses       = $ObjectClasses
            Objects             = $CachedOu[$OU]['Objects'].Values.Name
        }
    }
}

#$Values = Get-WinADOrganizationalUnits
#$Values | Format-Table

<#
$T = ([adsisearcher]'(objectcategory=organizationalunit)').FindAll() | Where-Object {
    -not (-join $_.GetDirectoryEntry().psbase.children) }
    #>