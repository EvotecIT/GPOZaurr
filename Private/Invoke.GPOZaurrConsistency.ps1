$GPOZaurrConsistency = [ordered] @{
    Name           = 'GPO Permissions Consistency'
    Enabled        = $true
    ActionRequired = $null
    Data           = $null
    Execute        = { Get-GPOZaurrPermissionConsistency -Type All -VerifyInheritance }
    Processing     = {
        foreach ($GPO in $Script:Reporting['GPOConsistency']['Data']) {
            if ($GPO.ACLConsistent -eq $true) {
                $Script:Reporting['GPOConsistency']['Variables']['Consistent']++
            } else {
                $Script:Reporting['GPOConsistency']['Variables']['Inconsistent']++
            }
            if ($GPO.ACLConsistentInside -eq $true) {
                $Script:Reporting['GPOConsistency']['Variables']['ConsistentInside']++
            } else {
                $Script:Reporting['GPOConsistency']['Variables']['InconsistentInside']++
            }
        }
        if ($Script:Reporting['GPOConsistency']['Variables']['Inconsistent'].Count -gt 0 -or $Script:Reporting['GPOConsistency']['Variables']['InconsistentInside'].Count -gt 0 ) {
            $Script:Reporting['GPOConsistency']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOConsistency']['ActionRequired'] = $false
        }
    }
    Variables      = @{
        Consistent         = 0
        Inconsistent       = 0
        ConsistentInside   = 0
        InconsistentInside = 0
    }
    Overview       = {
        New-HTMLPanel {
            New-HTMLText -Text 'Following chart presents ', 'permissions consistency between Active Directory and SYSVOL for Group Policies' -FontSize 10pt -FontWeight normal, bold
            New-HTMLList -Type Unordered {
                New-HTMLListItem -Text 'Top level permissions consistency: ', $Script:Reporting['GPOConsistency']['Variables']['Consistent'] -FontWeight normal, bold
                New-HTMLListItem -Text 'Inherited permissions consistency: ', $Script:Reporting['GPOConsistency']['Variables']['ConsistentInside'] -FontWeight normal, bold
                New-HTMLListItem -Text 'Inconsistent top level permissions: ', $Script:Reporting['GPOConsistency']['Variables']['Inconsistent'] -FontWeight normal, bold
                New-HTMLListItem -Text "Inconsistent inherited permissions: ", $Script:Reporting['GPOConsistency']['Variables']['InconsistentInside'] -FontWeight normal, bold
            } -FontSize 10pt
            New-HTMLText -FontSize 10pt -Text 'Having incosistent permissions on AD in comparison to those on SYSVOL can lead to uncontrolled ability to modify them.'
            New-HTMLChart {
                New-ChartLegend -Names 'Bad', 'Good' -Color PaleGreen, Salmon
                New-ChartBarOptions -Type barStacked
                New-ChartLegend -Name 'Consistent', 'Inconsistent'
                New-ChartBar -Name 'TopLevel' -Value $Script:Reporting['GPOConsistency']['Variables']['Consistent'], $Script:Reporting['GPOConsistency']['Variables']['Inconsistent']
                New-ChartBar -Name 'Inherited' -Value $Script:Reporting['GPOConsistency']['Variables']['ConsistentInside'], $Script:Reporting['GPOConsistency']['Variables']['InconsistentInside']
            } -Title 'Permissions Consistency' -TitleAlignment center
        }
    }
    Summary        = {
        New-HTMLText -FontSize 10pt -TextBlock {
            "When GPO is created it creates an entry in Active Directory (metadata) and SYSVOL (content). "
            "Two different places meens two different sets of permissions. Group Policy module is making sure the data in both places is correct. "
            "However, for different reasons it's not nessecary the case and often permissions go out of sync between AD and SYSVOL. "
            "This test verifies consistency of policies between AD and SYSVOL in two ways. "
            "It checks top level permissions for a GPO, and then checks if all files within said GPO are inheriting permissions or have different permissions in place. "
        }
        New-HTMLText -Text 'Following list presents ', 'permissions consistency between Active Directory and SYSVOL for Group Policies' -FontSize 10pt -FontWeight normal, bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Top level permissions consistency: ', $Script:Reporting['GPOConsistency']['Variables']['Consistent'] -FontWeight normal, bold
            New-HTMLListItem -Text 'Inherited permissions consistency: ', $Script:Reporting['GPOConsistency']['Variables']['ConsistentInside'] -FontWeight normal, bold
            New-HTMLListItem -Text 'Inconsistent top level permissions: ', $Script:Reporting['GPOConsistency']['Variables']['Inconsistent'] -FontWeight normal, bold
            New-HTMLListItem -Text "Inconsistent inherited permissions: ", $Script:Reporting['GPOConsistency']['Variables']['InconsistentInside'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -FontSize 10pt -Text 'Having incosistent permissions on AD in comparison to those on SYSVOL can lead to uncontrolled ability to modify them. Please notice that if ', `
            ' Not available ', 'is visible in the table you should first fix related, more pressing issue, before fixing permissions inconsistency.' -FontWeight normal, bold, normal
    }
    Solution       = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPOConsistency']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartBarOptions -Type barStacked
                    New-ChartLegend -Name 'Consistent', 'Inconsistent' -Color PaleGreen, Salmon
                    New-ChartBar -Name 'TopLevel' -Value $Script:Reporting['GPOConsistency']['Variables']['Consistent'], $Script:Reporting['GPOConsistency']['Variables']['Inconsistent']
                    New-ChartBar -Name 'Inherited' -Value $Script:Reporting['GPOConsistency']['Variables']['ConsistentInside'], $Script:Reporting['GPOConsistency']['Variables']['InconsistentInside']
                } -Title 'Permissions Consistency' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policy Permissions Consistency' {
            New-HTMLTable -DataTable $Script:Reporting['GPOConsistency']['Data'] -Filtering {
                New-HTMLTableCondition -Name 'ACLConsistent' -Value $false -BackgroundColor Salmon -TextTransform capitalize -ComparisonType string
                New-HTMLTableCondition -Name 'ACLConsistentInside' -Value $false -BackgroundColor Salmon -TextTransform capitalize -ComparisonType string
                New-HTMLTableCondition -Name 'ACLConsistent' -Value $true -BackgroundColor PaleGreen -TextTransform capitalize -ComparisonType string
                New-HTMLTableCondition -Name 'ACLConsistentInside' -Value $true -BackgroundColor PaleGreen -TextTransform capitalize -ComparisonType string
                New-HTMLTableCondition -Name 'ACLConsistent' -Value 'Not available' -BackgroundColor Crimson -ComparisonType string
                New-HTMLTableCondition -Name 'ACLConsistentInside' -Value 'Not available' -BackgroundColor Crimson -ComparisonType string
            } -PagingOptions 10, 20, 30, 40, 50
        }
        if ($Script:Reporting['GPOConsistency']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOConsistency']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
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
                                Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrPermissionsInconsistentBefore.html -Verbose -Type GPOConsistency
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
                                Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrPermissionsInconsistentAfter.html -Verbose -Type GPOConsistency
                            }
                            New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                        }
                    } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                }
            }
        }
    }
}