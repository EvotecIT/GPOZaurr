$GPOZaurrOwners = [ordered] @{
    Name       = 'GPO Owners'
    Enabled    = $true
    Data       = $null
    Execute    = { Get-GPOZaurrOwner -IncludeSysvol }
    Processing = {
        foreach ($GPO in $GpoZaurrOwners['Data']) {
            if ($GPO.IsOwnerConsistent) {
                $GpoZaurrOwners['Variables']['IsConsistent']++
            } else {
                $GpoZaurrOwners['Variables']['IsNotConsistent']++
            }
            if ($GPO.IsOwnerAdministrative) {
                $GpoZaurrOwners['Variables']['IsAdministrative']++
            } else {
                $GpoZaurrOwners['Variables']['IsNotAdministrative']++
            }
            if (($GPO.IsOwnerAdministrative -eq $false -or $GPO.IsOwnerConsistent -eq $false) -and $GPO.SysvolExists -eq $true) {
                $GpoZaurrOwners['Variables']['WillFix']++
            } elseif ($GPO.SysvolExists -eq $false) {
                $GpoZaurrOwners['Variables']['RequiresDiffFix']++
            } else {
                $GpoZaurrOwners['Variables']['WillNotTouch']++
            }
        }
    }
    Variables  = [ordered] @{
        IsAdministrative    = 0
        IsNotAdministrative = 0
        IsConsistent        = 0
        IsNotConsistent     = 0
        WillFix             = 0
        RequiresDiffFix     = 0
        WillNotTouch        = 0
    }
    Overview   = {
        New-HTMLPanel {
            New-HTMLText -Text 'Following chart presents Group Policy owners and whether they are administrative and consistent. By design an owner of Group Policy should be Domain Admins or Enterprise Admins group only to prevent malicious takeover. ', `
                "It's also important that owner in Active Directory matches owner on SYSVOL (file system)." -FontSize 10pt
            New-HTMLList -Type Unordered {
                New-HTMLListItem -Text 'Administrative Owners: ', $GpoZaurrOwners['Variables']['IsAdministrative'] -FontWeight normal, bold
                New-HTMLListItem -Text 'Non-Administrative Owners: ', $GpoZaurrOwners['Variables']['IsNotAdministrative'] -FontWeight normal, bold
                New-HTMLListItem -Text "Owners consistent in AD and SYSVOL: ", $GpoZaurrOwners['Variables']['IsConsistent'] -FontWeight normal, bold
                New-HTMLListItem -Text "Owners not-consistent in AD and SYSVOL: ", $GpoZaurrOwners['Variables']['IsNotConsistent'] -FontWeight normal, bold
            } -FontSize 10pt
            New-HTMLChart {
                New-ChartBarOptions -Type barStacked
                New-ChartLegend -Name 'Yes', 'No' -Color PaleGreen, Orchid
                New-ChartBar -Name 'Is administrative' -Value $GpoZaurrOwners['Variables']['IsAdministrative'], $GpoZaurrOwners['Variables']['IsNotAdministrative']
                New-ChartBar -Name 'Is consistent' -Value $GpoZaurrOwners['Variables']['IsConsistent'], $GpoZaurrOwners['Variables']['IsNotConsistent']
            } -Title 'Group Policy Owners' -TitleAlignment center
        }
    }
    Solution   = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
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
                    New-HTMLListItem -Text 'Administrative Owners: ', $GpoZaurrOwners['Variables']['IsAdministrative'] -FontWeight normal, bold
                    New-HTMLListItem -Text 'Non-Administrative Owners: ', $GpoZaurrOwners['Variables']['IsNotAdministrative'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Owners consistent in AD and SYSVOL: ", $GpoZaurrOwners['Variables']['IsConsistent'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Owners not-consistent in AD and SYSVOL: ", $GpoZaurrOwners['Variables']['IsNotConsistent'] -FontWeight normal, bold
                } -FontSize 10pt
                New-HTMLText -FontSize 10pt -Text "This gives us: "
                New-HTMLList -Type Unordered {
                    New-HTMLListItem -Text 'Group Policies requiring owner change: ', $GpoZaurrOwners['Variables']['WillFix'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies which can't be fixed (no SYSVOL?): ", $GpoZaurrOwners['Variables']['RequiresDiffFix'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies unaffected: ", $GpoZaurrOwners['Variables']['WillNotTouch'] -FontWeight normal, bold
                } -FontSize 10pt
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartBarOptions -Type barStacked
                    New-ChartLegend -Name 'Yes', 'No' -Color LightGreen, Salmon
                    New-ChartBar -Name 'Is administrative' -Value $GpoZaurrOwners['Variables']['IsAdministrative'], $GpoZaurrOwners['Variables']['IsNotAdministrative']
                    New-ChartBar -Name 'Is consistent' -Value $GpoZaurrOwners['Variables']['IsConsistent'], $GpoZaurrOwners['Variables']['IsNotConsistent']
                } -Title 'Group Policy Owners' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policy Owners' {
            New-HTMLTable -DataTable $GpoZaurrOwners['Data'] -Filtering {
                New-HTMLTableCondition -Name 'IsOwnerConsistent' -Value $false -BackgroundColor Salmon -ComparisonType string -Row
                New-HTMLTableCondition -Name 'IsOwnerAdministrative' -Value $false -BackgroundColor Salmon -ComparisonType string -Row
            } -PagingOptions 10, 20, 30, 40, 50
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
                        New-HTMLWizardStep -Name 'Set GPO Owners to Administrative (Domain Admins)' {
                            New-HTMLText -Text "Following command will find any GPO which doesn't have proper GPO Owner (be it due to inconsistency or not being Domain Admin) and will enforce new GPO Owner. "
                            New-HTMLText -Text "Make sure when running it for the first time to run it with ", "WhatIf", " parameter as shown below to prevent accidental removal." -FontWeight normal, bold, normal -Color Black, Red, Black

                            New-HTMLCodeBlock -Code {
                                Set-GPOZaurrOwner -Type All -Verbose -WhatIf
                            }
                            New-HTMLText -TextBlock {
                                "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be changed matches expected data. Once happy with results please follow with command: "
                            }
                            New-HTMLCodeBlock -Code {
                                Set-GPOZaurrOwner -Type All -Verbose -LimitProcessing 2
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