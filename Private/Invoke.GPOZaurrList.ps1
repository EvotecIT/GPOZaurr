$GPOZaurrList = [ordered] @{
    Name       = 'Group Policy Empty & Unlinked'
    Enabled    = $true
    Action     = $null
    Data       = $null
    Execute    = {
        Get-GPOZaurr
    }
    Processing = {
        foreach ($GPO in $GPOZaurrList['Data']) {
            if ($GPO.Linked -eq $false -and $GPO.Empty -eq $true) {
                # Not linked, Empty
                $GPOZaurrList['Variables']['GPOEmptyAndUnlinked']++
                $GPOZaurrList['Variables']['GPOEmptyOrUnlinked']++
                $GPOZaurrList['Variables']['GPONotLinked']++
                $GPOZaurrList['Variables']['GPOEmpty']++
            } elseif ($GPO.Linked -eq $true -and $GPO.Empty -eq $true) {
                # Linked, But EMPTY
                $GPOZaurrList['Variables']['GPOLinkedButEmpty']++
                $GPOZaurrList['Variables']['GPOEmptyOrUnlinked']++
                $GPOZaurrList['Variables']['GPOEmpty']++
                $GPOZaurrList['Variables']['GPOLinked']++
            } elseif ($GPO.Linked -eq $false) {
                # Not linked, but not EMPTY
                $GPOZaurrList['Variables']['GPONotLinked']++
                $GPOZaurrList['Variables']['GPOEmptyOrUnlinked']++
                $GPOZaurrList['Variables']['GPONotEmpty']++
            } elseif ($GPO.Empty -eq $true) {
                # Linked, But EMPTY
                $GPOZaurrList['Variables']['GPOEmpty']++
                $GPOZaurrList['Variables']['GPOEmptyOrUnlinked']++
                $GPOZaurrList['Variables']['GPOLinked']++
            } else {
                # Linked, not EMPTY
                $GPOZaurrList['Variables']['GPOValid']++
                $GPOZaurrList['Variables']['GPOLinked']++
                $GPOZaurrList['Variables']['GPONotEmpty']++
            }
            if ($GPO.LinksDisabledCount -eq $GPO.LinksCount -and $GPO.LinksCount -gt 0) {
                $GPOZaurrList['Variables']['GPOLinkedButLinkDisabled']++
            }
        }
        $GPOZaurrList['Variables']['GPOTotal'] = $GPOZaurrList['Data'].Count
    }
    Variables  = [ordered] @{
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
                New-HTMLListItem -Text 'Group Policies total: ', $GPOZaurrList['Variables']['GPOTotal'] -FontWeight normal, bold
                New-HTMLListItem -Text "Group Policies valid: ", $GPOZaurrList['Variables']['GPOValid'] -FontWeight normal, bold
                New-HTMLListItem -Text "Group Policies to delete: ", $GPOZaurrList['Variables']['GPOEmptyOrUnlinked'] -FontWeight normal, bold {
                    New-HTMLList -Type Unordered {
                        New-HTMLListItem -Text 'Group Policies that are unlinked (are not doing anything currently): ', $GPOZaurrList['Variables']['GPONotLinked'] -FontWeight normal, bold
                        New-HTMLListItem -Text "Group Policies that are empty (have no settings): ", $GPOZaurrList['Variables']['GPOEmpty'] -FontWeight normal, bold
                        New-HTMLListItem -Text "Group Policies that are linked, but empty: ", $GPOZaurrList['Variables']['GPOLinkedButEmpty'] -FontWeight normal, bold
                        New-HTMLListItem -Text "Group Policies that are linked, but link disabled: ", $GPOZaurrList['Variables']['GPOLinkedButLinkDisabled'] -FontWeight normal, bold
                    }
                }
            } -FontSize 10pt
            New-HTMLText -FontSize 10pt -Text 'Usually empty or unlinked Group Policies are safe to delete.'
            New-HTMLChart -Title 'Group Policies Summary' {
                New-ChartBarOptions -Type barStacked
                #New-ChartLegend -Names 'Unlinked', 'Linked', 'Empty', 'Total' -Color Salmon, PaleGreen, PaleVioletRed, PaleTurquoise
                New-ChartLegend -Names 'Good', 'Bad' -Color PaleGreen, Salmon
                #New-ChartBar -Name 'Group Policies' -Value $GPOZaurrList['Variables']['GPONotLinked'], $GPOZaurrList['Variables']['GPOLinked'], $GPOZaurrList['Variables']['GPOEmpty'], $GPOZaurrList['Variables']['GPOTotal']
                New-ChartBar -Name 'Linked' -Value $GPOZaurrList['Variables']['GPOLinked'], $GPOZaurrList['Variables']['GPONotLinked']
                New-ChartBar -Name 'Empty' -Value $GPOZaurrList['Variables']['GPONotEmpty'], $GPOZaurrList['Variables']['GPOEmpty']
                New-ChartBar -Name 'Valid' -Value $GPOZaurrList['Variables']['GPOValid'], $GPOZaurrList['Variables']['GPOEmptyOrUnlinked']
            } -TitleAlignment center
        }
    }
    Solution   = {
        New-HTMLSection -Invisible {
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
                    New-HTMLListItem -Text 'Group Policies total: ', $GPOZaurrList['Variables']['GPOTotal'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies valid: ", $GPOZaurrList['Variables']['GPOValid'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies to delete: ", $GPOZaurrList['Variables']['GPOEmptyOrUnlinked'] -FontWeight normal, bold {
                        New-HTMLList -Type Unordered {
                            New-HTMLListItem -Text 'Group Policies that are unlinked (are not doing anything currently): ', $GPOZaurrList['Variables']['GPONotLinked'] -FontWeight normal, bold
                            New-HTMLListItem -Text "Group Policies that are empty (have no settings): ", $GPOZaurrList['Variables']['GPOEmpty'] -FontWeight normal, bold
                            New-HTMLListItem -Text "Group Policies that are linked, but empty: ", $GPOZaurrList['Variables']['GPOLinkedButEmpty'] -FontWeight normal, bold
                            New-HTMLListItem -Text "Group Policies that are linked, but link disabled: ", $GPOZaurrList['Variables']['GPOLinkedButLinkDisabled'] -FontWeight normal, bold
                        }
                    }
                } -FontSize 10pt
                New-HTMLText -Text 'All those mentioned Group Policies can be automatically deleted following the steps below the table.' -FontSize 10pt
            }
            New-HTMLPanel {
                New-HTMLChart -Title 'Group Policies Empty & Unlinked' {
                    New-ChartBarOptions -Type barStacked
                    #New-ChartLegend -Names 'Unlinked', 'Linked', 'Empty', 'Total' -Color Salmon, PaleGreen, PaleVioletRed, PaleTurquoise
                    New-ChartLegend -Names 'Good', 'Bad' -Color PaleGreen, Salmon
                    #New-ChartBar -Name 'Group Policies' -Value $GPOZaurrList['Variables']['GPONotLinked'], $GPOZaurrList['Variables']['GPOLinked'], $GPOZaurrList['Variables']['GPOEmpty'], $GPOZaurrList['Variables']['GPOTotal']
                    New-ChartBar -Name 'Linked' -Value $GPOZaurrList['Variables']['GPOLinked'], $GPOZaurrList['Variables']['GPONotLinked']
                    New-ChartBar -Name 'Empty' -Value $GPOZaurrList['Variables']['GPONotEmpty'], $GPOZaurrList['Variables']['GPOEmpty']
                    New-ChartBar -Name 'Valid' -Value $GPOZaurrList['Variables']['GPOValid'], $GPOZaurrList['Variables']['GPOEmptyOrUnlinked']
                } -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policies List' {
            New-HTMLTable -DataTable $GPOZaurrList['Data'] -Filtering {
                New-HTMLTableCondition -Name 'Empty' -Value $true -BackgroundColor Salmon -TextTransform capitalize -ComparisonType string
                New-HTMLTableCondition -Name 'Linked' -Value $false -BackgroundColor Salmon -TextTransform capitalize -ComparisonType string
            } -PagingOptions 10, 20, 30, 40, 50
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