$GPOZaurrOrphans = [ordered] @{
    Name           = 'Orphaned Group Policies'
    Enabled        = $true
    ActionRequired = $null
    Data           = $null
    Execute        = {
        Get-GPOZaurrBroken -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing     = {
        $Script:Reporting['GPOOrphans']['Variables']['ToBeDeletedPerDomain'] = @{}
        $Script:Reporting['GPOOrphans']['Variables']['NotAvailablePermissionIssuePerDomain'] = @{}
        foreach ($GPO in $Script:Reporting['GPOOrphans']['Data']) {
            if (-not $Script:Reporting['GPOOrphans']['Variables']['ToBeDeletedPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOOrphans']['Variables']['ToBeDeletedPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOOrphans']['Variables']['NotAvailablePermissionIssuePerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOOrphans']['Variables']['NotAvailablePermissionIssuePerDomain'][$GPO.DomainName] = 0
            }
            if ($GPO.Status -eq 'Not available in AD') {
                $Script:Reporting['GPOOrphans']['Variables']['NotAvailableInAD']++
                $Script:Reporting['GPOOrphans']['Variables']['ToBeDeleted']++
                $Script:Reporting['GPOOrphans']['Variables']['ToBeDeletedPerDomain'][$GPO.DomainName]++
            } elseif ($GPO.Status -eq 'Not available on SYSVOL') {
                $Script:Reporting['GPOOrphans']['Variables']['NotAvailableOnSysvol']++
                $Script:Reporting['GPOOrphans']['Variables']['ToBeDeleted']++
                $Script:Reporting['GPOOrphans']['Variables']['ToBeDeletedPerDomain'][$GPO.DomainName]++
            } elseif ($GPO.Status -eq 'Permissions issue') {
                $Script:Reporting['GPOOrphans']['Variables']['NotAvailablePermissionIssue']++
                $Script:Reporting['GPOOrphans']['Variables']['NotAvailablePermissionIssuePerDomain'][$GPO.DomainName]++
            }
        }
        if ($Script:Reporting['GPOOrphans']['Variables']['ToBeDeleted'] -gt 0) {
            $Script:Reporting['GPOOrphans']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOOrphans']['ActionRequired'] = $false
        }
    }
    Variables      = @{
        NotAvailableInAD                     = 0
        NotAvailableOnSysvol                 = 0
        NotAvailablePermissionIssue          = 0
        NotAvailablePermissionIssuePerDomain = $null
        ToBeDeleted                          = 0
        ToBeDeletedPerDomain                 = $null
    }
    Overview       = {
        <#
        New-HTMLPanel {
            New-HTMLText -TextBlock {
                "Group Policies are stored in two places - Active Directory (metadata) and SYSVOL (content)."
                "Since those are managed in different ways, replicated in different ways it's possible because of different issues they get out of sync."
            } -LineBreak
            New-HTMLText -Text "For example:"
            New-HTMLList -Type Unordered {
                New-HTMLListItem -Text 'USN Rollback in AD could cause group policies to reappar in Active Directory, yet SYSVOL data would be unavailable'
                New-HTMLListItem -Text 'Group Policy deletion failing to delete GPO content'
                New-HTMLListItem -Text 'DFSR replication failing between DCs'
            }
            New-HTMLText -Text 'Following chart presents ', 'Broken / Orphaned Group Policies' -FontSize 10pt -FontWeight normal, bold
            New-HTMLList -Type Unordered {
                New-HTMLListItem -Text 'Group Policies on SYSVOL, but no details in AD: ', $Script:Reporting['GPOOrphans']['Variables']['NotAvailableInAD'] -FontWeight normal, bold
                New-HTMLListItem -Text 'Group Policies in AD, but no content on SYSVOL: ', $Script:Reporting['GPOOrphans']['Variables']['NotAvailableOnSysvol'] -FontWeight normal, bold
                New-HTMLListItem -Text "Group Policies which couldn't be assed due to permissions issue: ", $Script:Reporting['GPOOrphans']['Variables']['NotAvailablePermissionIssue'] -FontWeight normal, bold
            } -FontSize 10pt
            New-HTMLText -FontSize 10pt -Text 'Those problems must be resolved before doing other clenaup activities.'
            New-HTMLChart {
                New-ChartBarOptions -Type barStacked
                New-ChartLegend -Name 'Not in AD', 'Not on SYSVOL', 'Permissions Issue' -Color Crimson, LightCoral, IndianRed
                New-ChartBar -Name 'Orphans' -Value $Script:Reporting['GPOOrphans']['Variables']['NotAvailableInAD'], $Script:Reporting['GPOOrphans']['Variables']['NotAvailableOnSysvol'], $Script:Reporting['GPOOrphans']['Variables']['NotAvailablePermissionIssue']
            } -Title 'Broken / Orphaned Group Policies' -TitleAlignment center
        }
        #>
    }
    Summary        = {
        New-HTMLText -TextBlock {
            "Group Policies are stored in two places - Active Directory (metadata) and SYSVOL (content)."
            "Since those are managed in different ways, replicated in different ways it's possible because of different issues they get out of sync."
        } -FontSize 10pt -LineBreak
        New-HTMLText -Text "For example:" -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'USN Rollback in AD could cause already deleted Group Policies to reapper in Active Directory, yet SYSVOL data would be unavailable'
            New-HTMLListItem -Text 'Group Policy deletion failing to delete GPO content'
            New-HTMLListItem -Text 'Permission issue preventing deletion of GPO content'
            New-HTMLListItem -Text 'Failing DFSR replication between DCs'
        } -FontSize 10pt
        New-HTMLText -Text 'Following problems were detected:' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies on SYSVOL, but no details in AD: ', $Script:Reporting['GPOOrphans']['Variables']['NotAvailableInAD'] -FontWeight normal, bold
            New-HTMLListItem -Text 'Group Policies in AD, but no content on SYSVOL: ', $Script:Reporting['GPOOrphans']['Variables']['NotAvailableOnSysvol'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies which couldn't be assed due to permissions issue: ", $Script:Reporting['GPOOrphans']['Variables']['NotAvailablePermissionIssue'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOOrphans']['Variables']['ToBeDeletedPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOOrphans']['Variables']['ToBeDeletedPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
        } -FontSize 10pt
        New-HTMLText -Text "Please review output in table and follow the steps below table to get Active Directory Group Policies in healthy state." -FontSize 10pt
    }
    Solution       = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPOOrphans']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartBarOptions -Type barStacked
                    New-ChartLegend -Name 'Not in AD', 'Not on SYSVOL', 'Permissions Issue' -Color Crimson, LightCoral, IndianRed
                    New-ChartBar -Name 'Orphans' -Value $Script:Reporting['GPOOrphans']['Variables']['NotAvailableInAD'], $Script:Reporting['GPOOrphans']['Variables']['NotAvailableOnSysvol'], $Script:Reporting['GPOOrphans']['Variables']['NotAvailablePermissionIssue']
                } -Title 'Broken / Orphaned Group Policies' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Health State of Group Policies' {
            New-HTMLTable -DataTable $Script:Reporting['GPOOrphans']['Data'] -Filtering {
                New-HTMLTableCondition -Name 'Status' -Value "Not available in AD" -BackgroundColor Salmon -ComparisonType string
                New-HTMLTableCondition -Name 'Status' -Value "Not available on SYSVOL" -BackgroundColor LightCoral -ComparisonType string
                New-HTMLTableCondition -Name 'Status' -Value "Permissions issue" -BackgroundColor MediumVioletRed -ComparisonType string -Color White
            } -PagingOptions 10, 20, 30, 40, 50
        }
        if ($Script:Reporting['Settings']['HideSteps'] -eq $false) {
            New-HTMLSection -Name 'Steps to fix - Not available on SYSVOL / Active Directory' {
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
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrBrokenGpoBefore.html -Verbose -Type GPOOrphans
                                }
                                New-HTMLText -TextBlock {
                                    "When executed it will take a while to generate all data and provide you with new report depending on size of environment."
                                    "Once confirmed that data is still showing issues and requires fixing please proceed with next step."
                                }
                                New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                                New-HTMLCodeBlock -Code {
                                    $GPOOutput = Get-GPOZaurrBroken -Verbose
                                    $GPOOutput | Format-Table
                                }
                                New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
                            }
                            New-HTMLWizardStep -Name 'Make a backup (optional)' {
                                New-HTMLText -TextBlock {
                                    "The process fixing broken GPOs will delete AD or SYSVOL content depending on type of a problem. "
                                    "While it's always useful to have a backup, this backup won't actually backup those broken group policies"
                                    " for a simple reason that those are not backupable. You can't back up GPO if there is no SYSVOL content"
                                    " and you can't backup GPO if there's only SYSVOL content. "
                                    "However, since the script does make changes to GPOs it's advised to have a backup anyways! "
                                }
                                New-HTMLCodeBlock -Code {
                                    $GPOSummary = Backup-GPOZaurr -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -Type All
                                    $GPOSummary | Format-Table # only if you want to display output of backup
                                }
                                New-HTMLText -TextBlock {
                                    "Above command when executed will make a backup to Desktop, create GPO folder and within it it will put all those GPOs. "
                                }
                            }
                            New-HTMLWizardStep -Name 'Fix GPOs not available in AD' {
                                New-HTMLText -Text @(
                                    "Following command when executed runs cleanup procedure that removes all broken GPOs on SYSVOL side. ",
                                    "Make sure when running it for the first time to run it with ",
                                    "WhatIf ",
                                    "parameter as shown below to prevent accidental removal. ",
                                    'When run it will remove any GPO remains from SYSVOL, that should not be there, as AD metadata is already gone.'
                                    "Please notice I'm using SYSVOL as a type, because the removal will happen on SYSVOL. "
                                ) -FontWeight normal, normal, bold, normal -Color Black, Black, Red, Black
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurrBroken -Type SYSVOL -WhatIf -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurrBroken -Type SYSVOL -WhatIf -IncludeDomains 'YourDomainYouHavePermissionsFor' -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be deleted matches expected data. "
                                    "Keep in mind that what backup command does is simply copy SYSVOL content to given place. "
                                    "Since there is no GPO metadata in AD there's no real restore process for this step. "
                                    "It's there to make sure if someone kept some data in there and wants to get access to it, he/she can. "
                                } -LineBreak
                                New-HTMLText -Text "Once happy with results please follow with command (this will start deletion process): " -LineBreak -FontWeight bold

                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurrBroken -Type SYSVOL -LimitProcessing 2 -BackupPath $Env:UserProfile\Desktop\GPOSYSVOLBackup -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurrBroken -Type SYSVOL -LimitProcessing 2 -BackupPath $Env:UserProfile\Desktop\GPOSYSVOLBackup -IncludeDomains 'YourDomainYouHavePermissionsFor' -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "This command when executed deletes only first X broken GPOs. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur. "
                                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly. "
                                    "If there's nothing else to be deleted on SYSVOL side, we can skip to next step step. "
                                }
                            }
                            New-HTMLWizardStep -Name 'Fix GPOs not available on SYSVOL' {
                                New-HTMLText -Text @(
                                    "Following command when executed runs cleanup procedure that removes all broken GPOs on Active Directory side."
                                    "Make sure when running it for the first time to run it with ",
                                    "WhatIf",
                                    " parameter as shown below to prevent accidental removal."
                                    'When run it will remove any GPO remains from AD, that should not be there, as SYSVOL content is already gone.'
                                    "Please notice I'm using AD as a type, because the removal will happen on AD side. "
                                ) -FontWeight normal, normal, bold, normal -Color Black, Black, Red, Black
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurrBroken -Type AD -WhatIf -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurrBroken -Type AD -WhatIf -IncludeDomains 'YourDomainYouHavePermissionsFor' -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be deleted matches expected data. "
                                    "Keep in mind that there is no backup for this. "
                                    "Since there is no SYSVOL data, and only AD object is there there's no real restore process for this step. "
                                    "Once you delete it, it's gone. "
                                } -LineBreak
                                New-HTMLText -Text 'Once happy with results please follow with command (this will start deletion process): ' -LineBreak -FontWeight bold
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurrBroken -Type AD -LimitProcessing 2 -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurrBroken -Type AD -LimitProcessing 2 -IncludeDomains 'YourDomainYouHavePermissionsFor' -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "This command when executed deletes only first X broken GPOs. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur. "
                                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly. "
                                    "If there's nothing else to be deleted on AD side, we can skip to next step step. "
                                }
                            }
                            New-HTMLWizardStep -Name 'Verification report' {
                                New-HTMLText -TextBlock {
                                    "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                                }
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrBrokenGpoAfter.html -Verbose -Type GPOOrphans
                                }
                                New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                            }
                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                    }
                }
            }
        }
        if ($Script:Reporting['GPOOrphans']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOOrphans']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}