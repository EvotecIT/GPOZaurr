function Show-GPOZaurr {
    [cmdletBinding()]
    param(
        [string] $FilePath
    )

    $GPOContent = Invoke-GPOZaurr
    $GPOSummary = Get-GPOZaurr
    $GPOOrphans = Get-GPOZaurrSysvol
    $GPOPermissions = Get-GPOZaurrPermission -Type All -IncludePermissionType GpoEditDeleteModifySecurity, GpoEdit, GpoCustom -IncludeOwner
    $GPOPermissionsConsistency = Get-GPOZaurrPermissionConsistency -Type All -VerifyInheritance
    $GPOPermissionsRoot = Get-GPOZaurrPermissionRoot

    $GPOOwners = Get-GPOZaurrOwner -IncludeSysvol

    $GPOLinked = $GPOSummary.Where( { $_.Linked -eq $true }, 'split')
    $GPOEmpty = $GPOSummary.Where( { $_.Empty -eq $true, 'split' })
    $GPOTotal = $GPOSummary.Count

    $IsOwnerConsistent = $GPOOwners.Where( { $_.IsOwnerConsistent -eq $true } , 'split' )
    $IsOwnerAdministrative = $GPOOwners.Where( { $_.IsOwnerAdministrative -eq $true } , 'split' )

    [Array] $Inconsistent = $GPOPermissionsConsistency.Where( { $_.ACLConsistent -eq $true } , 'split' )
    [Array] $InconsistentInside = $GPOPermissionsConsistency.Where( { $_.ACLConsistentInside -eq $true }, 'split' )

    New-HTML {
        New-HTMLTabStyle -BorderRadius 0px -TextTransform capitalize -BackgroundColorActive SlateGrey
        New-HTMLSectionStyle -BorderRadius 0px -HeaderBackGroundColor Grey -RemoveShadow
        New-HTMLTableOption -DataStore JavaScript
        New-HTMLTab -Name 'Overview' {
            New-HTMLSection -Invisible {
                New-HTMLPanel {
                    New-HTMLChart -Title 'Group Policies Summary' {
                        New-ChartLegend -Names 'Unlinked', 'Linked', 'Empty', 'Total' -Color FireEngineRed, MediumSpringGreen, RedRobin, BlueDiamond
                        New-ChartBar -Name 'Group Policies' -Value $GPOLinked[1].Count, $GPOLinked[0].Count, $GPOEmpty[1].Count, $GPOTotal

                        #New-ChartBar -Name 'Linked' -Value $GPOLinked[0].Count
                        #New-ChartBar -Name 'Empty' -Value $GPOEmpty[1].Count
                        #New-ChartBar -Name 'Total' -Value $GPOTotal
                    } -TitleAlignment center
                }
                New-HTMLPanel {
                    New-HTMLChart {
                        New-ChartBarOptions -Type barStacked
                        New-ChartLegend -Name 'Consistent', 'Inconsistent'
                        New-ChartBar -Name 'TopLevel' -Value $Inconsistent[0].Count, $Inconsistent[1].Count
                        New-ChartBar -Name 'Inherited' -Value $InconsistentInside[0].Count, $InconsistentInside[1].Count
                    } -Title 'Permissions Consistency' -TitleAlignment center
                }
            }
            New-HTMLSection -Invisible {
                New-HTMLPanel {
                    New-HTMLText -Text 'Following chart presents Group Policy owners and whether they are administrative and consistent. By design an owner of Group Policy should be Domain Admins or Enterprise Admins group only to prevent malicious takeover. ', `
                        "It's also important that owner in Active Directory matches owner on SYSVOL (file system)."
                    New-HTMLChart {
                        New-ChartBarOptions -Type barStacked
                        New-ChartLegend -Name 'Yes', 'No' -Color Green, Red
                        New-ChartBar -Name 'Is administrative' -Value $IsOwnerAdministrative[0].Count, $IsOwnerAdministrative[1].Count
                        New-ChartBar -Name 'Is consistent' -Value $IsOwnerConsistent[0].Count, $IsOwnerConsistent[1].Count
                    } -Title 'Group Policy Owners'
                }
                New-HTMLPanel {

                }
            }
        }
        New-HTMLTab -Name 'Group Policies Summary' {
            New-HTMLTable -DataTable $GPOSummary -Filtering {
                New-HTMLTableCondition -Name 'Empty' -Value $false -BackgroundColor RedOxide -TextTransform capitalize -ComparisonType bool
                New-HTMLTableCondition -Name 'Linked' -Value $false -BackgroundColor RedOxide -TextTransform capitalize -ComparisonType bool
            }
        }
        New-HTMLTab -Name 'Sysvol' {
            New-HTMLTable -DataTable $GPOOrphans -Filtering
        }
        New-HTMLTab -Name 'Permissions' {
            New-HTMLTab -Name 'Root' {
                New-HTMLTable -DataTable $GPOPermissionsRoot -Filtering
            }
            New-HTMLTab -Name 'Owners' {
                New-HTMLTable -DataTable $GPOOwners -Filtering
            }
            New-HTMLTab -Name 'Edit & Modify' {
                New-HTMLTable -DataTable $GPOPermissions -Filtering
            }
            New-HTMLTab -Name 'Inconsistent' {
                New-HTMLTable -DataTable $GPOPermissionsConsistency -Filtering
            }
        }
        New-HTMLTab -Name 'Analysis' {
            foreach ($Key in $GPOContent.Keys) {
                New-HTMLTab -Name $Key {
                    New-HTMLTable -DataTable $GPOContent[$Key] -Filtering -Title $Key
                }
            }
        }
    } -Online -ShowHTML -FilePath $FilePath
}