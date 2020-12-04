$GPOZaurrPermissionsAdministrative = [ordered] @{
    Name       = 'Group Policy Administrative Permissions'
    Enabled    = $true
    Action     = $null
    Data       = $null
    Execute    = {
        $Object = [ordered] @{
            Permissions = Get-GPOZaurrPermission -Type Administrative -IncludePermissionType GpoEditDeleteModifySecurity -ReturnSecurityWhenNoData -IncludeGPOObject -ReturnSingleObject -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
        }
        $Object['PermissionsPerRow'] = $Object['Permissions'] | ForEach-Object { $_ }
        $Object
    }
    Processing = {
        # Create Per Domain Variables
        $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillFixPerDomain'] = @{}
        $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillNotTouchPerDomain'] = @{}

        foreach ($GPO in $Script:Reporting['GPOPermissionsAdministrative']['Data'].Permissions) {
            # Create Per Domain Variables
            if (-not $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillFixPerDomain'][$GPO[0].DomainName]) {
                $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillFixPerDomain'][$GPO[0].DomainName] = 0
            }
            if (-not $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillNotTouchPerDomain'][$GPO[0].DomainName]) {
                $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillNotTouchPerDomain'][$GPO[0].DomainName] = 0
            }
            # Checks

            $Analysis = Get-PermissionsAnalysis -GPOPermissions $GPO -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -Type Administrative -PermissionType GpoEditDeleteModifySecurity
            if ($Analysis.Skip) {
                $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillNotTouch']++
                $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillNotTouchPerDomain'][$GPO[0].DomainName]++
            } else {
                $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillFix']++
                $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillFixPerDomain'][$GPO[0].DomainName]++
            }
        }
        if ($Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillFix'] -gt 0) {
            $Script:Reporting['GPOPermissionsAdministrative']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOPermissionsAdministrative']['ActionRequired'] = $false
        }
    }
    Variables  = @{
        WillFix               = 0
        WillNotTouch          = 0
        WillFixPerDomain      = $null
        WillNotTouchPerDomain = $null
    }
    Overview   = {

    }
    Summary    = {
        New-HTMLText -FontSize 10pt -TextBlock {
            "When GPO is created by default it gets Domain Admins and Enterprise Admins with Edit/Delete/Modify Security permissions. "
            "For some reason, some Administrators remove those permissions or modify them when they shouldn't touch those at all. "
            "Since having Edit/Delete/Modify Security permissions doesn't affect GPOApply permissions there's no reason to remove Domain Admins or Enterprise Admins from permissions, or limit their rights. "
        } -LineBreak
        New-HTMLText -FontSize 10pt -Text "Assesment results: " -FontWeight bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies requiring adding Domain Admins or Enterprise Admins: ', $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillFix'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies which don't require changes: ", $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillNotTouch'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillFixPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillFixPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
        } -FontSize 10pt
        New-HTMLText -Text @(
            "That means we need to fix permissions on: "
            $($Script:Reporting['GPOPermissionsAdministrative']['Variables'].WillFix)
            " out of "
            $($Script:Reporting['GPOPermissionsAdministrative']['Data'].Permissions).Count
            " Group Policies. "
        ) -FontSize 10pt -FontWeight bold, bold, normal, bold, normal -Color Black, FreeSpeechRed, Black, Black -LineBreak -TextDecoration none, underline, underline, underline, none
    }
    Solution   = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPOPermissionsAdministrative']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartBarOptions -Type barStacked
                    New-ChartLegend -Name 'Yes', 'No' -Color LightGreen, Salmon
                    New-ChartBar -Name 'Administrative Users Present' -Value $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillNotTouch'], $Script:Reporting['GPOPermissionsAdministrative']['Variables']['WillFix']
                    #New-ChartBar -Name 'Accessible Group Policies' -Value $Script:Reporting['GPOPermissionsAdministrative']['Variables']['Read'], $Script:Reporting['GPOPermissionsAdministrative']['Variables']['CouldNotRead']
                } -Title 'Group Policy Permissions' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policy Administrative Users Analysis' {
            New-HTMLTable -DataTable $Script:Reporting['GPOPermissionsAdministrative']['Data'].PermissionsPerRow -Filtering {
                New-HTMLTableCondition -Name 'Permission' -Value '' -BackgroundColor Salmon -ComparisonType string -Row
            } -PagingOptions 7, 15, 30, 45, 60
        }
        if ($Script:Reporting['Settings']['HideSteps'] -eq $false) {
            New-HTMLSection -Name 'Steps to fix Group Policy Administrative Users' {
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
                                New-HTMLText -Text "Depending when this report was run you may want to prepare new report before proceeding with fixing Group Policy Authenticated Users. To generate new report please use:"
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrGPOPermissionsAdministrativeBefore.html -Verbose -Type GPOPermissionsAdministrative
                                }
                                New-HTMLText -TextBlock {
                                    "When executed it will take a while to generate all data and provide you with new report depending on size of environment. "
                                    "GPOs with problems will be those not having any value for Permission/PermissionType columns. "
                                    "Once confirmed that data is still showing issues and requires fixing please proceed with next step."
                                }
                                New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                                New-HTMLCodeBlock -Code {
                                    $AdministrativeUsers = Get-GPOZaurrPermission -Type Administrative -IncludePermissionType GpoEditDeleteModifySecurity -ReturnSecurityWhenNoData
                                    $AdministrativeUsers | Format-Table
                                }
                                New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
                            }
                            New-HTMLWizardStep -Name 'Make a backup (optional)' {
                                New-HTMLText -TextBlock {
                                    "The process of fixing GPO Permissions does NOT touch GPO content. It simply adds permissionss on AD and SYSVOL at the same time for given GPO. "
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

                            New-HTMLWizardStep -Name 'Add Administrative Groups proper permissions GPO' {
                                New-HTMLText -Text @(
                                    "Following command will find any GPO which doesn't have Domain Admins and Enterprise Admins added with GpoEditDeleteModifySecurity and will add it as GpoEditDeleteModifySecurity. ",
                                    "This change doesn't change GpoApply permission, therefore it won't change to whom the GPO applies to. ",
                                    "It ensures that Domain Admins and Enterprise Admins can manage GPO. ",
                                    "Make sure when running it for the first time to run it with ",
                                    "WhatIf",
                                    " parameter as shown below to prevent accidental adding of permissions."
                                ) -FontWeight normal, normal, normal, normal, bold, normal -Color Black, Black, Black, Black, Red, Black
                                New-HTMLCodeBlock -Code {
                                    Add-GPOZaurrPermission -Type Administrative -PermissionType GpoEditDeleteModifySecurity -All -WhatIf -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Add-GPOZaurrPermission -Type Administrative -PermissionType GpoEditDeleteModifySecurity -All -WhatIf -Verbose -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be changed matches expected data."
                                } -LineBreak
                                New-HTMLText -Text "Once happy with results please follow with command (this will start fixing process): " -LineBreak -FontWeight bold
                                New-HTMLCodeBlock -Code {
                                    Add-GPOZaurrPermission -Type Administrative -PermissionType GpoEditDeleteModifySecurity -All -Verbose -LimitProcessing 2
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Add-GPOZaurrPermission -Type Administrative -PermissionType GpoEditDeleteModifySecurity -All -Verbose -LimitProcessing 2 -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "This command when executed adds Enterprise Admins or/and Domain Admins (GpoEditDeleteModifySecurity permission) only on first X non-compliant Group Policies. "
                                    "Use LimitProcessing parameter to prevent mass change and increase the counter when no errors occur. "
                                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. "
                                    "In case of any issues please review and action accordingly. "
                                }
                            }
                            New-HTMLWizardStep -Name 'Verification report' {
                                New-HTMLText -TextBlock {
                                    "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                                }
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrGPOPermissionsAdministrativeAfter.html -Verbose -Type GPOPermissionsAdministrative
                                }
                                New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                            }
                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                    }
                }
            }
        }
        if ($Script:Reporting['GPOPermissionsAdministrative']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOPermissionsAdministrative']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                } -PagingOptions 10, 20, 30, 40, 50
            }
        }
    }
}