$GPOZaurrNetLogonOwners = [ordered] @{
    Name           = 'NetLogon Owners'
    Enabled        = $true
    ActionRequired = $null
    Data           = $null
    Execute        = {
        Get-GPOZaurrNetLogon -OwnerOnly -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing     = {
        foreach ($File in $Script:Reporting['NetLogonOwners']['Data']) {
            # if ($File.FileSystemRights -eq 'Owner') {
            # Process Owner part of the report
            $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwners']++
            if ($File.OwnerType -eq 'WellKnownAdministrative') {
                $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersAdministrative']++
            } elseif ($File.OwnerType -eq 'Administrative') {
                $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersAdministrative']++
            } else {
                $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersNotAdministrative']++
            }
            if ($File.OwnerSid -eq 'S-1-5-32-544') {
                $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersAdministrators']++
            } elseif ($File.OwnerType -in 'WellKnownAdministrative', 'Administrative') {
                $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersAdministrativeNotAdministrators']++
                $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersToFix']++
            } else {
                $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersToFix']++
            }
            #$Script:Reporting['NetLogonPermissions']['Variables']['Owner'].Add($File)
            #} else {
            # Process all other part of the report
            #     $Script:Reporting['NetLogonPermissions']['Variables']['NonOwner'].Add($File)

            #     if ($File.Status -eq 'Review permission required') {
            #         $Script:Reporting['NetLogonPermissions']['Variables']['PermissionReviewRequired']++
            #     } elseif ($File.Status -eq 'Removal permission required') {
            #         $Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequired']++
            #     } elseif ($File.Status -eq 'Not assesed') {
            #         $Script:Reporting['NetLogonPermissions']['Variables']['PermissionNotAssesed']++
            #     } else {
            #         $Script:Reporting['NetLogonPermissions']['Variables']['PermissionOK']++
            #     }
            # }
        }
        if ($Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersToFix'] -gt 0) {
            $Script:Reporting['NetLogonOwners']['ActionRequired'] = $true
        } else {
            $Script:Reporting['NetLogonOwners']['ActionRequired'] = $false
        }
        # if (-not $Script:Reporting['NetLogonPermissions']['ActionRequired']) {
        #     # if owners require fixing, we don't need to check those as we get this anyways
        #     # if owners don't require fixing we check permissions anyways
        #     if ($Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequired'] -gt 0 -or $Script:Reporting['NetLogonPermissions']['Variables']['PermissionReviewRequired'] -gt 0) {
        #         $Script:Reporting['NetLogonPermissions']['ActionRequired'] = $true
        #     } else {
        #         $Script:Reporting['NetLogonPermissions']['ActionRequired'] = $false
        #     }
        # }
    }
    Variables      = @{
        NetLogonOwners                                = 0
        NetLogonOwnersAdministrators                  = 0
        NetLogonOwnersNotAdministrative               = 0
        NetLogonOwnersAdministrative                  = 0
        NetLogonOwnersAdministrativeNotAdministrators = 0
        NetLogonOwnersToFix                           = 0
        #Owner                                         = [System.Collections.Generic.List[PSCustomObject]]::new()
        #NonOwner                                      = [System.Collections.Generic.List[PSCustomObject]]::new()

        # PermissionReviewRequired                      = 0
        # PermissionRemovalRequired                     = 0
        # PermissionOK                                  = 0
        # PermissionNotAssesed                          = 0
    }
    Overview       = {
        # New-HTMLPanel {
        #     New-HTMLText -Text 'Following chart presents ', 'NetLogon Summary' -FontSize 10pt -FontWeight normal, bold
        #     New-HTMLList -Type Unordered {
        #         New-HTMLListItem -Text 'NetLogon Files in Total: ', $Script:Reporting['NetLogonPermissions']['Variables']['NetLogonOwners'] -FontWeight normal, bold
        #         New-HTMLListItem -Text 'NetLogon BUILTIN\Administrators as Owner: ', $Script:Reporting['NetLogonPermissions']['Variables']['NetLogonOwnersAdministrators'] -FontWeight normal, bold
        #         New-HTMLListItem -Text "NetLogon Owners requiring change: ", $Script:Reporting['NetLogonPermissions']['Variables']['NetLogonOwnersToFix'] -FontWeight normal, bold {
        #             New-HTMLList -Type Unordered {
        #                 New-HTMLListItem -Text 'Not Administrative: ', $Script:Reporting['NetLogonPermissions']['Variables']['NetLogonOwnersNotAdministrative'] -FontWeight normal, bold
        #                 New-HTMLListItem -Text 'Administrative, but not BUILTIN\Administrators: ', $Script:Reporting['NetLogonPermissions']['Variables']['NetLogonOwnersAdministrativeNotAdministrators'] -FontWeight normal, bold
        #             }
        #         }
        #     } -FontSize 10pt
        #     #New-HTMLText -FontSize 10pt -Text 'Those problems must be resolved before doing other clenaup activities.'
        #     New-HTMLChart {
        #         New-ChartPie -Name 'Correct Owners' -Value $Script:Reporting['NetLogonPermissions']['Variables']['NetLogonOwnersAdministrators'] -Color LightGreen
        #         New-ChartPie -Name 'Incorrect Owners' -Value $Script:Reporting['NetLogonPermissions']['Variables']['NetLogonOwnersToFix'] -Color Crimson
        #     } -Title 'NetLogon Owners' -TitleAlignment center
        # }
        # New-HTMLPanel {

        # }
    }
    Summary        = {
        New-HTMLText -TextBlock {
            "NetLogon is crucial part of Active Directory. Files stored there are available on each and every computer or server in the company. "
            "Keeping those files clean and secure is very important task. "
            "It's important that NetLogon file owners are set to BUILTIN\Administrators (SID: S-1-5-32-544). "
            "Owners have full control over the file object. Current owner of the file may be an Administrator but it doesn't guarentee that he/she will be in the future. "
            "That's why as a best-practice it's recommended to change any non-administrative owners to BUILTIN\Administrators, and even Administrative accounts should be replaced with it. "
        } -FontSize 10pt
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'NetLogon Files in Total: ', $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwners'] -FontWeight normal, bold
            New-HTMLListItem -Text 'NetLogon BUILTIN\Administrators as Owner: ', $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersAdministrators'] -FontWeight normal, bold
            New-HTMLListItem -Text "NetLogon Owners requiring change: ", $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersToFix'] -FontWeight normal, bold {
                New-HTMLList -Type Unordered {
                    New-HTMLListItem -Text 'Not Administrative: ', $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersNotAdministrative'] -FontWeight normal, bold
                    New-HTMLListItem -Text 'Administrative, but not BUILTIN\Administrators: ', $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersAdministrativeNotAdministrators'] -FontWeight normal, bold
                }
            }
        } -FontSize 10pt
        New-HTMLText -Text "Follow the steps below table to get NetLogon Owners into compliant state." -FontSize 10pt
    }
    Solution       = {
        #New-HTMLTab -Name 'NetLogon Owners' {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['NetLogonOwners']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartPie -Name 'Correct Owners' -Value $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersAdministrators'] -Color LightGreen
                    New-ChartPie -Name 'Incorrect Owners' -Value $Script:Reporting['NetLogonOwners']['Variables']['NetLogonOwnersToFix'] -Color Crimson
                } -Title 'NetLogon Owners' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'NetLogon File Owners' {
            New-HTMLTable -DataTable $Script:Reporting['NetLogonOwners']['Data'] -Filtering {
                New-HTMLTableCondition -Name 'OwnerSid' -Value "S-1-5-32-544" -BackgroundColor LightGreen -ComparisonType string
                New-HTMLTableCondition -Name 'OwnerSid' -Value "S-1-5-32-544" -BackgroundColor Salmon -ComparisonType string -Operator ne
                New-HTMLTableCondition -Name 'OwnerType' -Value "WellKnownAdministrative" -BackgroundColor LightGreen -ComparisonType string -Operator eq
                New-HTMLTableCondition -Name 'Status' -Value "OK" -BackgroundColor LightGreen -ComparisonType string -Operator eq
                New-HTMLTableCondition -Name 'Status' -Value "OK" -BackgroundColor Salmon -ComparisonType string -Operator ne
            }
        }
        New-HTMLSection -Name 'Steps to fix NetLogon Owners ' {
            New-HTMLContainer {
                New-HTMLSpanStyle -FontSize 10pt {
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
                                Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrNetLogonBefore.html -Verbose -Type NetLogonOwners
                            }
                            New-HTMLText -TextBlock {
                                "When executed it will take a while to generate all data and provide you with new report depending on size of environment."
                                "Once confirmed that data is still showing issues and requires fixing please proceed with next step."
                            }
                            New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                            New-HTMLCodeBlock -Code {
                                $NetLogonOutput = Get-GPOZaurrNetLogon -OwnerOnly -Verbose
                                $NetLogonOutput | Format-Table
                            }
                            New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
                        }
                        New-HTMLWizardStep -Name 'Set non-compliant file owners to BUILTIN\Administrators' {
                            New-HTMLText -Text "Following command when executed runs internally command that lists all file owners and if it doesn't match changes it BUILTIN\Administrators. It doesn't change compliant owners."
                            New-HTMLText -Text "Make sure when running it for the first time to run it with ", "WhatIf", " parameter as shown below to prevent accidental removal." -FontWeight normal, bold, normal -Color Black, Red, Black

                            New-HTMLCodeBlock -Code {
                                Repair-GPOZaurrNetLogonOwner -Verbose -WhatIf
                            }
                            New-HTMLText -TextBlock {
                                "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                            }
                            New-HTMLCodeBlock -Code {
                                Repair-GPOZaurrNetLogonOwner -Verbose -WhatIf -IncludeDomains 'YourDomainYouHavePermissionsFor'
                            }
                            New-HTMLText -TextBlock {
                                "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be changed matches expected data. "
                            } -LineBreak
                            New-HTMLText -Text "Once happy with results please follow with command (this will start replacement of owners process): " -LineBreak -FontWeight bold
                            New-HTMLText -TextBlock {
                                "This command when executed sets new owner only on first X non-compliant NetLogon files. Use LimitProcessing parameter to prevent mass change and increase the counter when no errors occur."
                                "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
                            }
                            New-HTMLCodeBlock -Code {
                                Repair-GPOZaurrNetLogonOwner -Verbose -LimitProcessing 2
                            }
                            New-HTMLText -TextBlock {
                                "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                            }
                            New-HTMLCodeBlock -Code {
                                Repair-GPOZaurrNetLogonOwner -Verbose -LimitProcessing 2 -IncludeDomains 'YourDomainYouHavePermissionsFor'
                            }
                        }
                        New-HTMLWizardStep -Name 'Verification report' {
                            New-HTMLText -TextBlock {
                                "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                            }
                            New-HTMLCodeBlock -Code {
                                Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrNetLogonAfter.html -Verbose -Type NetLogonOwners
                            }
                            New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                        }
                    } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                }
            }
        }
        if ($Script:Reporting['NetLogonOwners']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['NetLogonOwners']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
        #}
        #New-HTMLTab -Name 'NetLogon Permissions' {
        # New-HTMLSection -Invisible {
        #     New-HTMLPanel {
        #         #& $Script:GPOConfiguration['NetLogonPermissions']['Summary']
        #     }
        #     New-HTMLPanel {
        #         #New-HTMLChart {
        #         #    New-ChartPie -Name 'Correct Owners' -Value $Script:Reporting['NetLogonPermissions']['Variables']['NetLogonOwnersAdministrators'] -Color LightGreen
        #         #    New-ChartPie -Name 'Incorrect Owners' -Value $Script:Reporting['NetLogonPermissions']['Variables']['NetLogonOwnersToFix'] -Color Crimson
        #         #} -Title 'NetLogon Owners' -TitleAlignment center
        #     }
        # }
        # # New-HTMLSection -Name 'NetLogon Files List' {
        # #     New-HTMLTable -DataTable $Script:Reporting['NetLogonPermissions']['Variables']['Owner'] -Filtering {
        # #         New-HTMLTableCondition -Name 'PrincipalSid' -Value "S-1-5-32-544" -BackgroundColor LightGreen -ComparisonType string
        # #         New-HTMLTableCondition -Name 'PrincipalSid' -Value "S-1-5-32-544" -BackgroundColor Salmon -ComparisonType string -Operator ne
        # #         New-HTMLTableCondition -Name 'PrincipalType' -Value "WellKnownAdministrative" -BackgroundColor LightGreen -ComparisonType string -Operator eq
        # #     }
        # # }
        # New-HTMLSection -Name 'NetLogon Files List' {
        #     New-HTMLTable -DataTable $Script:Reporting['NetLogonPermissions']['Variables']['NonOwner'] -Filtering {
        #         New-HTMLTableCondition -Name 'PrincipalType' -Value "Unknown" -BackgroundColor Salmon -ComparisonType string -Operator eq -Row
        #         New-HTMLTableCondition -Name 'PrincipalType' -Value "WellKnownAdministrative" -BackgroundColor LightGreen -ComparisonType string -Operator eq -Row
        #         New-HTMLTableCondition -Name 'Status' -Value "Review permission required" -BackgroundColor PaleGoldenrod -ComparisonType string -Operator eq -Row
        #         New-HTMLTableCondition -Name 'Status' -Value "Removal permission required" -BackgroundColor Salmon -ComparisonType string -Operator eq -Row
        #         New-HTMLTableCondition -Name 'Status' -Value "OK" -BackgroundColor LightGreen -ComparisonType string -Operator eq
        #     }
        # }
        # if ($Script:Reporting['NetLogonPermissions']['WarningsAndErrors']) {
        #     New-HTMLSection -Name 'Warnings & Errors to Review' {
        #         New-HTMLTable -DataTable $Script:Reporting['NetLogonPermissions']['WarningsAndErrors'] -Filtering {
        #             New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
        #             New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
        #         }
        #     }
        # }
        # }
    }
}