$GPOZaurrNetLogonPermissions = [ordered] @{
    Name           = 'NetLogon Permissions'
    Enabled        = $true
    ActionRequired = $null
    Data           = $null
    Execute        = {
        Get-GPOZaurrNetLogon -SkipOwner -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing     = {
        $Script:Reporting['NetLogonPermissions']['Variables']['PermissionWriteReviewPerDomain'] = @{}
        $Script:Reporting['NetLogonPermissions']['Variables']['PermissionFullControlReviewPerDomain'] = @{}
        $Script:Reporting['NetLogonPermissions']['Variables']['PermissionModifyReviewPerDomain'] = @{}
        $Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequiredPerDomain'] = @{}

        foreach ($File in $Script:Reporting['NetLogonPermissions']['Data']) {
            if (-not $Script:Reporting['NetLogonPermissions']['Variables']['PermissionWriteReviewPerDomain'][$File.DomainName]) {
                $Script:Reporting['NetLogonPermissions']['Variables']['PermissionWriteReviewPerDomain'][$File.DomainName] = 0
            }
            if (-not $Script:Reporting['NetLogonPermissions']['Variables']['PermissionFullControlReviewPerDomain'][$File.DomainName]) {
                $Script:Reporting['NetLogonPermissions']['Variables']['PermissionFullControlReviewPerDomain'][$File.DomainName] = 0
            }
            if (-not $Script:Reporting['NetLogonPermissions']['Variables']['PermissionModifyReviewPerDomain'][$File.DomainName]) {
                $Script:Reporting['NetLogonPermissions']['Variables']['PermissionModifyReviewPerDomain'][$File.DomainName] = 0
            }
            if (-not $Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequiredPerDomain'][$File.DomainName]) {
                $Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequiredPerDomain'][$File.DomainName] = 0
            }

            if ($File.Status -eq 'Review permission required') {
                $Script:Reporting['NetLogonPermissions']['Variables']['PermissionReviewRequired']++
                if ($File.FileSystemRights -like '*Modify*') {
                    $Script:Reporting['NetLogonPermissions']['Variables']['PermissionModifyReview']++
                    $Script:Reporting['NetLogonPermissions']['Variables']['PermissionModifyReviewPerDomain'][$File.DomainName]++
                } elseif ($File.FileSystemRights -like '*Write*') {
                    $Script:Reporting['NetLogonPermissions']['Variables']['PermissionWriteReview']++
                    $Script:Reporting['NetLogonPermissions']['Variables']['PermissionWriteReviewPerDomain'][$File.DomainName]++
                } elseif ($File.FileSystemRights -like '*FullControl*') {
                    $Script:Reporting['NetLogonPermissions']['Variables']['PermissionFullControlReview']++
                    $Script:Reporting['NetLogonPermissions']['Variables']['PermissionFullControlReviewPerDomain'][$File.DomainName]++
                } else {
                    $Script:Reporting['NetLogonPermissions']['Variables']['PermissionOtherReview']++
                }
            } elseif ($File.Status -eq 'Removal permission required') {
                $Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequired']++
                $Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequiredPerDomain'][$File.DomainName]++
                if ($File.PrincipalObjectClass -in 'user', 'computer') {
                    $Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequiredBecauseObject']++
                } else {
                    $Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequiredBecauseUnknown']++
                }
            } elseif ($File.Status -eq 'Not assesed') {
                $Script:Reporting['NetLogonPermissions']['Variables']['PermissionNotAssesed']++
            } else {
                $Script:Reporting['NetLogonPermissions']['Variables']['PermissionOK']++
            }
        }
        if ($Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequired'] -gt 0 -or $Script:Reporting['NetLogonPermissions']['Variables']['PermissionReviewRequired'] -gt 0) {
            $Script:Reporting['NetLogonPermissions']['ActionRequired'] = $true
        } else {
            $Script:Reporting['NetLogonPermissions']['ActionRequired'] = $false
        }
    }
    Variables      = @{
        PermissionReviewRequired                = 0
        PermissionRemovalRequired               = 0
        PermissionOK                            = 0
        PermissionNotAssesed                    = 0

        PermissionWriteReview                   = 0
        PermissionFullControlReview             = 0
        PermissionModifyReview                  = 0
        PermissionOtherReview                   = 0
        PermissionRemovalRequiredBecauseObject  = 0
        PermissionRemovalRequiredBecauseUnknown = 0


        PermissionWriteReviewPerDomain          = $null
        PermissionFullControlReviewPerDomain    = $null
        PermissionModifyReviewPerDomain         = $null
        PermissionRemovalRequiredPerDomain      = $null
    }
    Overview       = {

    }
    Summary        = {
        New-HTMLText -TextBlock {
            "NetLogon is crucial part of Active Directory. Files stored there are available on each and every computer or server in the company. "
            "Keeping those files clean and secure is very important task. "
            "Each file stored on NETLOGON has it's own permissions. "
            "It's important that crucial permissions such as FullControl, Modify or Write permissions are only applied to proper, trusted groups of users. "
            "Additionally permissions for FullControl, Modify or Write should not be granted to direct users or computers. Only groups are allowed! "
            ""
        } -FontSize 10pt
        New-HTMLText -Text 'Assesment overall: ' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Permissions that look ok: ' {
                New-HTMLList -Type Unordered {
                    New-HTMLListItem -Text 'Assesed and as expected ', $Script:Reporting['NetLogonPermissions']['Variables']['PermissionOK'] -FontWeight normal, bold
                    New-HTMLListItem -Text 'Not assesed, but not critical (read/execute only) ', $Script:Reporting['NetLogonPermissions']['Variables']['PermissionNotAssesed'] -FontWeight normal, bold
                }
            }
            New-HTMLListItem -Text 'Permissions requiring review:' {
                New-HTMLList -Type Unordered {
                    New-HTMLListItem -Text 'Full control permissions ', $Script:Reporting['NetLogonPermissions']['Variables']['PermissionFullControlReview'] -FontWeight normal, bold
                    New-HTMLListItem -Text 'Modify permissions ', $Script:Reporting['NetLogonPermissions']['Variables']['PermissionModifyReview'] -FontWeight normal, bold
                    New-HTMLListItem -Text 'Write permissions ', $Script:Reporting['NetLogonPermissions']['Variables']['PermissionWriteReview'] -FontWeight normal, bold
                }
            }
            New-HTMLListItem -Text 'Permissions requiring removal: ', $Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequired'] -FontWeight normal, bold {
                New-HTMLList -Type Unordered {
                    New-HTMLListItem -Text 'Because of object type (user/computer) ', $Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequiredBecauseObject'] -FontWeight normal, bold
                    New-HTMLListItem -Text 'Because of unknown permissions ', $Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequiredBecauseUnknown'] -FontWeight normal, bold
                }
            }
        } -FontSize 10pt -LineBreak
        New-HTMLText -Text 'Assesment split per domain (will require permissions to fix): ' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['NetLogonPermissions']['Variables']['PermissionWriteReviewPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires review of ", $Script:Reporting['NetLogonPermissions']['Variables']['PermissionFullControlReviewPerDomain'][$Domain], " full control" -FontWeight normal, bold, normal
                New-HTMLListItem -Text "$Domain requires review of ", $Script:Reporting['NetLogonPermissions']['Variables']['PermissionModifyReviewPerDomain'][$Domain], " modify permission" -FontWeight normal, bold, normal
                New-HTMLListItem -Text "$Domain requires review of ", $Script:Reporting['NetLogonPermissions']['Variables']['PermissionWriteReviewPerDomain'][$Domain], " write permission" -FontWeight normal, bold, normal
                New-HTMLListItem -Text "$Domain requires removal of ", $Script:Reporting['NetLogonPermissions']['Variables']['PermissionRemovalRequiredPerDomain'][$Domain], " permissions" -FontWeight normal, bold, normal
            }
        } -FontSize 10pt
        New-HTMLText -Text "Please review output in table and follow the steps below table to get NetLogon permissions in order." -FontSize 10pt
    }
    Solution       = {
        # New-HTMLTab -Name 'NetLogon Owners' {
        #     New-HTMLSection -Invisible {
        #         New-HTMLPanel {
        #             & $Script:GPOConfiguration['NetLogonPermissions']['Summary']
        #         }
        #         New-HTMLPanel {
        #             New-HTMLChart {
        #                 New-ChartPie -Name 'Correct Owners' -Value $Script:Reporting['NetLogonPermissions']['Variables']['NetLogonOwnersAdministrators'] -Color LightGreen
        #                 New-ChartPie -Name 'Incorrect Owners' -Value $Script:Reporting['NetLogonPermissions']['Variables']['NetLogonOwnersToFix'] -Color Crimson
        #             } -Title 'NetLogon Owners' -TitleAlignment center
        #         }
        #     }
        #     New-HTMLSection -Name 'NetLogon File Owners' {
        #         New-HTMLTable -DataTable $Script:Reporting['NetLogonPermissions']['Variables']['Owner'] -Filtering {
        #             New-HTMLTableCondition -Name 'PrincipalSid' -Value "S-1-5-32-544" -BackgroundColor LightGreen -ComparisonType string
        #             New-HTMLTableCondition -Name 'PrincipalSid' -Value "S-1-5-32-544" -BackgroundColor Salmon -ComparisonType string -Operator ne
        #             New-HTMLTableCondition -Name 'PrincipalType' -Value "WellKnownAdministrative" -BackgroundColor LightGreen -ComparisonType string -Operator eq
        #             New-HTMLTableCondition -Name 'Status' -Value "OK" -BackgroundColor LightGreen -ComparisonType string -Operator eq
        #             New-HTMLTableCondition -Name 'Status' -Value "OK" -BackgroundColor Salmon -ComparisonType string -Operator ne
        #         }
        #     }
        #     New-HTMLSection -Name 'Steps to fix NetLogon Owners ' {
        #         New-HTMLContainer {
        #             New-HTMLSpanStyle -FontSize 10pt {
        #                 New-HTMLText -Text 'Following steps will guide you how to fix NetLogon Owners and make them compliant.'
        #                 New-HTMLWizard {
        #                     New-HTMLWizardStep -Name 'Prepare environment' {
        #                         New-HTMLText -Text "To be able to execute actions in automated way please install required modules. Those modules will be installed straight from Microsoft PowerShell Gallery."
        #                         New-HTMLCodeBlock -Code {
        #                             Install-Module GPOZaurr -Force
        #                             Import-Module GPOZaurr -Force
        #                         } -Style powershell
        #                         New-HTMLText -Text "Using force makes sure newest version is downloaded from PowerShellGallery regardless of what is currently installed. Once installed you're ready for next step."
        #                     }
        #                     New-HTMLWizardStep -Name 'Prepare report' {
        #                         New-HTMLText -Text "Depending when this report was run you may want to prepare new report before proceeding with removal. To generate new report please use:"
        #                         New-HTMLCodeBlock -Code {
        #                             Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrNetLogonBefore.html -Verbose -Type NetLogon
        #                         }
        #                         New-HTMLText -TextBlock {
        #                             "When executed it will take a while to generate all data and provide you with new report depending on size of environment."
        #                             "Once confirmed that data is still showing issues and requires fixing please proceed with next step."
        #                         }
        #                         New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
        #                         New-HTMLCodeBlock -Code {
        #                             $NetLogonOutput = Get-GPOZaurrNetLogon -OwnerOnly -Verbose
        #                             $NetLogonOutput | Format-Table
        #                         }
        #                         New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
        #                     }
        #                     New-HTMLWizardStep -Name 'Set non-compliant file owners to BUILTIN\Administrators' {
        #                         New-HTMLText -Text "Following command when executed runs internally command that lists all file owners and if it doesn't match changes it BUILTIN\Administrators. It doesn't change compliant owners."
        #                         New-HTMLText -Text "Make sure when running it for the first time to run it with ", "WhatIf", " parameter as shown below to prevent accidental removal." -FontWeight normal, bold, normal -Color Black, Red, Black

        #                         New-HTMLCodeBlock -Code {
        #                             Repair-GPOZaurrNetLogonOwner -Verbose -WhatIf
        #                         }
        #                         New-HTMLText -TextBlock {
        #                             "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be changed matches expected data. Once happy with results please follow with command: "
        #                         }
        #                         New-HTMLCodeBlock -Code {
        #                             Repair-GPOZaurrNetLogonOwner -Verbose -LimitProcessing 2
        #                         }
        #                         New-HTMLText -TextBlock {
        #                             "This command when executed sets new owner only on first X non-compliant NetLogon files. Use LimitProcessing parameter to prevent mass change and increase the counter when no errors occur."
        #                             "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
        #                         }
        #                     }
        #                     New-HTMLWizardStep -Name 'Verification report' {
        #                         New-HTMLText -TextBlock {
        #                             "Once cleanup task was executed properly, we need to verify that report now shows no problems."
        #                         }
        #                         New-HTMLCodeBlock -Code {
        #                             Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrNetLogonAfter.html -Verbose -Type NetLogon
        #                         }
        #                         New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
        #                     }
        #                 } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center -EnableAllAnchors
        #             }
        #         }
        #     }
        #     if ($Script:Reporting['NetLogonPermissions']['WarningsAndErrors']) {
        #         New-HTMLSection -Name 'Warnings & Errors to Review' {
        #             New-HTMLTable -DataTable $Script:Reporting['NetLogonPermissions']['WarningsAndErrors'] -Filtering {
        #                 New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
        #                 New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
        #             }
        #         }
        #     }
        # }
        #New-HTMLTab -Name 'NetLogon Permissions' {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['NetLogonPermissions']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartPie -Name 'Full Control requiring review' -Value $Script:Reporting['NetLogonPermissions']['Variables']['PermissionFullControlReview'] -Color Crimson
                    New-ChartPie -Name 'Modify requiring review' -Value $Script:Reporting['NetLogonPermissions']['Variables']['PermissionModifyReview'] -Color Plum
                    New-ChartPie -Name 'Write requiring review' -Value $Script:Reporting['NetLogonPermissions']['Variables']['PermissionWriteReview'] -Color LightCoral
                    New-ChartPie -Name 'Permissions OK' -Value $Script:Reporting['NetLogonPermissions']['Variables']['PermissionOK'] -Color LightGreen
                    New-ChartPie -Name 'Permissions ReadOnly/Execute' -Value $Script:Reporting['NetLogonPermissions']['Variables']['PermissionNotAssesed'] -Color Aqua
                } -Title 'NetLogon Permissions' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'NetLogon Files List' {
            New-HTMLTable -DataTable $Script:Reporting['NetLogonPermissions']['Data'] -Filtering {
                New-HTMLTableCondition -Name 'PrincipalType' -Value "Unknown" -BackgroundColor Salmon -ComparisonType string -Operator eq -Row
                New-HTMLTableCondition -Name 'PrincipalType' -Value "WellKnownAdministrative" -BackgroundColor LightGreen -ComparisonType string -Operator eq -Row
                New-HTMLTableCondition -Name 'Status' -Value "Review permission required" -BackgroundColor PaleGoldenrod -ComparisonType string -Operator eq
                New-HTMLTableCondition -Name 'Status' -Value "Removal permission required" -BackgroundColor Salmon -ComparisonType string -Operator eq -Row
                New-HTMLTableCondition -Name 'Status' -Value "OK" -BackgroundColor LightGreen -ComparisonType string -Operator eq
            }
        }
        if ($Script:Reporting['Settings']['HideSteps'] -eq $false) {
            New-HTMLSection -Name 'Steps to fix NetLogon Permissions ' {
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
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrNetLogonBefore.html -Verbose -Type NetLogonPermissions
                                }
                                New-HTMLText -TextBlock {
                                    "When executed it will take a while to generate all data and provide you with new report depending on size of environment. "
                                    "Once confirmed that data is still showing issues and requires fixing please proceed with next step. "
                                }
                                New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                                New-HTMLCodeBlock -Code {
                                    $NetLogonOutput = Get-GPOZaurrNetLogon -SkipOwner -Verbose
                                    $NetLogonOutput | Format-Table
                                }
                                New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
                            }
                            New-HTMLWizardStep -Name 'Remove permissions manually for non-compliant users/groups' {
                                New-HTMLText -Text @(
                                    "In case of NETLOGON permissions it's impossible to tell what in a given moment for given domain should be automatically removed except for the very obvious ",
                                    "unknown ", 'permissions. Domain Admins have to make their assesment on and remove permissions from users or groups that '
                                ) -FontWeight normal, bold, normal
                            }
                            New-HTMLWizardStep -Name 'Verification report' {
                                New-HTMLText -TextBlock {
                                    "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                                }
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrNetLogonAfter.html -Verbose -Type NetLogonPermissions
                                }
                                New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                            }
                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center -EnableAllAnchors
                    }
                }
            }
        }
        if ($Script:Reporting['NetLogonPermissions']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['NetLogonPermissions']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}