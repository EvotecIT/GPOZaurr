$GPOZaurrOwners = [ordered] @{
    Name           = 'Group Policy Owners'
    Enabled        = $true
    ActionRequired = $null
    Data           = $null
    Execute        = { Get-GPOZaurrOwner -IncludeSysvol }
    Processing     = {
        # Create Per Domain Variables
        $Script:Reporting['GPOOwners']['Variables']['RequiresDiffFixPerDomain'] = @{}
        $Script:Reporting['GPOOwners']['Variables']['WillFixPerDomain'] = @{}
        foreach ($GPO in $Script:Reporting['GPOOwners']['Data']) {
            # Create Per Domain Variables
            if (-not $Script:Reporting['GPOOwners']['Variables']['RequiresDiffFixPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOOwners']['Variables']['RequiresDiffFixPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOOwners']['Variables']['WillFixPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOOwners']['Variables']['WillFixPerDomain'][$GPO.DomainName] = 0
            }
            # Checks
            if ($GPO.IsOwnerConsistent) {
                $Script:Reporting['GPOOwners']['Variables']['IsConsistent']++
            } else {
                $Script:Reporting['GPOOwners']['Variables']['IsNotConsistent']++
            }
            if ($GPO.IsOwnerAdministrative) {
                $Script:Reporting['GPOOwners']['Variables']['IsAdministrative']++
            } else {
                $Script:Reporting['GPOOwners']['Variables']['IsNotAdministrative']++
            }
            if (($GPO.IsOwnerAdministrative -eq $false -or $GPO.IsOwnerConsistent -eq $false) -and $GPO.SysvolExists -eq $true) {
                $Script:Reporting['GPOOwners']['Variables']['WillFix']++
                $Script:Reporting['GPOOwners']['Variables']['WillFixPerDomain'][$GPO.DomainName]++
            } elseif ($GPO.SysvolExists -eq $false) {
                $Script:Reporting['GPOOwners']['Variables']['RequiresDiffFix']++
                $Script:Reporting['GPOOwners']['Variables']['RequiresDiffFixPerDomain'][$GPO.DomainName]++
            } else {
                $Script:Reporting['GPOOwners']['Variables']['WillNotTouch']++
            }
        }
        if ($Script:Reporting['GPOOwners']['Variables']['WillFix'].Count -gt 0) {
            $Script:Reporting['GPOOwners']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOOwners']['ActionRequired'] = $false
        }
    }
    Variables      = @{
        IsAdministrative         = 0
        IsNotAdministrative      = 0
        IsConsistent             = 0
        IsNotConsistent          = 0
        WillFix                  = 0
        RequiresDiffFix          = 0
        WillNotTouch             = 0
        RequiresDiffFixPerDomain = $null
        WillFixPerDomain         = $null
    }
    Overview       = {
        <#
        New-HTMLPanel {
            New-HTMLText -Text 'Following chart presents Group Policy owners and whether they are administrative and consistent. By design an owner of Group Policy should be Domain Admins or Enterprise Admins group only to prevent malicious takeover. ', `
                "It's also important that owner in Active Directory matches owner on SYSVOL (file system)." -FontSize 10pt
            New-HTMLList -Type Unordered {
                New-HTMLListItem -Text 'Administrative Owners: ', $Script:Reporting['GPOOwners']['Variables']['IsAdministrative'] -FontWeight normal, bold
                New-HTMLListItem -Text 'Non-Administrative Owners: ', $Script:Reporting['GPOOwners']['Variables']['IsNotAdministrative'] -FontWeight normal, bold
                New-HTMLListItem -Text "Owners consistent in AD and SYSVOL: ", $Script:Reporting['GPOOwners']['Variables']['IsConsistent'] -FontWeight normal, bold
                New-HTMLListItem -Text "Owners not-consistent in AD and SYSVOL: ", $Script:Reporting['GPOOwners']['Variables']['IsNotConsistent'] -FontWeight normal, bold
            } -FontSize 10pt
            New-HTMLChart {
                New-ChartBarOptions -Type barStacked
                New-ChartLegend -Name 'Yes', 'No' -Color PaleGreen, Orchid
                New-ChartBar -Name 'Is administrative' -Value $Script:Reporting['GPOOwners']['Variables']['IsAdministrative'], $Script:Reporting['GPOOwners']['Variables']['IsNotAdministrative']
                New-ChartBar -Name 'Is consistent' -Value $Script:Reporting['GPOOwners']['Variables']['IsConsistent'], $Script:Reporting['GPOOwners']['Variables']['IsNotConsistent']
            } -Title 'Group Policy Owners' -TitleAlignment center
        }
        #>
    }
    Summary        = {
        New-HTMLText -FontSize 10pt -TextBlock {
            "By default GPO creation is usually maintained by Domain Admins or Enterprise Admins. "
            "When GPO is created by member of Domain Admins or Enterprise Admins group the GPO Owner is set to Domain Admins. "
            "When GPO is created by member of Group Policy Creator Owners or other group has delegated rights to create a GPO the owner of said GPO is not Domain Admins group but is assigned to relevant user. "
            "GPO Owners should be Domain Admins or Enterprise Admins to prevent abuse. If that isn't so it means owner is able to fully control GPO and potentially change it's settings in uncontrolled way. "
            "While at the moment of creation of new GPO it's not a problem, in long term it's possible such person may no longer be admin, yet keep their rights over GPO. "
        }
        New-HTMLText -FontSize 10pt -TextBlock {
            "As you're aware Group Policies are stored in 2 places. In Active Directory (metadata) and SYSVOL (settings). This means that there are 2 places where GPO Owners exists. "
            "This also means that for multiple reasons AD and SYSVOL can be out of sync when it comes to their permissions which can lead to uncontrolled ability to modify them. "
            "Ownership in Active Directory and Ownership of SYSVOL for said GPO are required to be the same. "
        }
        New-HTMLText -Text "Here's a short summary of ", "Group Policy Owners", ": " -FontSize 10pt -FontWeight normal, bold, normal
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Administrative Owners: ', $Script:Reporting['GPOOwners']['Variables']['IsAdministrative'] -FontWeight normal, bold
            New-HTMLListItem -Text 'Non-Administrative Owners: ', $Script:Reporting['GPOOwners']['Variables']['IsNotAdministrative'] -FontWeight normal, bold
            New-HTMLListItem -Text "Owners consistent in AD and SYSVOL: ", $Script:Reporting['GPOOwners']['Variables']['IsConsistent'] -FontWeight normal, bold
            New-HTMLListItem -Text "Owners not-consistent in AD and SYSVOL: ", $Script:Reporting['GPOOwners']['Variables']['IsNotConsistent'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -FontSize 10pt -Text "Following will need to happen: " -FontWeight bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies requiring owner change: ', $Script:Reporting['GPOOwners']['Variables']['WillFix'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies which can't be fixed (no SYSVOL?): ", $Script:Reporting['GPOOwners']['Variables']['RequiresDiffFix'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies unaffected: ", $Script:Reporting['GPOOwners']['Variables']['WillNotTouch'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOOwners']['Variables']['WillFixPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOOwners']['Variables']['WillFixPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
        } -FontSize 10pt
        New-HTMLText -Text 'Following domains require fixing using, ', 'different methods:' -FontSize 10pt -FontWeight bold, bold -Color Black, RedRobin -TextDecoration none, underline
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOOwners']['Variables']['RequiresDiffFixPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOOwners']['Variables']['RequiresDiffFixPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
        } -FontSize 10pt
    }
    Solution       = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPOOwners']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartBarOptions -Type barStacked
                    New-ChartLegend -Name 'Yes', 'No' -Color LightGreen, Salmon
                    New-ChartBar -Name 'Is administrative' -Value $Script:Reporting['GPOOwners']['Variables']['IsAdministrative'], $Script:Reporting['GPOOwners']['Variables']['IsNotAdministrative']
                    New-ChartBar -Name 'Is consistent' -Value $Script:Reporting['GPOOwners']['Variables']['IsConsistent'], $Script:Reporting['GPOOwners']['Variables']['IsNotConsistent']
                } -Title 'Group Policy Owners' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policy Owners' {
            New-HTMLTable -DataTable $Script:Reporting['GPOOwners']['Data'] -Filtering {
                New-HTMLTableCondition -Name 'IsOwnerConsistent' -Value $false -BackgroundColor Salmon -ComparisonType string -Row
                New-HTMLTableCondition -Name 'IsOwnerAdministrative' -Value $false -BackgroundColor Salmon -ComparisonType string -Row
            } -PagingOptions 10, 20, 30, 40, 50
        }
        if ($Script:Reporting['GPOOwners']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOOwners']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
        New-HTMLSection -Name 'Steps to fix Group Policy Owners' {
            New-HTMLContainer {
                New-HTMLSpanStyle -FontSize 10pt {
                    New-HTMLText -Text 'Following steps will guide you how to fix group policy owners'
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
                            New-HTMLText -Text "Depending when this report was run you may want to prepare new report before proceeding with fixing Group Policy Owners. To generate new report please use:"
                            New-HTMLCodeBlock -Code {
                                Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrGPOOwnersBefore.html -Verbose -Type GPOOwners
                            }
                            New-HTMLText -TextBlock {
                                "When executed it will take a while to generate all data and provide you with new report depending on size of environment."
                                "Once confirmed that data is still showing issues and requires fixing please proceed with next step."
                            }
                            New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                            New-HTMLCodeBlock -Code {
                                $OwnersGPO = Get-GPOZaurrOwner -IncludeSysvol -Verbose
                                $OwnersGPO | Format-Table
                            }
                            New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
                        }
                        New-HTMLWizardStep -Name 'Make a backup (optional)' {
                            New-HTMLText -TextBlock {
                                "The process of fixing GPO Owner does NOT touch GPO content. It simply changes owners on AD and SYSVOL at the same time. "
                                "However, it's always good to have a backup before executing changes that may impact Active Directory. "
                            }
                            New-HTMLCodeBlock -Code {
                                $GPOSummary = Backup-GPOZaurr -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -Type All
                                $GPOSummary | Format-Table # only if you want to display output of backup
                            }
                            New-HTMLText -TextBlock {
                                "Above command when executed will make a backup to Desktop, create GPO folder and within it it will put all those GPOs. "
                            }
                        }
                        New-HTMLWizardStep -Name 'Set GPO Owners to Administrative (Domain Admins)' {
                            New-HTMLText -Text "Following command will find any GPO which doesn't have proper GPO Owner (be it due to inconsistency or not being Domain Admin) and will enforce new GPO Owner. "
                            New-HTMLText -Text "Make sure when running it for the first time to run it with ", "WhatIf", " parameter as shown below to prevent accidental removal." -FontWeight normal, bold, normal -Color Black, Red, Black
                            New-HTMLCodeBlock -Code {
                                Set-GPOZaurrOwner -Type All -Verbose -WhatIf
                            }
                            New-HTMLText -TextBlock {
                                "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                            }
                            New-HTMLCodeBlock -Code {
                                Set-GPOZaurrOwner -Type All -Verbose -WhatIf -IncludeDomains 'YourDomainYouHavePermissionsFor'
                            }
                            New-HTMLText -TextBlock {
                                "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be changed matches expected data."
                            } -LineBreak
                            New-HTMLText -Text "Once happy with results please follow with command (this will start fixing process): " -LineBreak -FontWeight bold
                            New-HTMLCodeBlock -Code {
                                Set-GPOZaurrOwner -Type All -Verbose -LimitProcessing 2
                            }
                            New-HTMLText -TextBlock {
                                "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                            }
                            New-HTMLCodeBlock -Code {
                                Set-GPOZaurrOwner -Type All -Verbose -LimitProcessing 2 -IncludeDomains 'YourDomainYouHavePermissionsFor'
                            }
                            New-HTMLText -TextBlock {
                                "This command when executed sets new owner only on first X non-compliant GPO Owners for AD/SYSVOL. Use LimitProcessing parameter to prevent mass change and increase the counter when no errors occur."
                                "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
                            }
                        }
                        New-HTMLWizardStep -Name 'Verification report' {
                            New-HTMLText -TextBlock {
                                "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                            }
                            New-HTMLCodeBlock -Code {
                                Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrGPOOwnersAfter.html -Verbose -Type GPOOwners
                            }
                            New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                        }
                    } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                }
            }
        }
    }
}