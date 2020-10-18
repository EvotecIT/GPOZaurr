function Show-GPOZaurr {
    [cmdletBinding()]
    param(
        [string] $FilePath,
        [ValidateSet('GPOList', 'GPOOrphans', 'NetLogon')][string[]] $Type
    )

    if ($Type -contains 'GPOList' -or $null -eq $Type) {
        Write-Verbose -Message "Show-GPOZaurr - Processing GPO List"
        $GPOSummary = Get-GPOZaurr
        $GPOLinked = $GPOSummary.Where( { $_.Linked -eq $true }, 'split')
        $GPOEmpty = $GPOSummary.Where( { $_.Empty -eq $true, 'split' })
        $GPOTotal = $GPOSummary.Count
    }

    if ($Type -contains 'GPOOrphans' -or $null -eq $Type) {
        Write-Verbose -Message "Show-GPOZaurr - Processing GPO Sysvol"
        $GPOOrphans = Get-GPOZaurrSysvol
    }

    Write-Verbose -Message "Show-GPOZaurr - Processing GPO Permissions"
    $GPOPermissions = Get-GPOZaurrPermission -Type All -IncludePermissionType GpoEditDeleteModifySecurity, GpoEdit, GpoCustom -IncludeOwner

    Write-Verbose -Message "Show-GPOZaurr - Processing GPO Permissions Consistency"
    $GPOPermissionsConsistency = Get-GPOZaurrPermissionConsistency -Type All -VerifyInheritance

    Write-Verbose -Message "Show-GPOZaurr - Processing GPO Permissions Root"
    $GPOPermissionsRoot = Get-GPOZaurrPermissionRoot

    Write-Verbose "Show-GPOZaurr - Processing GPO Owners"
    $GPOOwners = Get-GPOZaurrOwner -IncludeSysvol

    if ($Type -contains 'NetLogon' -or $null -eq $Type) {
        Write-Verbose "Get-GPOZaurrNetLogon - Processing NETLOGON Share"
        $Netlogon = Get-GPOZaurrNetlogon
    }
    Write-Verbose "Show-GPOZaurr - Processing GPO Analysis"
    $GPOContent = Invoke-GPOZaurr



    $IsOwnerConsistent = $GPOOwners.Where( { $_.IsOwnerConsistent -eq $true } , 'split' )
    $IsOwnerAdministrative = $GPOOwners.Where( { $_.IsOwnerAdministrative -eq $true } , 'split' )

    [Array] $Inconsistent = $GPOPermissionsConsistency.Where( { $_.ACLConsistent -eq $true } , 'split' )
    [Array] $InconsistentInside = $GPOPermissionsConsistency.Where( { $_.ACLConsistentInside -eq $true }, 'split' )

    Write-Verbose "Show-GPOZaurr - Generating HTML"
    New-HTML {
        New-HTMLTabStyle -BorderRadius 0px -TextTransform capitalize -BackgroundColorActive SlateGrey
        New-HTMLSectionStyle -BorderRadius 0px -HeaderBackGroundColor Grey -RemoveShadow
        New-HTMLTableOption -DataStore JavaScript
        New-HTMLTab -Name 'Overview' {
            New-HTMLSection -Invisible {
                New-HTMLPanel {
                    New-HTMLChart -Title 'Group Policies Summary' {
                        New-ChartLegend -Names 'Unlinked', 'Linked', 'Empty', 'Total' -Color Salmon, PaleGreen, PaleVioletRed, PaleTurquoise
                        New-ChartBar -Name 'Group Policies' -Value $GPOLinked[1].Count, $GPOLinked[0].Count, $GPOEmpty[1].Count, $GPOTotal
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
                        New-ChartLegend -Name 'Yes', 'No' -Color PaleGreen, Orchid
                        New-ChartBar -Name 'Is administrative' -Value $IsOwnerAdministrative[0].Count, $IsOwnerAdministrative[1].Count
                        New-ChartBar -Name 'Is consistent' -Value $IsOwnerConsistent[0].Count, $IsOwnerConsistent[1].Count
                    } -Title 'Group Policy Owners'
                }
                New-HTMLPanel {

                }
            }
        }
        if ($Type -contains 'GPOList' -or $null -eq $Type) {
            New-HTMLTab -Name 'Group Policies Summary' {
                New-HTMLTable -DataTable $GPOSummary -Filtering {
                    New-HTMLTableCondition -Name 'Empty' -Value $false -BackgroundColor Salmon -TextTransform capitalize -ComparisonType bool
                    New-HTMLTableCondition -Name 'Linked' -Value $false -BackgroundColor Salmon -TextTransform capitalize -ComparisonType bool
                }
            }
        }
        if ($Type -contains 'GPOOrphans' -or $null -eq $Type) {
            New-HTMLTab -Name 'Sysvol' {
                New-HTMLTable -DataTable $GPOOrphans -Filtering
            }
        }
        if ($Type -contains 'NetLogon' -or $null -eq $Type) {
            New-HTMLTab -Name 'NetLogon' {
                New-HTMLTable -DataTable $Netlogon -Filtering
            }
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