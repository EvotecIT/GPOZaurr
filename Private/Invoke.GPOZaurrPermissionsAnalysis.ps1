$GPOZaurrPermissionsAnalysis = [ordered] @{
    Name       = 'Group Policy Permissions Analysis'
    Enabled    = $true
    Action     = $null
    Data       = $null
    Execute    = {
        $Object = [ordered] @{
            Permissions = Get-GPOZaurrPermission -ReturnSecurityWhenNoData -IncludeGPOObject -ReturnSingleObject -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
        }
        $Object['PermissionsPerRow'] = $Object['Permissions'] | ForEach-Object { $_ }
        $Object['PermissionsAnalysis'] = Get-GPOZaurrPermissionAnalysis -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -Permissions $Object.Permissions
        $Object
    }
    Processing = {
        # Create Per Domain Variables
        $Script:Reporting['GPOPermissions']['Variables']['WillFixAdministrativePerDomain'] = @{}
        $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchAdministrativePerDomain'] = @{}

        $Script:Reporting['GPOPermissions']['Variables']['WillFixAuthenticatedUsersPerDomain'] = @{}
        $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchAuthenticatedUsersPerDomain'] = @{}

        $Script:Reporting['GPOPermissions']['Variables']['WillFixSystemPerDomain'] = @{}
        $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchSystemPerDomain'] = @{}

        $Script:Reporting['GPOPermissions']['Variables']['WillFixUnknownPerDomain'] = @{}
        $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchUnknownPerDomain'] = @{}

        $Script:Reporting['GPOPermissions']['Variables']['WillNotFixPerDomain'] = @{}
        $Script:Reporting['GPOPermissions']['Variables']['WillFixPerDomain'] = @{}

        foreach ($GPO in $Script:Reporting['GPOPermissions']['Data'].PermissionsAnalysis) {
            # Create Per Domain Variables
            if (-not $Script:Reporting['GPOPermissions']['Variables']['WillFixPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissions']['Variables']['WillFixPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOPermissions']['Variables']['WillNotFixPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissions']['Variables']['WillNotFixPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOPermissions']['Variables']['WillFixAdministrativePerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissions']['Variables']['WillFixAdministrativePerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchAdministrativePerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchAdministrativePerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOPermissions']['Variables']['WillFixAuthenticatedUsersPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissions']['Variables']['WillFixAuthenticatedUsersPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOPermissions']['Variables']['WillFixSystemPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissions']['Variables']['WillFixSystemPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchSystemPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchSystemPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOPermissions']['Variables']['WillFixUnknownPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissions']['Variables']['WillFixUnknownPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchUnknownPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchUnknownPerDomain'][$GPO.DomainName] = 0
            }

            # Checks
            if ($GPO.Administrative -eq $true) {
                $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchAdministrative']++
                $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchAdministrativePerDomain'][$GPO.DomainName]++
            } else {
                $Script:Reporting['GPOPermissions']['Variables']['WillFixAdministrative']++
                $Script:Reporting['GPOPermissions']['Variables']['WillFixAdministrativePerDomain'][$GPO.DomainName]++
            }

            if ($GPO.AuthenticatedUsers -eq $true) {
                $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchAuthenticatedUsers']++
                $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchAuthenticatedUsersPerDomain'][$GPO.DomainName]++
            } else {
                $Script:Reporting['GPOPermissions']['Variables']['WillFixAuthenticatedUsers']++
                $Script:Reporting['GPOPermissions']['Variables']['WillFixAuthenticatedUsersPerDomain'][$GPO.DomainName]++
            }

            if ($GPO.System -eq $true) {
                $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchSystem']++
                $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchSystemPerDomain'][$GPO.DomainName]++
            } else {
                $Script:Reporting['GPOPermissions']['Variables']['WillFixSystem']++
                $Script:Reporting['GPOPermissions']['Variables']['WillFixSystemPerDomain'][$GPO.DomainName]++
            }

            if ($GPO.Unknown -eq $false) {
                $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchUnknown']++
                $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchUnknownPerDomain'][$GPO.DomainName]++
            } else {
                $Script:Reporting['GPOPermissions']['Variables']['WillFixUnknown']++
                $Script:Reporting['GPOPermissions']['Variables']['WillFixUnknownPerDomain'][$GPO.DomainName]++
            }

            if ($GPO.Status -eq $false) {
                $Script:Reporting['GPOPermissions']['Variables']['WillFix']++
                $Script:Reporting['GPOPermissions']['Variables']['WillFixPerDomain'][$GPO.DomainName]++
            } else {
                $Script:Reporting['GPOPermissions']['Variables']['WillNotFix']++
                $Script:Reporting['GPOPermissions']['Variables']['WillNotFixPerDomain'][$GPO.DomainName]++
            }
        }
        if ($Script:Reporting['GPOPermissions']['Variables']['WillFix'] -gt 0) {
            $Script:Reporting['GPOPermissions']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOPermissions']['ActionRequired'] = $false
        }
    }
    Variables  = @{
        WillFix                                 = 0
        WillNotFix                              = 0
        WillFixAdministrative                   = 0
        WillNotTouchAdministrative              = 0
        WillFixUnknown                          = 0
        WillNotTouchUnknown                     = 0
        WillNotTouchSystem                      = 0
        WillFixSystem                           = 0
        WillNotTouchAuthenticatedUsers          = 0
        WillFixAuthenticatedUsers               = 0
        WillNotTouchAuthenticatedUsersPerDomain = $null
        WillFixAuthenticatedUsersPerDomain      = $null
        WillNotTouchSystemPerDomain             = $null
        WillFixSystemPerDomain                  = $null
        WillFixAdministrativePerDomain          = $null
        WillNotTouchAdministrativePerDomain     = $null
        WillNotFixPerDomain                     = $null
        WillFixPerDomain                        = $null
        WillFixUnknownPerDomain                 = $null
        WillNotTouchUnknownPerDomain            = $null
    }
    Summary    = {
        New-HTMLText -FontSize 10pt -Text "When GPO is created it gets a handful of standard permissions. Those are:"
        New-HTMLList {
            New-HTMLListItem -Text "NT AUTHORITY\Authenticated Users with GpoApply permissions"
            New-HTMLListItem -Text "Domain Admins and Enterprise Admins with Edit/Delete/Modify permissions"
            New-HTMLListItem -Text "SYSTEM account with Edit/Delete/Modify permissions"
        } -FontSize 10pt
        New-HTMLText -FontSize 10pt -Text "But then IT people change those permissions to their own needs. While most changes make sense and are required to be able to target proper groups of people, some changes are not required or even bad. "

        New-HTMLText -Text "First problem relates to NT AUTHORITY\Authenticated Users" -FontSize 10pt -FontWeight bold -TextDecoration underline -Alignment center

        New-HTMLText -FontSize 10pt -TextBlock {
            "When GPO is created one of the permissions that are required for proper functioning of Group Policies is NT AUTHORITY\Authenticated Users. "
            "Some Administrators don't follow best practices and trying to remove GpoApply permission, remove also GpoRead permission from a GPO which can have consequences. "
            "On June 14th, 2016 Microsoft released [HotFix](https://support.microsoft.com/en-gb/help/3159398/ms16-072-description-of-the-security-update-for-group-policy-june-14-2) that requires Authenticated Users to be present on all Group Policies to function properly. "
            "MS16-072 changes the security context with which user group policies are retrieved. "
            "This by-design behavior change protects customers’ computers from a security vulnerability. "
        }
        New-HTMLList {
            New-HTMLListItem -Text "Before MS16-072 is installed, user group policies were retrieved by using the user’s security context. "
            New-HTMLListItem -Text "After MS16-072 is installed, user group policies are retrieved by using the computer's security context."
        } -FontSize 10pt

        New-HTMLText -FontSize 10pt -Text "Assesment results " -FontWeight bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies requiring Authenticated Users with GpoRead permission: ', $Script:Reporting['GPOPermissions']['Variables']['WillFixAuthenticatedUsers'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies which don't require changes: ", $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchAuthenticatedUsers'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOPermissions']['Variables']['WillFixAuthenticatedUsersPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOPermissions']['Variables']['WillFixAuthenticatedUsersPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
        } -FontSize 10pt
        New-HTMLText -Text "Second problem relates to Domain Admins and Enterprise Admins" -FontSize 10pt -FontWeight bold -TextDecoration underline -Alignment center
        New-HTMLText -FontSize 10pt -TextBlock {
            "When GPO is created by default it gets Domain Admins and Enterprise Admins with Edit/Delete/Modify Security permissions. "
            "For some reason, some Administrators remove those permissions or modify them when they shouldn't touch those at all. "
            "Since having Edit/Delete/Modify Security permissions doesn't affect GPOApply permissions there's no reason to remove Domain Admins or Enterprise Admins from permissions, or limit their rights. "
            "Domain Admins and Enterprise Admins have to have either GPOEditModify permissions or at the very least GPOCustom. "
            "When GPOCustom is set it usually means there's a mix of Allow and Deny permission in place (for example deny GPOApply). "
            "In such case we're assuming you know what you're doing. However it's always possible to review those permissions, as those are marked in the table for review. "
        } -LineBreak

        New-HTMLText -FontSize 10pt -Text "Assesment results " -FontWeight bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies requiring Administrative permission fix: ', $Script:Reporting['GPOPermissions']['Variables']['WillFixAdministrative'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies which don't require changes: ", $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchAdministrative'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOPermissions']['Variables']['WillFixAdministrativePerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOPermissions']['Variables']['WillFixAdministrativePerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
        } -FontSize 10pt

        New-HTMLText -Text "Third problem relates to SYSTEM account" -FontSize 10pt -FontWeight bold -TextDecoration underline -Alignment center
        New-HTMLText -FontSize 10pt -TextBlock {
            "When GPO is created by default it gets SYSTEM account with Edit/Delete/Modify Security permissions. "
            "For some reason, some Administrators remove those permissions or modify them when they shouldn't touch those at all. "
            "Since having Edit/Delete/Modify Security permissions doesn't affect GPOApply permissions there's no reason to remove SYSTEM from permissions, or limit their rights. "
        } -LineBreak

        New-HTMLText -FontSize 10pt -Text "Assesment results " -FontWeight bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies requiring SYSTEM permission fix: ', $Script:Reporting['GPOPermissions']['Variables']['WillFixSystem'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies which don't require changes: ", $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchSystem'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOPermissions']['Variables']['WillFixSystemPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOPermissions']['Variables']['WillFixSystemPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
        } -FontSize 10pt

        New-HTMLText -Text "Fourth problem relates to UNKNOWN SID" -FontSize 10pt -FontWeight bold -TextDecoration underline -Alignment center
        New-HTMLText -FontSize 10pt -TextBlock {
            "Sometimes groups or users are deleted in Active Directory and unfortunetly their permissions are not cleaned automatically. "
            "Those are left in-place and stay there forever until removed. "
        } -LineBreak

        New-HTMLText -FontSize 10pt -Text "Assesment results " -FontWeight bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies requiring Unknown permission removal: ', $Script:Reporting['GPOPermissions']['Variables']['WillFixUnknown'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies which don't require changes: ", $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchUnknown'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOPermissions']['Variables']['WillFixUnknownPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOPermissions']['Variables']['WillFixUnknownPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
        } -FontSize 10pt
    }
    Solution   = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPOPermissions']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartBarOptions -Type barStacked
                    New-ChartLegend -Name 'Yes', 'No' -Color SpringGreen, Salmon
                    New-ChartBar -Name 'Overall Permissions' -Value $Script:Reporting['GPOPermissions']['Variables']['WillNotFix'], $Script:Reporting['GPOPermissions']['Variables']['WillFix']
                    New-ChartBar -Name 'Administrative Permissions' -Value $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchAdministrative'], $Script:Reporting['GPOPermissions']['Variables']['WillFixAdministrative']
                    New-ChartBar -Name 'Authenticated Users Permissions' -Value $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchAdministrative'], $Script:Reporting['GPOPermissions']['Variables']['WillFixAuthenticatedUsers']
                    New-ChartBar -Name 'System Permissions' -Value $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchSystem'], $Script:Reporting['GPOPermissions']['Variables']['WillFixSystem']
                    New-ChartBar -Name 'Unknown Permissions' -Value $Script:Reporting['GPOPermissions']['Variables']['WillNotTouchUnknown'], $Script:Reporting['GPOPermissions']['Variables']['WillFixUnknown']
                } -Title 'Group Policy Permissions' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policy Permissions Analysis' {
            New-HTMLContainer {
                New-HTMLText -Text 'Explanation to table columns:' -FontSize 10pt
                New-HTMLList {
                    New-HTMLListItem -FontWeight bold, normal -Text "Status", " - means GPO has at least one problem with permissions. "
                    New-HTMLListItem -FontWeight bold, normal -Text "Administrative", " - means GPO has problem with either Domain Admins or Enterprise Admins not having proper permissions. "
                    New-HTMLListItem -FontWeight bold, normal -Text "AuthenticatedUsers", " - means GPO has Authenticated Users missing either as GPOApply or GPORead. "
                    New-HTMLListItem -FontWeight bold, normal -Text "System", " - means GPO has SYSTEM permission missing or lacking proper permissions. "
                    New-HTMLListItem -FontWeight bold, normal -Text "DomainAdmins", " - means GPO has Domain Admins missing or having wrong permissions. "
                    New-HTMLListItem -FontWeight bold, normal -Text "EnterpriseAdmins", " - means GPO has Enterprise Admins missing or having wrong permissions. "
                } -FontSize 10pt
                New-HTMLTable -DataTable $Script:Reporting['GPOPermissions']['Data'].PermissionsAnalysis -Filtering {
                    New-HTMLTableCondition -Name 'Status' -Value 'True' -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'Administrative' -Value 'True' -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'AuthenticatedUsers' -Value 'True' -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'System' -Value 'True' -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'Unknown' -Value 'False' -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'DomainAdmins' -Value 'True' -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'EnterpriseAdmins' -Value 'True' -BackgroundColor SpringGreen -ComparisonType string

                    # Mark as warning
                    New-HTMLTableCondition -Name 'DomainAdminsPermission' -Value 'GpoCustom' -BackgroundColor Moccasin -ComparisonType string
                    New-HTMLTableCondition -Name 'EnterpriseAdminsPermission' -Value 'GpoCustom' -BackgroundColor Moccasin -ComparisonType string
                    # Reverse
                    New-HTMLTableCondition -Name 'Status' -Value 'True' -BackgroundColor Salmon -ComparisonType string -Operator ne
                    New-HTMLTableCondition -Name 'Administrative' -Value 'True' -BackgroundColor Salmon -ComparisonType string -Operator ne
                    New-HTMLTableCondition -Name 'AuthenticatedUsers' -Value 'True' -BackgroundColor Salmon -ComparisonType string -Operator ne
                    New-HTMLTableCondition -Name 'System' -Value 'True' -BackgroundColor Salmon -ComparisonType string -Operator ne
                    New-HTMLTableCondition -Name 'Unknown' -Value 'False' -BackgroundColor Salmon -ComparisonType string -Operator ne
                    New-HTMLTableCondition -Name 'DomainAdmins' -Value 'True' -BackgroundColor Salmon -ComparisonType string -Operator ne
                    New-HTMLTableCondition -Name 'EnterpriseAdmins' -Value 'True' -BackgroundColor Salmon -ComparisonType string -Operator ne

                    New-TableEvent -TableID 'GPOPermissionsAll' -SourceColumnName 'GUID' -TargetColumnID 1 # TargetColumnID 1 eq GUID on the other table
                } -PagingOptions 7, 15, 30, 45, 60
            }
        }
        New-HTMLSection -Name 'All Permissions' {
            New-HTMLTable -DataTable $Script:Reporting['GPOPermissions']['Data'].PermissionsPerRow -Filtering {
                New-HTMLTableHeader -Names 'PrincipalNetBiosName', 'PrincipalDistinguishedName', 'PrincipalDomainName', 'PrincipalName', 'PrincipalSid', 'PrincipalSidType' -Title 'Account Information'
                New-HTMLTableCondition -Name 'Permission' -Value 'GpoEditDeleteModifySecurity' -BackgroundColor HotPink -ComparisonType string -Operator eq
                New-HTMLTableCondition -Name 'Permission' -Value 'GpoCustom' -BackgroundColor Moccasin -ComparisonType string
                New-HTMLTableCondition -Name 'Permission' -Value 'GpoApply' -BackgroundColor Orange -ComparisonType string
                New-HTMLTableCondition -Name 'Permission' -Value 'GpoRead' -BackgroundColor MediumSpringGreen -ComparisonType string -Operator eq
                New-HTMLTableCondition -Name 'PrincipalSidType' -Value 'Unknown' -BackgroundColor Salmon -ComparisonType string -Operator eq
            } -PagingOptions 7, 15, 30, 45, 60 -DataTableID 'GPOPermissionsAll'
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
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrGPOPermissionsAdministrativeBefore.html -Verbose -Type GPOPermissions
                                }
                                New-HTMLText -TextBlock {
                                    "When executed it will take a while to generate all data and provide you with new report depending on size of environment. "
                                    "GPOs with problems will be those not having any value for Permission/PermissionType columns. "
                                    "Once confirmed that data is still showing issues and requires fixing please proceed with next step."
                                }
                                New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                                New-HTMLCodeBlock -Code {
                                    # This gets all permissions
                                    $AllPermissions = Get-GPOZaurrPermission
                                    $AllPermissions | Format-Table

                                    # this analyses permissions
                                    $PermissionsAnalysis = Get-GPOZaurrPermissionAnalysis
                                    $PermissionsAnalysis | Format-Table
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
                            New-HTMLWizardStep -Name 'Add Authenticated Users permissions' {
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
                            New-HTMLWizardStep -Name 'Add Administrative Groups permissions' {
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
                            New-HTMLWizardStep -Name 'Add SYSTEM permissions' {
                                New-HTMLText -Text @(
                                    "Following command will find any GPO which doesn't have SYSTEM account added with GpoEditDeleteModifySecurity and will add it as GpoEditDeleteModifySecurity. ",
                                    "This change doesn't change GpoApply permission, therefore it won't change to whom the GPO applies to. ",
                                    "It ensures that SYSTEM can manage GPO. ",
                                    "Make sure when running it for the first time to run it with ",
                                    "WhatIf",
                                    " parameter as shown below to prevent accidental adding of permissions."
                                ) -FontWeight normal, normal, normal, normal, bold, normal -Color Black, Black, Black, Black, Red, Black
                                New-HTMLCodeBlock -Code {
                                    Add-GPOZaurrPermission -Type WellKnownAdministrative -PermissionType GpoEditDeleteModifySecurity -All -WhatIf -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Add-GPOZaurrPermission -Type WellKnownAdministrative -PermissionType GpoEditDeleteModifySecurity -All -WhatIf -Verbose -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be changed matches expected data."
                                } -LineBreak
                                New-HTMLText -Text "Once happy with results please follow with command (this will start fixing process): " -LineBreak -FontWeight bold
                                New-HTMLCodeBlock -Code {
                                    Add-GPOZaurrPermission -Type WellKnownAdministrative -PermissionType GpoEditDeleteModifySecurity -All -Verbose -LimitProcessing 2
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Add-GPOZaurrPermission -Type WellKnownAdministrative -PermissionType GpoEditDeleteModifySecurity -All -Verbose -LimitProcessing 2 -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "This command when executed adds SYSTEM account (GpoEditDeleteModifySecurity permission) only on first X non-compliant Group Policies. "
                                    "Use LimitProcessing parameter to prevent mass change and increase the counter when no errors occur. "
                                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. "
                                    "In case of any issues please review and action accordingly. "
                                }
                            }
                            New-HTMLWizardStep -Name 'Remove UNKNOWN permissions' {
                                New-HTMLText -Text @(
                                    "Following command will find any GPO which has an unknown SID and will remove it. ",
                                    "This change doesn't change any other permissions. ",
                                    "It ensures that GPOs have no unknown permissions present. ",
                                    "Make sure when running it for the first time to run it with ",
                                    "WhatIf",
                                    " parameter as shown below to prevent accidental adding of permissions."
                                ) -FontWeight normal, normal, normal, normal, bold, normal -Color Black, Black, Black, Black, Red, Black
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurrPermission -Verbose -Type Unknown -WhatIf
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurrPermission -Verbose -Type Unknown -WhatIf -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be changed matches expected data."
                                } -LineBreak
                                New-HTMLText -Text "Once happy with results please follow with command (this will start fixing process): " -LineBreak -FontWeight bold
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurrPermission -Verbose -Type Unknown -LimitProcessing 2
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurrPermission -Verbose -Type Unknown -LimitProcessing 2 -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "This command when executed removes only first X unknwon permissions from Group Policies. "
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
                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center -EnableAllAnchors
                    }
                }
            }
        }
        if ($Script:Reporting['GPOPermissions']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOPermissions']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}