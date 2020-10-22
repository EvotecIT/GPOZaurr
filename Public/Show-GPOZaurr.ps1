function Show-GPOZaurr {
    [cmdletBinding()]
    param(
        [string] $FilePath,
        [ValidateSet(
            'GPOList', 'GPOOrphans', 'GPOPermissions', 'GPOPermissionsRoot', 'GPOFiles',
            'GPOConsistency', 'GPOOwners', 'GPOAnalysis', 'NetLogon'
        )][string[]] $Type
    )
    $Script:Reporting = [ordered] @{

    }
    # Provide version check for easy use
    $GPOZaurrVersion = Get-Command -Name 'Show-GPOZaurr' -ErrorAction SilentlyContinue

    [Array] $GitHubReleases = (Get-GitHubLatestRelease -Url "https://api.github.com/repos/evotecit/GpoZaurr/releases" -Verbose:$false)

    $LatestVersion = $GitHubReleases[0]
    if (-not $LatestVersion.Errors) {
        if ($GPOZaurrVersion.Version -eq $LatestVersion.Version) {
            $Script:Reporting['Version'] = "GPOZaurr Current/Latest: $($LatestVersion.Version) at $($LatestVersion.PublishDate)"
        } elseif ($GPOZaurrVersion.Version -lt $LatestVersion.Version) {
            $Script:Reporting['Version'] = "GPOZaurr Current: $($GPOZaurrVersion.Version), Published: $($LatestVersion.Version) at $($LatestVersion.PublishDate). Update?"
        } elseif ($GPOZaurrVersion.Version -gt $LatestVersion.Version) {
            $Script:Reporting['Version'] = "GPOZaurr Current: $($GPOZaurrVersion.Version), Published: $($LatestVersion.Version) at $($LatestVersion.PublishDate). Lucky you!"
        }
    } else {
        $Script:Reporting['Version'] = "GPOZaurr Current: $($GPOZaurrVersion.Version)"
    }

    # Gather data
    $TimeLog = Start-TimeLog
    if ($Type -contains 'GPOList' -or $null -eq $Type) {
        $TimeLogGPOList = Start-TimeLog
        Write-Verbose -Message "Show-GPOZaurr - Processing GPO List"
        $GPOSummary = Get-GPOZaurr
        $GPOLinkedStatus = $GPOSummary.Where( { $_.Linked -eq $true }, 'split')
        [Array] $GPONotLinked = $GPOLinkedStatus[1]
        [Array] $GPOLinked = $GPOLinkedStatus[0]
        $GPOEmptyStatus = $GPOSummary.Where( { $_.Empty -eq $true }, 'split' )
        [Array] $GPOEmpty = $GPOEmptyStatus[0]
        [Array] $GPONotEmpty = $GPOEmptyStatus[1]
        $GPOTotal = $GPOSummary.Count
        $TimeEndGPOList = Stop-TimeLog -Time $TimeLog -Option OneLiner
    }
    if ($Type -contains 'GPOOrphans' -or $null -eq $Type) {
        #Write-Color -Text "[Info] ", "Processing GPOOrphans" -Color Yellow, White
        Write-Verbose -Message "Show-GPOZaurr - Processing GPO Sysvol"
        $GPOOrphans = Get-GPOZaurrBroken

        $NotAvailableInAD = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NotAvailableOnSysvol = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NotAvailablePermissionIssue = [System.Collections.Generic.List[PSCustomObject]]::new()
        foreach ($_ in $GPOOrphans) {
            if ($_.Status -eq 'Not available in AD') {
                $NotAvailableInAD.Add($NotAvailableInAD)
            } elseif ($_.Status -eq 'Not available on SYSVOL') {
                $NotAvailableOnSysvol.Add($NotAvailableInAD)
            } elseif ( $_.Status -eq 'Permissions issue') {
                $NotAvailablePermissionIssue.Add($NotAvailableInAD)
            }
        }
    }
    if ($Type -contains 'GPOPermissions' -or $null -eq $Type) {
        #Write-Color -Text "[Info] ", "Processing GPOPermissions" -Color Yellow, White
        Write-Verbose -Message "Show-GPOZaurr - Processing GPO Permissions"
        $GPOPermissions = Get-GPOZaurrPermission -Type All -IncludePermissionType GpoEditDeleteModifySecurity, GpoEdit, GpoCustom -IncludeOwner
    }
    if ($Type -contains 'GPOConsistency' -or $null -eq $Type) {
        Write-Verbose -Message "Show-GPOZaurr - Processing GPO Permissions Consistency"
        $GPOPermissionsConsistency = Get-GPOZaurrPermissionConsistency -Type All -VerifyInheritance
        [Array] $Inconsistent = $GPOPermissionsConsistency.Where( { $_.ACLConsistent -eq $true } , 'split' )
        [Array] $InconsistentInside = $GPOPermissionsConsistency.Where( { $_.ACLConsistentInside -eq $true }, 'split' )
    }
    if ($Type -contains 'GPOPermissionsRoot' -or $null -eq $Type) {
        Write-Verbose -Message "Show-GPOZaurr - Processing GPO Permissions Root"
        $GPOPermissionsRoot = Get-GPOZaurrPermissionRoot
    }
    if ($Type -contains 'GPOOwners' -or $null -eq $Type) {
        Write-Verbose "Show-GPOZaurr - Processing GPO Owners"
        $GPOOwners = Get-GPOZaurrOwner -IncludeSysvol
        $IsOwnerConsistent = $GPOOwners.Where( { $_.IsOwnerConsistent -eq $true } , 'split' )
        $IsOwnerAdministrative = $GPOOwners.Where( { $_.IsOwnerAdministrative -eq $true } , 'split' )
    }
    if ($Type -contains 'NetLogon' -or $null -eq $Type) {
        Write-Verbose "Get-GPOZaurrNetLogon - Processing NETLOGON Share"
        $Netlogon = Get-GPOZaurrNetLogon
    }
    if ($Type -contains 'GPOAnalysis' -or $null -eq $Type) {
        Write-Verbose "Show-GPOZaurr - Processing GPO Analysis"
        $GPOContent = Invoke-GPOZaurr
    }
    if ($Type -contains 'GPOFiles') {
        Write-Verbose "Show-GPOZaurr - Processing GPOFiles"
        $GPOFiles = Get-GPOZaurrFiles
    }
    $TimeEnd = Stop-TimeLog -Time $TimeLog -Option OneLiner

    # Generate pretty HTML
    Write-Verbose "Show-GPOZaurr - Generating HTML"
    New-HTML {
        New-HTMLTabStyle -BorderRadius 0px -TextTransform capitalize -BackgroundColorActive SlateGrey
        New-HTMLSectionStyle -BorderRadius 0px -HeaderBackGroundColor Grey -RemoveShadow
        New-HTMLPanelStyle -BorderRadius 0px
        New-HTMLTableOption -DataStore JavaScript -BoolAsString

        New-HTMLHeader {
            New-HTMLSection -Invisible {
                New-HTMLSection {
                    New-HTMLText -Text "Report generated on $(Get-Date)" -Color Blue
                } -JustifyContent flex-start -Invisible
                New-HTMLSection {
                    New-HTMLText -Text $Script:Reporting['Version'] -Color Blue
                } -JustifyContent flex-end -Invisible
            }
        }

        New-HTMLTab -Name 'Overview' {
            if ($Type -contains 'GPOConsistency' -or $Type -contains 'GPOList' -or $null -eq $Type) {
                New-HTMLSection -Invisible {
                    if ($Type -contains 'GPOList' -or $null -eq $Type) {
                        New-HTMLPanel {
                            New-HTMLText -Text 'Following chart presents ', 'Linked / Empty and Unlinked Group Policies' -FontSize 10pt -FontWeight normal, bold
                            New-HTMLList -Type Unordered {
                                New-HTMLListItem -Text 'Group Policies total: ', $GPOTotal -FontWeight normal, bold
                                New-HTMLListItem -Text 'Group Policies linked: ', $GPOLinked.Count -FontWeight normal, bold
                                New-HTMLListItem -Text 'Group Policies that are unlinked (are not doing anything currently): ', $GPONotLinked.Count -FontWeight normal, bold
                                New-HTMLListItem -Text "Group Policies that are empty (have no settings): ", $GPOEmpty.Count -FontWeight normal, bold
                            } -FontSize 10pt
                            New-HTMLText -FontSize 10pt -Text 'Usually empty or unlinked Group Policies are safe to delete.'
                            New-HTMLChart -Title 'Group Policies Summary' {
                                New-ChartBarOptions -Type barStacked
                                #New-ChartLegend -Names 'Unlinked', 'Linked', 'Empty', 'Total' -Color Salmon, PaleGreen, PaleVioletRed, PaleTurquoise
                                New-ChartLegend -Names 'Bad', 'Good' -Color PaleGreen, Salmon
                                #New-ChartBar -Name 'Group Policies' -Value $GPONotLinked.Count, $GPOLinked.Count, $GPOEmpty.Count, $GPOTotal
                                New-ChartBar -Name 'Linked' -Value $GPOLinked.Count, $GPONotLinked.Count
                                New-ChartBar -Name 'Empty' -Value $GPONotEmpty.Count, $GPOEmpty.Count
                            } -TitleAlignment center
                        }
                    }
                    if ($Type -contains 'GPOConsistency' -or $null -eq $Type) {
                        New-HTMLPanel {
                            New-HTMLText -Text 'Following chart presents ', 'permissions consistency between Active Directory and SYSVOL for Group Policies' -FontSize 10pt -FontWeight normal, bold
                            New-HTMLList -Type Unordered {
                                New-HTMLListItem -Text 'Top level permissions consistency: ', $Inconsistent[0].Count -FontWeight normal, bold
                                New-HTMLListItem -Text 'Inherited permissions consistency: ', $InconsistentInside[0].Count -FontWeight normal, bold
                                New-HTMLListItem -Text 'Inconsistent top level permissions: ', $Inconsistent[1].Count -FontWeight normal, bold
                                New-HTMLListItem -Text "Inconsistent inherited permissions: ", $InconsistentInside[1].Count -FontWeight normal, bold
                            } -FontSize 10pt
                            New-HTMLText -FontSize 10pt -Text 'Having incosistent permissions on AD in comparison to those on SYSVOL can lead to uncontrolled ability to modify them.'
                            New-HTMLChart {
                                New-ChartLegend -Names 'Bad', 'Good' -Color PaleGreen, Salmon
                                New-ChartBarOptions -Type barStacked
                                New-ChartLegend -Name 'Consistent', 'Inconsistent'
                                New-ChartBar -Name 'TopLevel' -Value $Inconsistent[0].Count, $Inconsistent[1].Count
                                New-ChartBar -Name 'Inherited' -Value $InconsistentInside[0].Count, $InconsistentInside[1].Count
                            } -Title 'Permissions Consistency' -TitleAlignment center
                        }
                    }
                }
            }
            if ($Type -contains 'GPOOwners' -or $Type -contains 'GPOOrphans' -or $null -eq $Type) {
                New-HTMLSection -Invisible {
                    if ($Type -contains 'GPOOwners' -or $null -eq $Type) {
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
                    }
                    if ($Type -contains 'GPOOrphans' -or $null -eq $Type) {
                        New-HTMLPanel {
                            New-HTMLText -Text 'Following chart presents ', 'Broken / Orphaned Group Policies' -FontSize 10pt -FontWeight normal, bold
                            New-HTMLList -Type Unordered {
                                New-HTMLListItem -Text 'Group Policies on SYSVOL, but no details in AD: ', $NotAvailableInAD.Count -FontWeight normal, bold
                                New-HTMLListItem -Text 'Group Policies in AD, but no content on SYSVOL: ', $NotAvailableOnSysvol.Count -FontWeight normal, bold
                                New-HTMLListItem -Text "Group Policies which couldn't be assed due to permissions issue: ", $NotAvailablePermissionIssue.Count -FontWeight normal, bold
                            } -FontSize 10pt
                            New-HTMLText -FontSize 10pt -Text 'Those problems must be resolved before doing other clenaup activities.'
                            New-HTMLChart {
                                New-ChartBarOptions -Type barStacked
                                New-ChartLegend -Name 'Not in AD', 'Not on SYSVOL', 'Permissions Issue' -Color Crimson, LightCoral, IndianRed
                                New-ChartBar -Name 'Orphans' -Value $NotAvailableInAD.Count, $NotAvailableOnSysvol.Count, $NotAvailablePermissionIssue.Count
                            } -Title 'Broken / Orphaned Group Policies' -TitleAlignment center
                        }
                    }
                }
            }
        }
        if ($Type -contains 'GPOList' -or $null -eq $Type) {
            New-HTMLTab -Name 'Group Policies Summary' {
                New-HTMLPanel {
                    New-HTMLText -Text 'Following table shows a list of group policies. ', 'By using following table you can easily find which GPOs can be safely deleted because those are empty or unlinked.' -FontSize 10pt -FontWeight normal, bold
                    New-HTMLList -Type Unordered {
                        New-HTMLListItem -Text 'Group Policies total: ', $GPOTotal -FontWeight normal, bold
                        New-HTMLListItem -Text 'Group Policies linked: ', $GPOLinked.Count -FontWeight normal, bold
                        New-HTMLListItem -Text 'Group Policies that are unlinked (are not doing anything currently): ', $GPONotLinked.Count -FontWeight normal, bold
                        New-HTMLListItem -Text "Group Policies that are empty (have no settings): ", $GPOEmpty.Count -FontWeight normal, bold
                    } -FontSize 10pt
                }
                New-HTMLSection -Name 'Group Policies List' {
                    New-HTMLTable -DataTable $GPOSummary -Filtering {
                        New-HTMLTableCondition -Name 'Empty' -Value $true -BackgroundColor Salmon -TextTransform capitalize -ComparisonType string
                        New-HTMLTableCondition -Name 'Linked' -Value $false -BackgroundColor Salmon -TextTransform capitalize -ComparisonType string
                    } -PagingOptions 10, 20, 30, 40, 50
                }
                New-HTMLSection -Name 'Steps to fix - Empty & Unlinked Group Policies' {
                    New-HTMLContainer {
                        New-HTMLSpanStyle -FontSize 10pt {
                            New-HTMLText -Text 'Following steps will guide you how to remove empty or unlinked group policies'
                            New-HTMLWizard {
                                New-HTMLWizardStep {

                                }
                            } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                        }
                    }
                }
            }
        }
        if ($Type -contains 'GPOOrphans' -or $null -eq $Type) {
            New-HTMLTab -Name 'Health State' {
                New-HTMLPanel {
                    New-HTMLText -TextBlock {
                        "Following table shows list of all group policies and their status in AD and SYSVOL. Due to different reasons it's "
                        "possible that "
                    } -FontSize 10pt
                    New-HTMLList -Type Unordered {
                        New-HTMLListItem -Text 'Group Policies on SYSVOL, but no details in AD: ', $NotAvailableInAD.Count -FontWeight normal, bold
                        New-HTMLListItem -Text 'Group Policies in AD, but no content on SYSVOL: ', $NotAvailableOnSysvol.Count -FontWeight normal, bold
                        New-HTMLListItem -Text "Group Policies which couldn't be assed due to permissions issue: ", $NotAvailablePermissionIssue.Count -FontWeight normal, bold
                    } -FontSize 10pt
                    New-HTMLText -Text "Follow the steps below table to get Active Directory Group Policies in healthy state." -FontSize 10pt
                }
                New-HTMLSection -Name 'Health State of Group Policies' {
                    New-HTMLTable -DataTable $GPOOrphans -Filtering {
                        New-HTMLTableCondition -Name 'Status' -Value "Not available in AD" -BackgroundColor Salmon -ComparisonType string
                        New-HTMLTableCondition -Name 'Status' -Value "Not available on SYSVOL" -BackgroundColor LightCoral -ComparisonType string
                        New-HTMLTableCondition -Name 'Status' -Value "Permissions issue" -BackgroundColor MediumVioletRed -ComparisonType string -Color White
                    } -PagingOptions 10, 20, 30, 40, 50
                }
                New-HTMLSection -Name 'Steps to fix - Not available on SYSVOL / Active Directory' {
                    New-HTMLContainer {
                        New-HTMLSpanStyle -FontSize 10pt {
                            New-HTMLText -Text 'Following steps will guide you how to fix GPOs which are not available on SYSVOL or AD.'
                            New-HTMLWizard {
                                New-HTMLWizardStep -Name 'Prepare environment' {
                                    New-HTMLText -Text "To be able to execute actions in automated way please install required modules. Those modules will be installed straight from Microsoft PowerShell Gallery."
                                    New-HTMLCodeBlock -Code {
                                        Install-Module GPOZaurr -Force
                                        Import-Module GPOZaurr -Force
                                    } -Style powershell
                                    New-HTMLText -Text "Using force makes sure newest version is downloaded from PowerShellGallery regardless of what is currently installed. Once installed you're ready for next step."
                                }
                                New-HTMLWizardStep -Name 'Prepare report' {
                                    New-HTMLText -Text "Depending when this report was run you may want to prepare new report before proceeding with removal. To generate new report please use:"
                                    New-HTMLCodeBlock -Code {
                                        Show-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrBrokenGpoBefore.html -Verbose -Type GPOOrphans
                                    }
                                    New-HTMLText -Text {
                                        "When executed it will take a while to generate all data and provide you with new report depending on size of environment."
                                        "Once confirmed that data is still showing issues and requires fixing please proceed with next step."
                                    }
                                    New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                                    New-HTMLCodeBlock -Code {
                                        $GPOOutput = Get-GPOZaurrBroken
                                        $GPOOutput | Format-Table
                                    }
                                    New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
                                }
                                New-HTMLWizardStep -Name 'Fix GPOs not available on SYSVOL' {
                                    New-HTMLText -Text "Following command when executed runs cleanup procedure that removes all broken GPOs on SYSVOL side."
                                    New-HTMLText -Text "Make sure when running it for the first time to run it with ", "WhatIf", " parameter as shown below to prevent accidental removal." -FontWeight normal, bold, normal -Color Black, Red, Black

                                    New-HTMLCodeBlock -Code {
                                        Remove-GPOZaurrBroken -Type SYSVOL -WhatIf
                                    }
                                    New-HTMLText -TextBlock {
                                        "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be deleted matches expected data. Once happy with results please follow with command: "
                                    }
                                    New-HTMLCodeBlock -Code {
                                        Remove-GPOZaurrBroken -Type SYSVOL -LimitProcessing 2 -BackupPath $Env:UserProfile\Desktop\GPOSYSVOLBackup
                                    }
                                    New-HTMLText -TextBlock {
                                        "This command when executed deletes only first X broken GPOs. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur."
                                        "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
                                    }
                                    New-HTMLText -Text "If there's nothing else to be deleted on SYSVOL side, we can skip to next step step"
                                }
                                New-HTMLWizardStep -Name 'Fix GPOs not available on AD' {
                                    New-HTMLText -Text "Following command when executed runs cleanup procedure that removes all broken GPOs on Active Directory side."
                                    New-HTMLText -Text "Make sure when running it for the first time to run it with ", "WhatIf", " parameter as shown below to prevent accidental removal." -FontWeight normal, bold, normal -Color Black, Red, Black

                                    New-HTMLCodeBlock -Code {
                                        Remove-GPOZaurrBroken -Type AD -WhatIf
                                    }
                                    New-HTMLText -TextBlock {
                                        "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be deleted matches expected data. Once happy with results please follow with command: "
                                    }
                                    New-HTMLCodeBlock -Code {
                                        Remove-GPOZaurrBroken -Type AD -LimitProcessing 2 -BackupPath $Env:UserProfile\Desktop\GPOSYSVOLBackup
                                    }
                                    New-HTMLText -TextBlock {
                                        "This command when executed deletes only first X broken GPOs. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur."
                                        "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
                                    }
                                    New-HTMLText -Text "If there's nothing else to be deleted on AD side, we can skip to next step step"
                                }
                                New-HTMLWizardStep -Name 'Verification report' {
                                    New-HTMLText -TextBlock {
                                        "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                                    }
                                    New-HTMLCodeBlock -Code {
                                        Show-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrBrokenGpoAfter.html -Verbose -Type GPOOrphans
                                    }
                                    New-HTMLText -Text "If everything is health in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                                }
                            } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                        }
                    }
                }
            }
        }
        if ($Type -contains 'NetLogon' -or $null -eq $Type) {
            New-HTMLTab -Name 'NetLogon' {
                New-HTMLTable -DataTable $Netlogon -Filtering
            }
        }
        if ($Type -contains 'GPOPermissionsRoot' -or $Type -contains 'GPOOwners' -or
            $Type -contains 'GPOPermissions' -or $Type -contains 'GPOConsistency' -or
            $null -eq $Type
        ) {
            New-HTMLTab -Name 'Permissions' {
                if ($Type -contains 'GPOPermissionsRoot' -or $null -eq $Type) {
                    New-HTMLTab -Name 'Root' {
                        New-HTMLTable -DataTable $GPOPermissionsRoot -Filtering
                    }
                }
                if ($Type -contains 'GPOOwners' -or $null -eq $Type) {
                    New-HTMLTab -Name 'Owners' {
                        New-HTMLTable -DataTable $GPOOwners -Filtering
                    }
                }
                if ($Type -contains 'GPOPermissions' -or $null -eq $Type) {
                    New-HTMLTab -Name 'Edit & Modify' {
                        New-HTMLTable -DataTable $GPOPermissions -Filtering
                    }
                }
                if ($Type -contains 'GPOConsistency' -or $null -eq $Type) {
                    New-HTMLTab -Name 'Permissions Consistency' {
                        New-HTMLPanel {
                            New-HTMLText -Text 'Following table presents ', 'permissions consistency between Active Directory and SYSVOL for Group Policies' -FontSize 10pt -FontWeight normal, bold
                            New-HTMLList -Type Unordered {
                                New-HTMLListItem -Text 'Top level permissions consistency: ', $Inconsistent[0].Count -FontWeight normal, bold
                                New-HTMLListItem -Text 'Inherited permissions consistency: ', $InconsistentInside[0].Count -FontWeight normal, bold
                                New-HTMLListItem -Text 'Inconsistent top level permissions: ', $Inconsistent[1].Count -FontWeight normal, bold
                                New-HTMLListItem -Text "Inconsistent inherited permissions: ", $InconsistentInside[1].Count -FontWeight normal, bold
                            } -FontSize 10pt
                            New-HTMLText -FontSize 10pt -Text 'Having incosistent permissions on AD in comparison to those on SYSVOL can lead to uncontrolled ability to modify them. Please notice that if ', `
                                ' Not available ', 'is visible in the table you should first fix related, more pressing issue, before fixing permissions inconsistency.' -FontWeight normal, bold, normal
                        }
                        New-HTMLSection -Name 'Group Policy Permissions Consistency' {
                            New-HTMLTable -DataTable $GPOPermissionsConsistency -Filtering {
                                New-HTMLTableCondition -Name 'ACLConsistent' -Value $false -BackgroundColor Salmon -TextTransform capitalize -ComparisonType string
                                New-HTMLTableCondition -Name 'ACLConsistentInside' -Value $false -BackgroundColor Salmon -TextTransform capitalize -ComparisonType string
                                New-HTMLTableCondition -Name 'ACLConsistent' -Value $true -BackgroundColor PaleGreen -TextTransform capitalize -ComparisonType string
                                New-HTMLTableCondition -Name 'ACLConsistentInside' -Value $true -BackgroundColor PaleGreen -TextTransform capitalize -ComparisonType string
                                New-HTMLTableCondition -Name 'ACLConsistent' -Value 'Not available' -BackgroundColor Crimson -ComparisonType string
                                New-HTMLTableCondition -Name 'ACLConsistentInside' -Value 'Not available' -BackgroundColor Crimson -ComparisonType string
                            } -PagingOptions 10, 20, 30, 40, 50
                        }
                        New-HTMLSection -Name 'Steps to fix - Permissions Consistency' {
                            New-HTMLContainer {
                                New-HTMLSpanStyle -FontSize 10pt {
                                    New-HTMLText -Text 'Following steps will guide you how to fix permissions consistency'
                                    New-HTMLWizard {
                                        New-HTMLWizardStep -Name 'Prepare environment' {
                                            New-HTMLText -Text "To be able to execute actions in automated way please install required modules. Those modules will be installed straight from Microsoft PowerShell Gallery."
                                            New-HTMLCodeBlock -Code {
                                                Install-Module GPOZaurr -Force
                                                Import-Module GPOZaurr -Force
                                            } -Style powershell
                                            New-HTMLText -Text "Using force makes sure newest version is downloaded from PowerShellGallery regardless of what is currently installed. Once installed you're ready for next step."
                                        }
                                        New-HTMLWizardStep -Name 'Prepare report' {
                                            New-HTMLText -Text "Depending when this report was run you may want to prepare new report before proceeding fixing permissions inconsistencies. To generate new report please use:"
                                            New-HTMLCodeBlock -Code {
                                                Show-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrPermissionsInconsistentBefore.html -Verbose -Type GPOConsistency
                                            }
                                            New-HTMLText -Text {
                                                "When executed it will take a while to generate all data and provide you with new report depending on size of environment."
                                                "Once confirmed that data is still showing issues and requires fixing please proceed with next step."
                                            }
                                            New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                                            New-HTMLCodeBlock -Code {
                                                $GPOOutput = Get-GPOZaurrPermissionConsistency
                                                $GPOOutput | Format-Table # do your actions as desired
                                            }
                                            New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
                                        }
                                        New-HTMLWizardStep -Name 'Fix inconsistent permissions' {
                                            New-HTMLText -Text "Following command when executed fixes inconsistent permissions."
                                            New-HTMLText -Text "Make sure when running it for the first time to run it with ", "WhatIf", " parameter as shown below to prevent accidental removal." -FontWeight normal, bold, normal -Color Black, Red, Black
                                            New-HTMLText -Text "Make sure to fill in TargetDomain to match your Domain Admin permission account"

                                            New-HTMLCodeBlock -Code {
                                                Repair-GPOZaurrPermissionConsistency -IncludeDomains "TargetDomain" -Verbose -WhatIf
                                            }
                                            New-HTMLText -TextBlock {
                                                "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be deleted matches expected data. Once happy with results please follow with command: "
                                            }
                                            New-HTMLCodeBlock -Code {
                                                Repair-GPOZaurrPermissionConsistency -LimitProcessing 2 -IncludeDomains "TargetDomain"
                                            }
                                            New-HTMLText -TextBlock {
                                                "This command when executed repairs only first X inconsistent permissions. Use LimitProcessing parameter to prevent mass fixing and increase the counter when no errors occur."
                                                "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
                                            }
                                            New-HTMLText -Text "If there's nothing else to be fixed, we can skip to next step step"
                                        }
                                        New-HTMLWizardStep -Name 'Fix inconsistent downlevel permissions' {
                                            New-HTMLText -Text "Unfortunetly this step is manual until automation is developed. "
                                            New-HTMLText -Text "If there are inconsistent permissions found inside GPO one has to fix them manually by going into SYSVOL and making sure inheritance is enabled, and that permissions are consistent across all files."
                                        }
                                        New-HTMLWizardStep -Name 'Verification report' {
                                            New-HTMLText -TextBlock {
                                                "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                                            }
                                            New-HTMLCodeBlock -Code {
                                                Show-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrPermissionsInconsistentAfter.html -Verbose -Type GPOConsistency
                                            }
                                            New-HTMLText -Text "If everything is health in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                                        }
                                    } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                                }
                            }
                        }
                    }
                }
            }
        }
        if ($Type -contains 'GPOAnalysis' -or $null -eq $Type) {
            New-HTMLTab -Name 'Analysis' {
                foreach ($Key in $GPOContent.Keys) {
                    New-HTMLTab -Name $Key {
                        New-HTMLTable -DataTable $GPOContent[$Key] -Filtering -Title $Key
                    }
                }
            }
        }
    } -Online -ShowHTML -FilePath $FilePath
}