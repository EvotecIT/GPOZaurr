function Invoke-GPOZaurr {
    [alias('Show-GPOZaurr', 'Show-GPO')]
    [cmdletBinding()]
    param(
        [string] $FilePath,
        [string[]] $Type
        <#
        [ValidateSet(
            'GPOList', 'GPOOrphans', 'GPOPermissions', 'GPOPermissionsRoot', 'GPOFiles',
            'GPOConsistency', 'GPOOwners', 'GPOAnalysis',
            'NetLogon',
            'LegacyAdm'
        )][string[]] $Type
        #>
    )
    Reset-GPOZaurrStatus # This makes sure types are at it's proper status

    $Script:Reporting = [ordered] @{}
    # Provide version check for easy use
    $GPOZaurrVersion = Get-Command -Name 'Invoke-GPOZaurr' -ErrorAction SilentlyContinue

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

    # Lets disable all current ones
    foreach ($T in $Script:GPOConfiguration.Keys) {
        $Script:GPOConfiguration[$T].Enabled = $false
    }
    foreach ($T in $Type) {
        $Script:GPOConfiguration[$T].Enabled = $true
    }

    foreach ($T in $Script:GPOConfiguration.Keys) {
        if ($Script:GPOConfiguration[$T].Enabled -eq $true) {
            $TimeLogGPOList = Start-TimeLog
            Write-Color -Text '[i]', '[Start] ', $($Script:GPOConfiguration[$T]['Name']) -Color Yellow, DarkGray, Yellow
            $Script:GPOConfiguration[$T]['Data'] = & $Script:GPOConfiguration[$T]['Execute']
            & $Script:GPOConfiguration[$T]['Processing']

            $TimeEndGPOList = Stop-TimeLog -Time $TimeLogGPOList -Option OneLiner
            Write-Color -Text '[i]', '[End  ] ', $($Script:GPOConfiguration[$T]['Name']), " [Time to execute: $TimeEndGPOList]" -Color Yellow, DarkGray, Yellow, DarkGray
        }
    }

    <#
    # Gather data
    $TimeLog = Start-TimeLog
    if ($Type -contains 'GPOList' -or $null -eq $Type) {
        $TimeLogGPOList = Start-TimeLog
        Write-Verbose -Message "Invoke-GPOZaurr - Processing GPO List"
        $GPOSummary = Get-GPOZaurr
        $GPONotLinked = [System.Collections.Generic.List[PSCustomObject]]::new()
        $GPOLinked = [System.Collections.Generic.List[PSCustomObject]]::new()
        $GPOEmpty = [System.Collections.Generic.List[PSCustomObject]]::new()
        $GPONotEmpty = [System.Collections.Generic.List[PSCustomObject]]::new()
        $GPOEmptyAndUnlinked = [System.Collections.Generic.List[PSCustomObject]]::new()
        $GPOEmptyOrUnlinked = [System.Collections.Generic.List[PSCustomObject]]::new()
        $GPOLinkedButEmpty = [System.Collections.Generic.List[PSCustomObject]]::new()
        $GPOValid = [System.Collections.Generic.List[PSCustomObject]]::new()
        $GPOLinkedButLinkDisabled = [System.Collections.Generic.List[PSCustomObject]]::new()
        foreach ($GPO in $GPOSummary) {
            if ($GPO.Linked -eq $false -and $GPO.Empty -eq $true) {
                # Not linked, Empty
                $GPOEmptyAndUnlinked.Add($GPO)
                $GPOEmptyOrUnlinked.Add($GPO)
                $GPONotLinked.Add($GPO)
                $GPOEmpty.Add($GPO)
            } elseif ($GPO.Linked -eq $true -and $GPO.Empty -eq $true) {
                # Linked, But EMPTY
                $GPOLinkedButEmpty.Add($GPO)
                $GPOEmptyOrUnlinked.Add($GPO)
                $GPOEmpty.Add($GPO)
                $GPOLinked.Add($GPO)
            } elseif ($GPO.Linked -eq $false) {
                # Not linked, but not EMPTY
                $GPONotLinked.Add($GPO)
                $GPOEmptyOrUnlinked.Add($GPO)
                $GPONotEmpty.Add($GPO)
            } elseif ($GPO.Empty -eq $true) {
                # Linked, But EMPTY
                $GPOEmpty.Add($GPO)
                $GPOEmptyOrUnlinked.Add($GPO)
                $GPOLinked.Add($GPO)
            } else {
                # Linked, not EMPTY
                $GPOValid.Add($GPO)
                $GPOLinked.Add($GPO)
                $GPONotEmpty.Add($GPO)
            }
            if ($GPO.LinksDisabledCount -eq $GPO.LinksCount -and $GPO.LinksCount -gt 0) {
                $GPOLinkedButLinkDisabled.Add($GPO)
            }
        }
        $GPOTotal = $GPOSummary.Count
        $TimeEndGPOList = Stop-TimeLog -Time $TimeLogGPOList -Option OneLiner
        Write-Verbose -Message "Invoke-GPOZaurr - Processing GPO List $TimeEndGPOList"
    }
    if ($Type -contains 'GPOOrphans' -or $null -eq $Type) {
        #Write-Color -Text "[Info] ", "Processing GPOOrphans" -Color Yellow, White
        Write-Verbose -Message "Invoke-GPOZaurr - Processing GPO Sysvol"
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
        Write-Verbose -Message "Invoke-GPOZaurr - Processing GPO Permissions"
        $GPOPermissions = Get-GPOZaurrPermission -Type All -IncludePermissionType GpoEditDeleteModifySecurity, GpoEdit, GpoCustom -IncludeOwner
    }
    if ($Type -contains 'GPOConsistency' -or $null -eq $Type) {
        Write-Verbose -Message "Invoke-GPOZaurr - Processing GPO Permissions Consistency"
        $Script:GPOZaurrConsistency['Data'] = & $Script:GPOZaurrConsistency['Execute']
        & $Script:GPOZaurrConsistency['Processing']
    }
    if ($Type -contains 'GPOPermissionsRoot' -or $null -eq $Type) {
        Write-Verbose -Message "Invoke-GPOZaurr - Processing GPO Permissions Root"
        $GPOPermissionsRoot = Get-GPOZaurrPermissionRoot -SkipNames
    }
    if ($Type -contains 'GPOOwners' -or $null -eq $Type) {
        $TimeLogGPOList = Start-TimeLog
        Write-Verbose "Invoke-GPOZaurr - Processing GPO Owners"
        $Script:GpoZaurrOwners['Data'] = & $Script:GpoZaurrOwners['Execute']
        & $Script:GpoZaurrOwners['Processing']
        $TimeEndGPOList = Stop-TimeLog -Time $TimeLogGPOList -Option OneLiner
        Write-Verbose -Message "Invoke-GPOZaurr - Processing GPO Owners $TimeEndGPOList"
    }
    if ($Type -contains 'NetLogon' -or $null -eq $Type) {
        $TimeLogSection = Start-TimeLog
        Write-Verbose "Get-GPOZaurrNetLogon - Processing NETLOGON Share"
        $NetLogon = Get-GPOZaurrNetLogon
        $NetLogonOwners = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersAdministrators = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersNotAdministrative = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersAdministrative = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersAdministrativeNotAdministrators = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersToFix = [System.Collections.Generic.List[PSCustomObject]]::new()
        foreach ($File in $Netlogon) {
            if ($File.FileSystemRights -eq 'Owner') {
                $NetLogonOwners.Add($File)

                if ($File.PrincipalType -eq 'WellKnownAdministrative') {
                    $NetLogonOwnersAdministrative.Add($File)
                } elseif ($File.PrincipalType -eq 'Administrative') {
                    $NetLogonOwnersAdministrative.Add($File)
                } else {
                    $NetLogonOwnersNotAdministrative.Add($File)
                }

                if ($File.PrincipalSid -eq 'S-1-5-32-544') {
                    $NetLogonOwnersAdministrators.Add($File)
                } elseif ($File.PrincipalType -in 'WellKnownAdministrative', 'Administrative') {
                    $NetLogonOwnersAdministrativeNotAdministrators.Add($File)
                    $NetLogonOwnersToFix.Add($File)
                } else {
                    $NetLogonOwnersToFix.Add($File)
                }
            }
        }
        $TimeLogSectionEnd = Stop-TimeLog -Time $TimeLogSection -Option OneLiner
        Write-Verbose "Get-GPOZaurrNetLogon - Processing NETLOGON Share $TimeLogSectionEnd"
    }
    if ($Type -contains 'GPOAnalysis' -or $null -eq $Type) {
        Write-Verbose "Invoke-GPOZaurr - Processing GPO Analysis"
        $GPOContent = Invoke-GPOZaurrContent
    }
    if ($Type -contains 'GPOFiles') {
        Write-Verbose "Invoke-GPOZaurr - Processing GPOFiles"
        $GPOFiles = Get-GPOZaurrFiles
    }
    if ($Type -contains 'LegacyADM') {
        Write-Verbose "Invoke-GPOZaurr - Processing GPOFiles"
        $ADMLegacyFiles = Get-GPOZaurrLegacyFiles
    }
    $TimeEnd = Stop-TimeLog -Time $TimeLog -Option OneLiner
    Write-Verbose "Invoke-GPOZaurr - Data gathering time $TimeEnd"
    #>
    # Generate pretty HTML
    Write-Verbose "Invoke-GPOZaurr - Generating HTML"
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

        if ($Type.Count -eq 1) {
            foreach ($T in $Script:GPOConfiguration.Keys) {
                if ($Script:GPOConfiguration[$T].Enabled -eq $true) {
                    if ($Script:GPOConfiguration[$T]['Data']) {
                        & $Script:GPOConfiguration[$T]['Solution']
                    }
                }
            }
        } else {
            New-HTMLTab -Name 'Overview' {
                if ($Type -contains 'GPOConsistency' -or $Type -contains 'GPOList' -or $null -eq $Type) {
                    New-HTMLSection -Invisible {
                        if ($Type -contains 'GPOList' -or $null -eq $Type) {

                            New-HTMLPanel {
                                New-HTMLText -Text 'Following chart presents ', 'Linked / Empty and Unlinked Group Policies' -FontSize 10pt -FontWeight normal, bold
                                New-HTMLList -Type Unordered {
                                    New-HTMLListItem -Text 'Group Policies total: ', $GPOTotal -FontWeight normal, bold
                                    New-HTMLListItem -Text "Group Policies valid: ", $GPOValid.Count -FontWeight normal, bold
                                    New-HTMLListItem -Text "Group Policies to delete: ", $GPOEmptyOrUnlinked.Count -FontWeight normal, bold {
                                        New-HTMLList -Type Unordered {
                                            New-HTMLListItem -Text 'Group Policies that are unlinked (are not doing anything currently): ', $GPONotLinked.Count -FontWeight normal, bold
                                            New-HTMLListItem -Text "Group Policies that are empty (have no settings): ", $GPOEmpty.Count -FontWeight normal, bold
                                            New-HTMLListItem -Text "Group Policies that are linked, but empty: ", $GPOLinkedButEmpty.Count -FontWeight normal, bold
                                            New-HTMLListItem -Text "Group Policies that are linked, but link disabled: ", $GPOLinkedButLinkDisabled.Count -FontWeight normal, bold
                                        }
                                    }
                                } -FontSize 10pt
                                New-HTMLText -FontSize 10pt -Text 'Usually empty or unlinked Group Policies are safe to delete.'
                                New-HTMLChart -Title 'Group Policies Summary' {
                                    New-ChartBarOptions -Type barStacked
                                    #New-ChartLegend -Names 'Unlinked', 'Linked', 'Empty', 'Total' -Color Salmon, PaleGreen, PaleVioletRed, PaleTurquoise
                                    New-ChartLegend -Names 'Good', 'Bad' -Color PaleGreen, Salmon
                                    #New-ChartBar -Name 'Group Policies' -Value $GPONotLinked.Count, $GPOLinked.Count, $GPOEmpty.Count, $GPOTotal
                                    New-ChartBar -Name 'Linked' -Value $GPOLinked.Count, $GPONotLinked.Count
                                    New-ChartBar -Name 'Empty' -Value $GPONotEmpty.Count, $GPOEmpty.Count
                                    New-ChartBar -Name 'Valid' -Value $GPOValid.Count, $GPOEmptyOrUnlinked.Count
                                } -TitleAlignment center
                            }

                        }
                        if ($Type -contains 'GPOConsistency' -or $null -eq $Type) {
                            if ($Script:GPOZaurrConsistency['Overview']) {
                                & $Script:GPOZaurrConsistency['Overview']
                            }
                        }
                    }
                }
                if ($Type -contains 'GPOOwners' -or $Type -contains 'GPOOrphans' -or $null -eq $Type) {
                    New-HTMLSection -Invisible {
                        if ($Type -contains 'GPOOwners' -or $null -eq $Type) {
                            if ($Script:GpoZaurrOwners['Overview']) {
                                & $Script:GpoZaurrOwners['Overview']
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
                if ($Type -contains 'NetLogon' -or $null -eq $Type) {
                    New-HTMLSection -Invisible {
                        New-HTMLPanel {
                            New-HTMLText -Text 'Following chart presents ', 'NetLogon Summary' -FontSize 10pt -FontWeight normal, bold
                            New-HTMLList -Type Unordered {
                                & $Script:GPOConfiguration['NetLogon']['List']
                            } -FontSize 10pt
                            #New-HTMLText -FontSize 10pt -Text 'Those problems must be resolved before doing other clenaup activities.'
                            New-HTMLChart {
                                New-ChartPie -Name 'Correct Owners' -Value $NetLogonOwnersAdministrators.Count -Color LightGreen
                                New-ChartPie -Name 'Incorrect Owners' -Value $NetLogonOwnersToFix.Count -Color Crimson
                            } -Title 'NetLogon Owners' -TitleAlignment center
                        }
                        New-HTMLPanel {

                        }
                    }
                }
            }

            if ($Type -contains 'GPOList' -or $null -eq $Type) {
                New-HTMLTab -Name 'Group Policies Summary' {
                    New-HTMLPanel {
                        $newHTMLTextSplat = @{
                            Text       = @(
                                'Following table shows a list of group policies.',
                                'By using following table you can easily find which GPOs can be safely deleted because those are empty or unlinked or linked, but link disabled.'
                            )
                            FontSize   = '10pt'
                            FontWeight = 'normal', 'bold'
                        }
                        New-HTMLText @newHTMLTextSplat
                        New-HTMLList -Type Unordered {
                            New-HTMLListItem -Text 'Group Policies total: ', $GPOTotal -FontWeight normal, bold
                            New-HTMLListItem -Text "Group Policies valid: ", $GPOValid.Count -FontWeight normal, bold
                            New-HTMLListItem -Text "Group Policies to delete: ", $GPOEmptyOrUnlinked.Count -FontWeight normal, bold {
                                New-HTMLList -Type Unordered {
                                    New-HTMLListItem -Text 'Group Policies that are unlinked (are not doing anything currently): ', $GPONotLinked.Count -FontWeight normal, bold
                                    New-HTMLListItem -Text "Group Policies that are empty (have no settings): ", $GPOEmpty.Count -FontWeight normal, bold
                                    New-HTMLListItem -Text "Group Policies that are linked, but empty: ", $GPOLinkedButEmpty.Count -FontWeight normal, bold
                                    New-HTMLListItem -Text "Group Policies that are linked, but link disabled: ", $GPOLinkedButLinkDisabled.Count -FontWeight normal, bold
                                }
                            }
                        } -FontSize 10pt
                        New-HTMLText -Text 'All those mentioned Group Policies can be automatically deleted following the steps below the table.' -FontSize 10pt
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
                                    & $Script:GPOConfiguration['GPOList']['Wizard']
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
                                    & $Script:GPOConfiguration['GPOOrphans']['Wizard']
                                } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                            }
                        }
                    }
                }
            }
            if ($Type -contains 'NetLogon' -or $Type -contains 'GPOFiles' -or $null -eq $Type) {
                New-HTMLTab -Name 'Files (SysVol / NetLogon)' {
                    if ($Type -contains 'NetLogon' -or $null -eq $Type) {
                        New-HTMLTab -Name 'NetLogon Owners' {
                            New-HTMLPanel {
                                New-HTMLText -TextBlock {
                                    "Following table shows NetLogon file owners. It's important that NetLogon file owners are set to BUILTIN\Administrators (SID: S-1-5-32-544). "
                                    "Owners have full control over the file object. Current owner of the file may be an Administrator but it doesn't guarentee that he will be in the future. "
                                    "That's why as a best-practice it's recommended to change any non-administrative owners to BUILTIN\Administrators, and even Administrative accounts should be replaced with it. "
                                } -FontSize 10pt
                                New-HTMLList -Type Unordered {
                                    & $Script:GPOConfiguration['NetLogon']['List']
                                } -FontSize 10pt
                                New-HTMLText -Text "Follow the steps below table to get NetLogon Owners into compliant state." -FontSize 10pt
                            }
                            New-HTMLSection -Name 'NetLogon Files List' {
                                New-HTMLTable -DataTable $NetLogonOwners -Filtering {
                                    New-HTMLTableCondition -Name 'PrincipalSid' -Value "S-1-5-32-544" -BackgroundColor LightGreen -ComparisonType string
                                    New-HTMLTableCondition -Name 'PrincipalSid' -Value "S-1-5-32-544" -BackgroundColor Salmon -ComparisonType string -Operator ne
                                    New-HTMLTableCondition -Name 'PrincipalType' -Value "WellKnownAdministrative" -BackgroundColor LightGreen -ComparisonType string -Operator eq
                                }
                            }
                            New-HTMLSection -Name 'Steps to fix NetLogon Owners ' {
                                New-HTMLContainer {
                                    New-HTMLSpanStyle -FontSize 10pt {
                                        New-HTMLText -Text 'Following steps will guide you how to fix NetLogon Owners and make them compliant.'
                                        New-HTMLWizard {
                                            & $Script:GPOConfiguration['NetLogon']['Wizard']
                                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                                    }
                                }
                            }

                        }
                        New-HTMLTab -Name 'NetLogon Permissions' {
                            New-HTMLSection -Name 'NetLogon Files List' {
                                New-HTMLTable -DataTable $Netlogon -Filtering
                            }
                        }
                    }
                    if ($Type -contains 'GPOFiles' -or $null -eq $Type) {
                        New-HTMLTab -Name 'SysVol Files Assesment' {
                            New-HTMLTable -DataTable $GPOFiles -Filtering
                        }
                    }
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
                            if ($Script:GpoZaurrOwners['Solution']) {
                                & $Script:GpoZaurrOwners['Solution']
                            }
                        }
                    }
                    if ($Type -contains 'GPOPermissions' -or $null -eq $Type) {
                        New-HTMLTab -Name 'Edit & Modify' {
                            New-HTMLTable -DataTable $GPOPermissions -Filtering
                        }
                    }
                    if ($Type -contains 'GPOConsistency' -or $null -eq $Type) {
                        New-HTMLTab -Name 'Permissions Consistency' {
                            if ($Script:GPOZaurrConsistency['Solution']) {
                                & $Script:GPOZaurrConsistency['Solution']
                            }
                            <#
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
                                        & $Script:GPOConfiguration['GPOConsistency']['Wizard']
                                    } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                                }
                            }
                        }
                        #>
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
        }
    } -Online -ShowHTML -FilePath $FilePath


    Reset-GPOZaurrStatus # This makes sure types are at it's proper status
}

[scriptblock] $SourcesAutoCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $Script:GPOConfiguration.Keys | Sort-Object | Where-Object { $_ -like "*$wordToComplete*" }
}

Register-ArgumentCompleter -CommandName Invoke-GPOZaurr -ParameterName Type -ScriptBlock $SourcesAutoCompleter