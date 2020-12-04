$GPOZaurrPermissionsRead = [ordered] @{
    Name       = 'Group Policy Authenticated Users Permissions'
    Enabled    = $true
    Action     = $null
    Data       = $null
    Execute    = {
        [ordered] @{
            Permissions = Get-GPOZaurrPermission -Type AuthenticatedUsers -ReturnSecurityWhenNoData -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
            Issues      = Get-GPOZaurrPermissionIssue
        }
    }
    Processing = {
        # This is a workaround - we need to use it since we have 0 permissions

        # Create Per Domain Variables
        $Script:Reporting['GPOPermissionsRead']['Variables']['WillFixPerDomain'] = @{}
        $Script:Reporting['GPOPermissionsRead']['Variables']['WillNotTouchPerDomain'] = @{}
        $Script:Reporting['GPOPermissionsRead']['Variables']['ReadPerDomain'] = @{}
        $Script:Reporting['GPOPermissionsRead']['Variables']['CouldNotReadPerDomain'] = @{}
        $Script:Reporting['GPOPermissionsRead']['Variables']['TotalPerDomain'] = @{}

        foreach ($GPO in $Script:Reporting['GPOPermissionsRead']['Data'].Issues) {
            # Create Per Domain Variables
            if (-not $Script:Reporting['GPOPermissionsRead']['Variables']['CouldNotReadPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissionsRead']['Variables']['CouldNotReadPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOPermissionsRead']['Variables']['ReadPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissionsRead']['Variables']['ReadPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOPermissionsRead']['Variables']['TotalPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissionsRead']['Variables']['TotalPerDomain'][$GPO.DomainName] = 0
            }
            if ($GPO.PermissionIssue) {
                $Script:Reporting['GPOPermissionsRead']['Variables']['CouldNotRead']++
                $Script:Reporting['GPOPermissionsRead']['Variables']['CouldNotReadPerDomain'][$GPO.DomainName]++
            } else {
                $Script:Reporting['GPOPermissionsRead']['Variables']['Read']++
                $Script:Reporting['GPOPermissionsRead']['Variables']['ReadPerDomain'][$GPO.DomainName]++
            }
            $Script:Reporting['GPOPermissionsRead']['Variables']['TotalPerDomain'][$GPO.DomainName]++
        }
        foreach ($GPO in $Script:Reporting['GPOPermissionsRead']['Data'].Permissions) {
            # Create Per Domain Variables
            if (-not $Script:Reporting['GPOPermissionsRead']['Variables']['WillFixPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissionsRead']['Variables']['WillFixPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOPermissionsRead']['Variables']['WillNotTouchPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissionsRead']['Variables']['WillNotTouchPerDomain'][$GPO.DomainName] = 0
            }
            # Checks
            if ($GPO.Permission -in 'GpoApply', 'GpoRead') {
                $Script:Reporting['GPOPermissionsRead']['Variables']['WillNotTouch']++
                $Script:Reporting['GPOPermissionsRead']['Variables']['WillNotTouchPerDomain'][$GPO.DomainName]++
            } else {
                $Script:Reporting['GPOPermissionsRead']['Variables']['WillFix']++
                $Script:Reporting['GPOPermissionsRead']['Variables']['WillFixPerDomain'][$GPO.DomainName]++
            }
        }
        if ($Script:Reporting['GPOPermissionsRead']['Variables']['WillFix'] -gt 0 -or $Script:Reporting['GPOPermissionsRead']['Variables']['CouldNotRead'] -gt 0) {
            $Script:Reporting['GPOPermissionsRead']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOPermissionsRead']['ActionRequired'] = $false
        }
        # Summary from 2 reports
        $Script:Reporting['GPOPermissionsRead']['Variables']['TotalToFix'] = $Script:Reporting['GPOPermissionsRead']['Variables']['WillFix'] + $Script:Reporting['GPOPermissionsRead']['Variables']['CouldNotRead']
    }
    Variables  = @{
        WillFix               = 0
        WillNotTouch          = 0
        WillFixPerDomain      = $null
        WillNotTouchPerDomain = $null
        CouldNotRead          = 0
        CouldNotReadPerDomain = $null
        Read                  = 0
        ReadPerDomain         = $null
        TotalToFix            = 0
        TotalPerDomain        = $null
    }
    Overview   = {

    }
    Summary    = {
        New-HTMLText -FontSize 10pt -TextBlock {
            "When GPO is created one of the permissions that are required for proper functioning of Group Policies is NT AUTHORITY\Authenticated Users. "
            "Some Administrators don't follow best practices and trying to remove GpoApply permission, remove also GpoRead permission from a GPO which can have consequences. "
        } -LineBreak
        New-HTMLText -Text "On June 14th, 2016 Microsoft released [HotFix](https://support.microsoft.com/en-gb/help/3159398/ms16-072-description-of-the-security-update-for-group-policy-june-14-2) that requires Authenticated Users to be present on all Group Policies to function properly: " -FontSize 10pt
        New-HTMLText -TextBlock {
            "MS16-072 changes the security context with which user group policies are retrieved. "
            "This by-design behavior change protects customers’ computers from a security vulnerability. "
            "Before MS16-072 is installed, user group policies were retrieved by using the user’s security context. "
            "After MS16-072 is installed, user group policies are retrieved by using the computer's security context."
        } -FontStyle italic -FontSize 10pt -FontWeight bold -LineBreak
        New-HTMLText -FontSize 10pt -Text @(
            "There are two parts to this assesment. Reading all Group Policies Permissions that account ",
            $($Env:USERNAME.ToUpper()),
            " has permissions to read and provide detailed assesment about permissions. ",
            "Second assesment checks for permissions that this account is not able to read at all, and therefore it has no visibility about permissions set on it. "
            "We just were able to detect the problem, but hopefully higher level account (Domain Admin) should be able to provide full assesment. "
        ) -FontWeight normal, bold, normal
        New-HTMLText -FontSize 10pt -Text "First assesment results: " -FontWeight bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies requiring Authenticated Users with GpoRead permission: ', $Script:Reporting['GPOPermissionsRead']['Variables']['WillFix'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies which don't require changes: ", $Script:Reporting['GPOPermissionsRead']['Variables']['WillNotTouch'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOPermissionsRead']['Variables']['WillFixPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOPermissionsRead']['Variables']['WillFixPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
        } -FontSize 10pt
        New-HTMLText -FontSize 10pt -Text "Secondary assesment results: " -FontWeight bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text "Group Policies couldn't read at all: ", $Script:Reporting['GPOPermissionsRead']['Variables']['CouldNotRead'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies with permissions allowing read: ", $Script:Reporting['GPOPermissionsRead']['Variables']['Read'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -Text 'With split per domain (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOPermissionsRead']['Variables']['CouldNotReadPerDomain'].Keys) {
                New-HTMLListItem -Text @(
                    "$Domain requires ",
                    $Script:Reporting['GPOPermissionsRead']['Variables']['CouldNotReadPerDomain'][$Domain],
                    " changes out of ",
                    $Script:Reporting['GPOPermissionsRead']['Variables']['TotalPerDomain'][$Domain],
                    "."
                ) -FontWeight normal, bold, normal
            }
        } -FontSize 10pt
        New-HTMLText -Text @(
            "That means we need to fix permissions on: "
            $($Script:Reporting['GPOPermissionsRead']['Variables']['TotalToFix'])
            " out of "
            $($Script:Reporting['GPOPermissionsRead']['Data'].Issues).Count
            " Group Policies. "
        ) -FontSize 10pt -FontWeight bold, bold, normal, bold, normal -Color Black, FreeSpeechRed, Black, Black -LineBreak -TextDecoration none, underline, underline, underline, none
    }
    Solution   = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPOPermissionsRead']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartBarOptions -Type barStacked
                    New-ChartLegend -Name 'Yes', 'No' -Color LightGreen, Salmon
                    New-ChartBar -Name 'Authenticated Users Available' -Value $Script:Reporting['GPOPermissionsRead']['Variables']['WillNotTouch'], $Script:Reporting['GPOPermissionsRead']['Variables']['WillFix']
                    New-ChartBar -Name 'Accessible Group Policies' -Value $Script:Reporting['GPOPermissionsRead']['Variables']['Read'], $Script:Reporting['GPOPermissionsRead']['Variables']['CouldNotRead']
                } -Title 'Group Policy Permissions' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policy Authenticated Users Analysis' {
            New-HTMLTable -DataTable $Script:Reporting['GPOPermissionsRead']['Data'].Permissions -Filtering {
                New-HTMLTableCondition -Name 'Permission' -Value '' -BackgroundColor Salmon -ComparisonType string -Row
            } -PagingOptions 7, 15, 30, 45, 60
        }
        New-HTMLSection -Name 'Group Policy Issues Assesment' {
            New-HTMLTable -DataTable $Script:Reporting['GPOPermissionsRead']['Data'].Issues -Filtering {
                New-HTMLTableCondition -Name 'PermissionIssue' -Value $true -BackgroundColor Salmon -ComparisonType string -Row
            } -PagingOptions 7, 15, 30, 45, 60 -DefaultSortColumn PermissionIssue -DefaultSortOrder Descending
        }
        if ($Script:Reporting['Settings']['HideSteps'] -eq $false) {
            New-HTMLSection -Name 'Steps to fix Group Policy Authenticated Users' {
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
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrGPOPermissionsReadBefore.html -Verbose -Type GPOPermissionsRead
                                }
                                New-HTMLText -TextBlock {
                                    "When executed it will take a while to generate all data and provide you with new report depending on size of environment. "
                                    "GPOs with problems will be those not having any value for Permission/PermissionType columns. "
                                    "Once confirmed that data is still showing issues and requires fixing please proceed with next step."
                                }
                                New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                                New-HTMLCodeBlock -Code {
                                    $AuthenticatedUsers = Get-GPOZaurrPermission -Type AuthenticatedUsers -ReturnSecurityWhenNoData
                                    $AuthenticatedUsers | Format-Table
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

                            New-HTMLWizardStep -Name 'Add Authenticated Users ability to read all GPO' {
                                New-HTMLText -Text @(
                                    "Following command will find any GPO which doesn't have Authenticated User as GpoRead or GpoApply and will add it as GpoRead. ",
                                    "This change doesn't change GpoApply permission, therefore it won't change to whom the GPO applies to. ",
                                    "It ensures that COMPUTERS can read GPO properly to be able to Apply it. ",
                                    "Make sure when running it for the first time to run it with ",
                                    "WhatIf",
                                    " parameter as shown below to prevent accidental adding of permissions."
                                ) -FontWeight normal, normal, normal, normal, bold, normal -Color Black, Black, Black, Black, Red, Black
                                New-HTMLCodeBlock -Code {
                                    Add-GPOZaurrPermission -Type AuthenticatedUsers -PermissionType GpoRead -All -WhatIf -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Add-GPOZaurrPermission -Type AuthenticatedUsers -PermissionType GpoRead -All -WhatIf -Verbose -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be changed matches expected data."
                                } -LineBreak
                                New-HTMLText -Text "Once happy with results please follow with command (this will start fixing process): " -LineBreak -FontWeight bold
                                New-HTMLCodeBlock -Code {
                                    Add-GPOZaurrPermission -Type AuthenticatedUsers -PermissionType GpoRead -All -Verbose -LimitProcessing 2
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Add-GPOZaurrPermission -Type AuthenticatedUsers -PermissionType GpoRead -All -Verbose -LimitProcessing 2 -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "This command when executed adds Authenticated Users (GpoRead permission) only on first X non-compliant Group Policies. "
                                    "Use LimitProcessing parameter to prevent mass change and increase the counter when no errors occur. "
                                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. "
                                    "In case of any issues please review and action accordingly."
                                }
                            }
                            New-HTMLWizardStep -Name 'Verification report' {
                                New-HTMLText -TextBlock {
                                    "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                                }
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrGPOPermissionsReadAfter.html -Verbose -Type GPOPermissionsRead
                                }
                                New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                            }
                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                    }
                }
            }
        }
        if ($Script:Reporting['GPOPermissionsRead']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOPermissionsRead']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                } -PagingOptions 10, 20, 30, 40, 50
            }
        }
    }
}