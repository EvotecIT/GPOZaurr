$GPOZaurrList = [ordered] @{
    Name       = 'Group Policy Summary'
    Enabled    = $true
    Action     = $null
    Data       = $null
    Execute    = {
        Get-GPOZaurr
    }
    Processing = {
        foreach ($GPO in $Script:Reporting['GPOList']['Data']) {
            if ($GPO.Linked -eq $false -and $GPO.Empty -eq $true) {
                # Not linked, Empty
                $Script:Reporting['GPOList']['Variables']['GPOEmptyAndUnlinked']++
                $Script:Reporting['GPOList']['Variables']['GPOEmptyOrUnlinked']++
                $Script:Reporting['GPOList']['Variables']['GPONotLinked']++
                $Script:Reporting['GPOList']['Variables']['GPOEmpty']++
            } elseif ($GPO.Linked -eq $true -and $GPO.Empty -eq $true) {
                # Linked, But EMPTY
                $Script:Reporting['GPOList']['Variables']['GPOLinkedButEmpty']++
                $Script:Reporting['GPOList']['Variables']['GPOEmptyOrUnlinked']++
                $Script:Reporting['GPOList']['Variables']['GPOEmpty']++
                $Script:Reporting['GPOList']['Variables']['GPOLinked']++
            } elseif ($GPO.Linked -eq $false) {
                # Not linked, but not EMPTY
                $Script:Reporting['GPOList']['Variables']['GPONotLinked']++
                $Script:Reporting['GPOList']['Variables']['GPOEmptyOrUnlinked']++
                $Script:Reporting['GPOList']['Variables']['GPONotEmpty']++
            } elseif ($GPO.Empty -eq $true) {
                # Linked, But EMPTY
                $Script:Reporting['GPOList']['Variables']['GPOEmpty']++
                $Script:Reporting['GPOList']['Variables']['GPOEmptyOrUnlinked']++
                $Script:Reporting['GPOList']['Variables']['GPOLinked']++
            } else {
                # Linked, not EMPTY
                $Script:Reporting['GPOList']['Variables']['GPOValid']++
                $Script:Reporting['GPOList']['Variables']['GPOLinked']++
                $Script:Reporting['GPOList']['Variables']['GPONotEmpty']++
            }
            if ($GPO.LinksDisabledCount -eq $GPO.LinksCount -and $GPO.LinksCount -gt 0) {
                $Script:Reporting['GPOList']['Variables']['GPOLinkedButLinkDisabled']++
            }

            if ($GPO.ComputerOptimized -eq $true) {
                $Script:Reporting['GPOList']['Variables']['ComputerOptimizedYes']++
            } else {
                $Script:Reporting['GPOList']['Variables']['ComputerOptimizedNo']++
            }
            if ($GPO.ComputerProblem -eq $true) {
                $Script:Reporting['GPOList']['Variables']['ComputerProblemYes']++
            } else {
                $Script:Reporting['GPOList']['Variables']['ComputerProblemNo']++
            }
            if ($GPO.UserOptimized -eq $true) {
                $Script:Reporting['GPOList']['Variables']['UserOptimizedYes']++
            } else {
                $Script:Reporting['GPOList']['Variables']['UserOptimizedNo']++
            }
            if ($GPO.UserProblem -eq $true) {
                $Script:Reporting['GPOList']['Variables']['UserProblemYes']++
            } else {
                $Script:Reporting['GPOList']['Variables']['UserProblemNo']++
            }
            if ($GPO.UserProblem -or $GPO.ComputerProblem) {
                $Script:Reporting['GPOList']['Variables']['GPOWithProblems']++
            }
        }
        $Script:Reporting['GPOList']['Variables']['GPOTotal'] = $Script:Reporting['GPOList']['Data'].Count
        if ($Script:Reporting['GPOList']['Variables']['GPOEmptyOrUnlinked'].Count -gt 0) {
            $Script:Reporting['GPOList']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOList']['ActionRequired'] = $false
        }
    }
    Variables  = @{
        GPOWithProblems          = 0
        ComputerOptimizedYes     = 0
        ComputerOptimizedNo      = 0
        ComputerProblemYes       = 0
        ComputerProblemNo        = 0
        UserOptimizedYes         = 0
        UserOptimizedNo          = 0
        UserProblemYes           = 0
        UserProblemNo            = 0
        GPONotLinked             = 0
        GPOLinked                = 0
        GPOEmpty                 = 0
        GPONotEmpty              = 0
        GPOEmptyAndUnlinked      = 0
        GPOEmptyOrUnlinked       = 0
        GPOLinkedButEmpty        = 0
        GPOValid                 = 0
        GPOLinkedButLinkDisabled = 0
        GPOTotal                 = 0
    }
    Overview   = {
        New-HTMLPanel {
            New-HTMLText -Text 'Following chart presents ', 'Linked / Empty and Unlinked Group Policies' -FontSize 10pt -FontWeight normal, bold
            New-HTMLList -Type Unordered {
                New-HTMLListItem -Text 'Group Policies total: ', $Script:Reporting['GPOList']['Variables']['GPOTotal'] -FontWeight normal, bold
                New-HTMLListItem -Text "Group Policies valid: ", $Script:Reporting['GPOList']['Variables']['GPOValid'] -FontWeight normal, bold
                New-HTMLListItem -Text "Group Policies to delete: ", $Script:Reporting['GPOList']['Variables']['GPOEmptyOrUnlinked'] -FontWeight normal, bold {
                    New-HTMLList -Type Unordered {
                        New-HTMLListItem -Text 'Group Policies that are unlinked (are not doing anything currently): ', $Script:Reporting['GPOList']['Variables']['GPONotLinked'] -FontWeight normal, bold
                        New-HTMLListItem -Text "Group Policies that are empty (have no settings): ", $Script:Reporting['GPOList']['Variables']['GPOEmpty'] -FontWeight normal, bold
                        New-HTMLListItem -Text "Group Policies that are linked, but empty: ", $Script:Reporting['GPOList']['Variables']['GPOLinkedButEmpty'] -FontWeight normal, bold
                        New-HTMLListItem -Text "Group Policies that are linked, but link disabled: ", $Script:Reporting['GPOList']['Variables']['GPOLinkedButLinkDisabled'] -FontWeight normal, bold
                    }
                }
            }
            New-HTMLText -FontSize 10pt -Text 'Usually empty or unlinked Group Policies are safe to delete.'
            New-HTMLChart -Title 'Group Policies Summary' {
                New-ChartBarOptions -Type barStacked
                #New-ChartLegend -Names 'Unlinked', 'Linked', 'Empty', 'Total' -Color Salmon, PaleGreen, PaleVioletRed, PaleTurquoise
                New-ChartLegend -Names 'Good', 'Bad' -Color PaleGreen, Salmon
                #New-ChartBar -Name 'Group Policies' -Value $Script:Reporting['GPOList']['Variables']['GPONotLinked'], $Script:Reporting['GPOList']['Variables']['GPOLinked'], $Script:Reporting['GPOList']['Variables']['GPOEmpty'], $Script:Reporting['GPOList']['Variables']['GPOTotal']
                New-ChartBar -Name 'Linked' -Value $Script:Reporting['GPOList']['Variables']['GPOLinked'], $Script:Reporting['GPOList']['Variables']['GPONotLinked']
                New-ChartBar -Name 'Empty' -Value $Script:Reporting['GPOList']['Variables']['GPONotEmpty'], $Script:Reporting['GPOList']['Variables']['GPOEmpty']
                New-ChartBar -Name 'Valid' -Value $Script:Reporting['GPOList']['Variables']['GPOValid'], $Script:Reporting['GPOList']['Variables']['GPOEmptyOrUnlinked']
            } -TitleAlignment center
        }
    }
    Summary    = {
        New-HTMLText -TextBlock {
            "Over time Administrators add more and more group policies, as business requirements change. "
            "Due to neglection or thinking it may serve it's purpose later on a lot of Group Policies often have no value at all. "
            "Either the Group Policy is not linked to anything and just stays unlinked forever, or GPO is linked, but the link (links) are disabled. "
            "Additionally sometimes new GPO is created without any settings or the settings are removed over time, but GPO stays in place. "
        } -FontSize 10pt
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies total: ', $Script:Reporting['GPOList']['Variables']['GPOTotal'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies valid: ", $Script:Reporting['GPOList']['Variables']['GPOValid'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies to delete: ", $Script:Reporting['GPOList']['Variables']['GPOEmptyOrUnlinked'] -FontWeight normal, bold {
                New-HTMLList -Type Unordered {
                    New-HTMLListItem -Text 'Group Policies that are unlinked (are not doing anything currently): ', $Script:Reporting['GPOList']['Variables']['GPONotLinked'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies that are empty (have no settings): ", $Script:Reporting['GPOList']['Variables']['GPOEmpty'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies that are linked, but empty: ", $Script:Reporting['GPOList']['Variables']['GPOLinkedButEmpty'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies that are linked, but link disabled: ", $Script:Reporting['GPOList']['Variables']['GPOLinkedButLinkDisabled'] -FontWeight normal, bold
                }
            }
        } -FontSize 10pt
        New-HTMLText -Text "Additionally, we're reviewing Group Policies that have their section disabled, but contain data. Please review them and make sure this configuration is as expected!" -FontSize 10pt
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies with problems: ', $Script:Reporting['GPOList']['Variables']['GPOWithProblems'] -FontWeight normal, bold {
                New-HTMLList -Type Unordered {
                    New-HTMLListItem -Text 'Group Policies that have content (computer), but are disabled: ', $Script:Reporting['GPOList']['Variables']['ComputerProblemYes'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies that have content (user), but are disabled: ", $Script:Reporting['GPOList']['Variables']['UserProblemYes'] -FontWeight normal, bold
                }
            }
        } -FontSize 10pt
        New-HTMLText -Text "For best performance it's recommended that if there are no settings of certain kind (Computer or User settings) it's best to disable them. " -FontSize 10pt
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies with optimization: ' -FontWeight normal, bold {
                New-HTMLList -Type Unordered {
                    New-HTMLListItem -Text 'Group Policies that are optimized (computer) ', $Script:Reporting['GPOList']['Variables']['ComputerOptimizedYes'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies that are optimized (user): ", $Script:Reporting['GPOList']['Variables']['UserOptimizedYes'] -FontWeight normal, bold
                }
            }
            New-HTMLListItem -Text 'Group Policies without optimization: ' -FontWeight normal, bold {
                New-HTMLList -Type Unordered {
                    New-HTMLListItem -Text 'Group Policies that are not optimized (computer): ', $Script:Reporting['GPOList']['Variables']['ComputerOptimizedNo'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies that are not optimized (user): ", $Script:Reporting['GPOList']['Variables']['UserOptimizedNo'] -FontWeight normal, bold
                }
            }
        } -FontSize 10pt
        New-HTMLText -TextBlock {
            'All empty or unlinked Group Policies can be automatically deleted. Please review output in the table and follow steps below table to cleanup Group Policies. '
            'GPOs that have content, but are disabled require manual intervention. '
            "If performance is an issue you should consider disabling user or computer sections of GPO when those are not used. "
        } -FontSize 10pt
    }
    Solution   = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPOList']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart -Title 'Group Policies Empty & Unlinked' {
                    New-ChartBarOptions -Type barStacked
                    New-ChartLegend -Names 'Yes', 'No' -Color SpringGreen, Salmon
                    New-ChartBar -Name 'Linked' -Value $Script:Reporting['GPOList']['Variables']['GPOLinked'], $Script:Reporting['GPOList']['Variables']['GPONotLinked']
                    New-ChartBar -Name 'Empty' -Value $Script:Reporting['GPOList']['Variables']['GPONotEmpty'], $Script:Reporting['GPOList']['Variables']['GPOEmpty']
                    New-ChartBar -Name 'Valid' -Value $Script:Reporting['GPOList']['Variables']['GPOValid'], $Script:Reporting['GPOList']['Variables']['GPOEmptyOrUnlinked']
                    New-ChartBar -Name 'With problem (computers)' -Value $Script:Reporting['GPOList']['Variables']['ComputerProblemNo'], $Script:Reporting['GPOList']['Variables']['ComputerProblemYes']
                    New-ChartBar -Name 'With problem (users)' -Value $Script:Reporting['GPOList']['Variables']['UserProblemNo'], $Script:Reporting['GPOList']['Variables']['UserProblemYes']
                    New-ChartBar -Name 'Optimized Computers' -Value $Script:Reporting['GPOList']['Variables']['ComputerOptimizedYes'], $Script:Reporting['GPOList']['Variables']['ComputerOptimizedNo']
                    New-ChartBar -Name 'Optimized Users' -Value $Script:Reporting['GPOList']['Variables']['UserOptimizedYes'], $Script:Reporting['GPOList']['Variables']['UserOptimizedNo']
                } -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policies List' {
            New-HTMLTable -DataTable $Script:Reporting['GPOList']['Data'] -Filtering {
                New-HTMLTableCondition -Name 'Empty' -Value $true -BackgroundColor Salmon -ComparisonType string
                New-HTMLTableCondition -Name 'Linked' -Value $false -BackgroundColor Salmon -ComparisonType string
                New-HTMLTableCondition -Name 'ComputerProblem' -Value $true -BackgroundColor Salmon -ComparisonType string
                New-HTMLTableCondition -Name 'UserProblem' -Value $true -BackgroundColor Salmon -ComparisonType string
                New-HTMLTableCondition -Name 'ComputerOptimized' -Value $false -BackgroundColor Salmon -ComparisonType string
                New-HTMLTableCondition -Name 'UserOptimized' -Value $false -BackgroundColor Salmon -TextTransform capitalize -ComparisonType string
                # reverse
                New-HTMLTableCondition -Name 'Empty' -Value $false -BackgroundColor SpringGreen -ComparisonType string
                New-HTMLTableCondition -Name 'Linked' -Value $true -BackgroundColor SpringGreen -ComparisonType string
                New-HTMLTableCondition -Name 'ComputerProblem' -Value $false -BackgroundColor SpringGreen -ComparisonType string
                New-HTMLTableCondition -Name 'UserProblem' -Value $false -BackgroundColor SpringGreen -ComparisonType string
                New-HTMLTableCondition -Name 'ComputerOptimized' -Value $true -BackgroundColor SpringGreen -ComparisonType string
                New-HTMLTableCondition -Name 'UserOptimized' -Value $true -BackgroundColor SpringGreen -TextTransform capitalize -ComparisonType string
            } -PagingOptions 10, 20, 30, 40, 50
        }
        if ($Script:Reporting['GPOList']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOList']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
        New-HTMLSection -Name 'Steps to fix - Empty & Unlinked Group Policies' {
            New-HTMLContainer {
                New-HTMLSpanStyle -FontSize 10pt {
                    New-HTMLText -Text 'Following steps will guide you how to remove empty or unlinked group policies'
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
                                Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrEmptyUnlinked.html -Verbose -Type GPOList
                            }
                            New-HTMLText -TextBlock {
                                "When executed it will take a while to generate all data and provide you with new report depending on size of environment."
                                "Once confirmed that data is still showing issues and requires fixing please proceed with next step."
                            }
                            New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                            New-HTMLCodeBlock -Code {
                                $GPOOutput = Get-GPOZaurr
                                $GPOOutput | Format-Table
                            }
                            New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
                        }
                        New-HTMLWizardStep -Name 'Remove GPOs that are EMPTY or UNLINKED' {
                            New-HTMLText -Text @(
                                "Following command when executed removes every ",
                                "EMPTY"
                                " or "
                                "NOT LINKED"
                                " Group Policy. Make sure when running it for the first time to run it with ",
                                "WhatIf",
                                " parameter as shown below to prevent accidental removal.",
                                "Make sure to use BackupPath which will make sure that for each GPO that is about to be deleted a backup is made to folder on a desktop."
                            ) -FontWeight normal, bold, normal, bold, normal, bold, normal, normal -Color Black, Red, Black, Red, Black
                            New-HTMLCodeBlock -Code {
                                Remove-GPOZaurr -Type Empty, Unlinked -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -WhatIf
                            }
                            New-HTMLText -TextBlock {
                                "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be deleted matches expected data. Once happy with results please follow with command: "
                            }
                            New-HTMLCodeBlock -Code {
                                Remove-GPOZaurr -Type Empty, Unlinked -BackupPath "$Env:UserProfile\Desktop\GPO" -LimitProcessing 2 -Verbose
                            }
                            New-HTMLText -TextBlock {
                                "This command when executed deletes only first empty or unlinked GPOs. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur."
                                "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
                                "Please make sure to check if backup is made as well before going all in."
                            }
                            New-HTMLText -Text "If there's nothing else to be deleted on SYSVOL side, we can skip to next step step"
                        }
                        New-HTMLWizardStep -Name 'Verification report' {
                            New-HTMLText -TextBlock {
                                "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                            }
                            New-HTMLCodeBlock -Code {
                                Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrEmptyUnlinkedAfter.html -Verbose -Type GPOList
                            }
                            New-HTMLText -Text "If there are no more empty or unlinked GPOs in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                        }
                    } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                }
            }
        }
    }
}