$GPOZaurrOrganizationalUnit = [ordered] @{
    Name           = 'Group Policy Organizational Units'
    Enabled        = $true
    ActionRequired = $null
    Data           = $null
    Execute        = {
        Get-GPOZaurrOrganizationalUnit -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing     = {
        # Create Per Domain Variables
        $Script:Reporting['GPOOrganizationalUnit']['Variables']['RequiresDiffFixPerDomain'] = @{}
        $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFixPerDomain'] = @{}
        foreach ($OU in $Script:Reporting['GPOOrganizationalUnit']['Data']) {

            # Create Per Domain Variables
            if (-not $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFixPerDomain'][$OU.DomainName]) {
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFixPerDomain'][$OU.DomainName] = 0
            }

            if ($OU.Status -eq 'Unlink GPO') {
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['UnlinkGPO']++
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFix']++
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFixPerDomain'][$OU.DomainName]++
            } elseif ($OU.Status -eq 'Unlink GPO', 'Delete OU') {
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['UnlinkGPODeleteOU']++
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFix']++
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFixPerDomain'][$OU.DomainName]++
            } elseif ($OU.Status -eq 'Delete OU') {
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['DeleteOU']++
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFix']++
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFixPerDomain'][$OU.DomainName]++
            } else {
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['Legitimate']++

            }

            <#
            # Checks
            if ($OU.GPOCount -eq 0 -and $OU.ObjectCount -eq 0) {
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['OUWithoutObjectsAndGPOs']++
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFix']++
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFixPerDomain'][$OU.DomainName]++
            } elseif ($OU.GPOCount -gt 0 -and $OU.ObjectCount -eq 0) {
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['OUWithGPOsAndNoObjects']++
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFix']++
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFixPerDomain'][$OU.DomainName]++
            } elseif ($OU.GPOCount -gt 0 -and $OU.ObjectCount -gt 0) {
                $ObjectsFound = $false
                foreach ($ObjectClass in $OU.ObjectClasses) {
                    if ($ObjectClass -in @('user', 'computer')) {
                        $ObjectsFound = $true
                    }
                }
                if ($ObjectsFound) {
                    $Script:Reporting['GPOOrganizationalUnit']['Variables']['OUWithBoth']++
                } else {
                    $Script:Reporting['GPOOrganizationalUnit']['Variables']['OUWithGPOsAndNoProperObjects']++
                    $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFix']++
                }
            } elseif ($OU.GPOCount -eq 0 -and $OU.ObjectCount -gt 0) {
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['OUWithObjectsAndNoGPO']++
            } else {
                $Script:Reporting['GPOOrganizationalUnit']['Variables']['OUWithBoth']++
            }

            #>
        }
        if ($Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFix'] -gt 0) {
            $Script:Reporting['GPOOrganizationalUnit']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOOrganizationalUnit']['ActionRequired'] = $false
        }
    }
    Variables      = @{
        UnlinkGPO         = 0
        UnlinkGPODeleteOU = 0
        DeleteOU          = 0
        Legitimate        = 0
        WillFix           = 0
        WillFixPerDomain  = $null
    }
    Overview       = {

    }
    Summary        = {
        New-HTMLText -FontSize 10pt -Text @(
            "In most Active Directories there are a lot of Organizational Units that have different use cases to store different type of objects. "
            "As Active Directories change over time you can often find Organizational Units with linked GPOs and no objects inside. "
            "In some cases thats's expected, but in some cases it's totally unnessecary, and for very large AD can be a problem. "
        )

        New-HTMLText -Text "Here's a short summary of ", "Organizational Units", ": " -FontSize 10pt -FontWeight normal, bold, normal
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Organizational Units without any Objects and Group Policies: ', $Script:Reporting['GPOOrganizationalUnit']['Variables']['OUWithoutObjectsAndGPOs'] -FontWeight normal, bold
            New-HTMLListItem -Text 'Organizational Units with Group Policies, but without any objects: ', $Script:Reporting['GPOOrganizationalUnit']['Variables']['OUWithGPOsAndNoObjects'] -FontWeight normal, bold
            New-HTMLListItem -Text 'Organizational Units with Group Policies, but without computer/user objects: ', $Script:Reporting['GPOOrganizationalUnit']['Variables']['OUWithGPOsAndNoProperObjects'] -FontWeight normal, bold
            New-HTMLListItem -Text "Organizational Units with Group Policies and with objects: ", $Script:Reporting['GPOOrganizationalUnit']['Variables']['OUWithBoth'] -FontWeight normal, bold
            New-HTMLListItem -Text "Organizational Units with Objects, but no directly linked Group Policies: ", $Script:Reporting['GPOOrganizationalUnit']['Variables']['OUWithObjectsAndNoGPO'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -FontSize 10pt -Text "Following will need to happen: " -FontWeight bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Organizational Units that can have Group Policies unlinked (objects exists): ', $Script:Reporting['GPOOrganizationalUnit']['Variables']['UnlinkGPO'] -FontWeight normal, bold
            New-HTMLListItem -Text 'Organizational Units that can have Group Policies unlinked and OU removed (be careful!) (no objects): ', $Script:Reporting['GPOOrganizationalUnit']['Variables']['UnlinkGPODeleteOU'] -FontWeight normal, bold
            New-HTMLListItem -Text "Organizational Units that can be deleted (no objects/no gpos): ", $Script:Reporting['GPOOrganizationalUnit']['Variables']['DeleteOU'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFixPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOOrganizationalUnit']['Variables']['WillFixPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
        } -FontSize 10pt
    }
    Solution       = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPOOrganizationalUnit']['Summary']
            }
            New-HTMLPanel {
                <#
                New-HTMLChart {
                    New-ChartBarOptions -Type barStacked
                    New-ChartLegend -Name 'Yes', 'No' -Color LightGreen, Salmon
                    New-ChartBar -Name 'Is administrative' -Value $Script:Reporting['GPOOrganizationalUnit']['Variables']['IsAdministrative'], $Script:Reporting['GPOOrganizationalUnit']['Variables']['IsNotAdministrative']
                    New-ChartBar -Name 'Is consistent' -Value $Script:Reporting['GPOOrganizationalUnit']['Variables']['IsConsistent'], $Script:Reporting['GPOOrganizationalUnit']['Variables']['IsNotConsistent']
                } -Title 'Group Policy Owners' -TitleAlignment center
                #>
            }
        }
        New-HTMLSection -Name 'Group Policy Organizational Units' {
            New-HTMLTable -DataTable $Script:Reporting['GPOOrganizationalUnit']['Data'] -Filtering {
                #New-HTMLTableCondition -Name 'IsOwnerConsistent' -Value $false -BackgroundColor Salmon -ComparisonType string -Row
                #New-HTMLTableCondition -Name 'IsOwnerAdministrative' -Value $false -BackgroundColor Salmon -ComparisonType string -Row
                New-HTMLTableCondition -Name 'Status' -ComparisonType string -Value 'Unlink GPO, Delete OU' -BackgroundColor Salmon -Row
                New-HTMLTableCondition -Name 'Status' -ComparisonType string -Value 'Unlink GPO' -BackgroundColor YellowOrange -Row
                New-HTMLTableCondition -Name 'Status' -ComparisonType string -Value 'Delete OU' -BackgroundColor Red -Row
                New-HTMLTableCondition -Name 'Status' -ComparisonType string -Value 'OK' -BackgroundColor LightGreen -Row
                <#
                New-HTMLTableConditionGroup {
                    New-HTMLTableCondition -Name 'GPOCount' -Value 0 -ComparisonType number -Operator eq
                    New-HTMLTableCondition -Name 'ObjectCount' -Value 0 -ComparisonType number -Operator eq
                    New-HTMLTableCondition -Name 'Level' -Value 'Child' -ComparisonType string -Operator eq
                } -HighlightHeaders 'GPOCount', 'ObjectCount' -BackgroundColor Salmon -FailBackgroundColor LightGreen
                #>
            } -PagingOptions 10, 20, 30, 40, 50 -SearchBuilder
        }
        if ($Script:Reporting['Settings']['HideSteps'] -eq $false) {
            New-HTMLSection -Name 'Steps to fix Group Organizational Units' {
                New-HTMLContainer {
                    New-HTMLSpanStyle -FontSize 10pt {
                        #New-HTMLText -Text 'Following steps will guide you how to fix group policy owners'
                        New-HTMLWizard {
                            New-HTMLWizardStep -Name 'Prepare environment' {
                                New-HTMLText -Text "To be able to execute actions in automated way please install required modules. Those modules will be installed straight from Microsoft PowerShell Gallery."
                                New-HTMLCodeBlock -Code {
                                    Install-Module GPOZaurr -Force
                                    Import-Module GPOZaurr -Force
                                } -Style powershell
                                New-HTMLText -Text "Using force makes sure newest version is downloaded from PowerShellGallery regardless of what is currently installed. Once installed you're ready for next step."
                            }
                            <#
                            New-HTMLWizardStep -Name 'Prepare report' {
                                New-HTMLText -Text "Depending when this report was run you may want to prepare new report before proceeding with fixing Group Policy Owners. To generate new report please use:"
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrGPOOrganizationalUnitBefore.html -Verbose -Type GPOOrganizationalUnit
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
                                    "This command when executed sets new owner only on first X non-compliant GPO Owners for AD/SYSVOL. Use LimitProcessing parameter to prevent mass change and increase the counter when no errors occur. "
                                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly. "
                                }
                            }
                            New-HTMLWizardStep -Name 'Verification report' {
                                New-HTMLText -TextBlock {
                                    "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                                }
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrGPOOrganizationalUnitAfter.html -Verbose -Type GPOOrganizationalUnit
                                }
                                New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                            }
                            #>
                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center -EnableAllAnchors
                    }
                }
            }
        }
        if ($Script:Reporting['GPOOrganizationalUnit']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOOrganizationalUnit']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                } -PagingOptions 10, 20, 30, 40, 50
            }
        }
    }
}