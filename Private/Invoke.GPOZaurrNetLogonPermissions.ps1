$GPOZaurrNetLogonPermissions = [ordered] @{
    Name       = 'NetLogon Permissions'
    Enabled    = $true
    Data       = $null
    Execute    = {
        Get-GPOZaurrNetLogon
    }
    Processing = {
        foreach ($File in $GPOZaurrNetLogonPermissions['Data']) {
            if ($File.FileSystemRights -eq 'Owner') {
                $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwners']++
                if ($File.PrincipalType -eq 'WellKnownAdministrative') {
                    $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersAdministrative']++
                } elseif ($File.PrincipalType -eq 'Administrative') {
                    $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersAdministrative']++
                } else {
                    $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersNotAdministrative']++
                }
                if ($File.PrincipalSid -eq 'S-1-5-32-544') {
                    $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersAdministrators']++
                } elseif ($File.PrincipalType -in 'WellKnownAdministrative', 'Administrative') {
                    $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersAdministrativeNotAdministrators']++
                    $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersToFix']++
                } else {
                    $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersToFix']++
                }
                $GPOZaurrNetLogonPermissions['Variables']['Owner'].Add($File)
            } else {
                $GPOZaurrNetLogonPermissions['Variables']['NonOwner'].Add($File)
            }
        }
    }
    Variables  = @{
        NetLogonOwners                                = 0
        NetLogonOwnersAdministrators                  = 0
        NetLogonOwnersNotAdministrative               = 0
        NetLogonOwnersAdministrative                  = 0
        NetLogonOwnersAdministrativeNotAdministrators = 0
        NetLogonOwnersToFix                           = 0
        Owner                                         = [System.Collections.Generic.List[PSCustomObject]]::new()
        NonOwner                                      = [System.Collections.Generic.List[PSCustomObject]]::new()
    }
    Overview   = {
        New-HTMLPanel {
            New-HTMLText -Text 'Following chart presents ', 'NetLogon Summary' -FontSize 10pt -FontWeight normal, bold
            New-HTMLList -Type Unordered {
                New-HTMLListItem -Text 'NetLogon Files in Total: ', $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwners'] -FontWeight normal, bold
                New-HTMLListItem -Text 'NetLogon BUILTIN\Administrators as Owner: ', $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersAdministrators'] -FontWeight normal, bold
                New-HTMLListItem -Text "NetLogon Owners requiring change: ", $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersToFix'] -FontWeight normal, bold {
                    New-HTMLList -Type Unordered {
                        New-HTMLListItem -Text 'Not Administrative: ', $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersNotAdministrative'] -FontWeight normal, bold
                        New-HTMLListItem -Text 'Administrative, but not BUILTIN\Administrators: ', $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersAdministrativeNotAdministrators'] -FontWeight normal, bold
                    }
                }
            } -FontSize 10pt
            #New-HTMLText -FontSize 10pt -Text 'Those problems must be resolved before doing other clenaup activities.'
            New-HTMLChart {
                New-ChartPie -Name 'Correct Owners' -Value $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersAdministrators'] -Color LightGreen
                New-ChartPie -Name 'Incorrect Owners' -Value $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersToFix'] -Color Crimson
            } -Title 'NetLogon Owners' -TitleAlignment center
        }
        New-HTMLPanel {

        }
    }
    Solution   = {
        New-HTMLTab -Name 'NetLogon Owners' {
            New-HTMLSection -Invisible {
                New-HTMLPanel {
                    New-HTMLText -TextBlock {
                        "Following table shows NetLogon file owners. It's important that NetLogon file owners are set to BUILTIN\Administrators (SID: S-1-5-32-544). "
                        "Owners have full control over the file object. Current owner of the file may be an Administrator but it doesn't guarentee that he will be in the future. "
                        "That's why as a best-practice it's recommended to change any non-administrative owners to BUILTIN\Administrators, and even Administrative accounts should be replaced with it. "
                    } -FontSize 10pt
                    New-HTMLList -Type Unordered {
                        New-HTMLListItem -Text 'NetLogon Files in Total: ', $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwners'] -FontWeight normal, bold
                        New-HTMLListItem -Text 'NetLogon BUILTIN\Administrators as Owner: ', $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersAdministrators'] -FontWeight normal, bold
                        New-HTMLListItem -Text "NetLogon Owners requiring change: ", $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersToFix'] -FontWeight normal, bold {
                            New-HTMLList -Type Unordered {
                                New-HTMLListItem -Text 'Not Administrative: ', $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersNotAdministrative'] -FontWeight normal, bold
                                New-HTMLListItem -Text 'Administrative, but not BUILTIN\Administrators: ', $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersAdministrativeNotAdministrators'] -FontWeight normal, bold
                            }
                        }
                    } -FontSize 10pt
                    New-HTMLText -Text "Follow the steps below table to get NetLogon Owners into compliant state." -FontSize 10pt
                }
                New-HTMLPanel {
                    New-HTMLChart {
                        New-ChartPie -Name 'Correct Owners' -Value $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersAdministrators'] -Color LightGreen
                        New-ChartPie -Name 'Incorrect Owners' -Value $GPOZaurrNetLogonPermissions['Variables']['NetLogonOwnersToFix'] -Color Crimson
                    } -Title 'NetLogon Owners' -TitleAlignment center
                }
            }
            New-HTMLSection -Name 'NetLogon Files List' {
                New-HTMLTable -DataTable $GPOZaurrNetLogonPermissions['Variables']['Owner'] -Filtering {
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
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrNetLogonBefore.html -Verbose -Type NetLogon
                                }
                                New-HTMLText -TextBlock {
                                    "When executed it will take a while to generate all data and provide you with new report depending on size of environment."
                                    "Once confirmed that data is still showing issues and requires fixing please proceed with next step."
                                }
                                New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                                New-HTMLCodeBlock -Code {
                                    $NetLogonOutput = Get-GPOZaurrNetLogon -Verbose
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
                                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be changed matches expected data. Once happy with results please follow with command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Repair-GPOZaurrNetLogonOwner -Verbose -LimitProcessing 2
                                }
                                New-HTMLText -TextBlock {
                                    "This command when executed sets new owner only on first X non-compliant NetLogon files. Use LimitProcessing parameter to prevent mass change and increase the counter when no errors occur."
                                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
                                }
                            }
                            New-HTMLWizardStep -Name 'Verification report' {
                                New-HTMLText -TextBlock {
                                    "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                                }
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrNetLogonAfter.html -Verbose -Type NetLogon
                                }
                                New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                            }
                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                    }
                }
            }
        }
        New-HTMLTab -Name 'NetLogon Permissions' {
            New-HTMLSection -Name 'NetLogon Files List' {
                New-HTMLTable -DataTable $GPOZaurrNetLogonPermissions['Variables']['NonOwner'] -Filtering
            }
        }
    }
}