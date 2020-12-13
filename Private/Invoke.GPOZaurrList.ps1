$GPOZaurrList = [ordered] @{
    Name       = 'Group Policy Summary'
    Enabled    = $true
    Action     = $null
    Data       = $null
    Execute    = {
        if ($Script:Reporting['GPOList']['ExclusionsCode']) {
            Get-GPOZaurr -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExcludeGroupPolicies $Script:Reporting['GPOList']['ExclusionsCode']

        } else {
            Get-GPOZaurr -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
        }
    }
    Processing = {
        # Create Per Domain Variables
        $Script:Reporting['GPOList']['Variables']['GPONotValidPerDomain'] = @{}
        $Script:Reporting['GPOList']['Variables']['GPOValidPerDomain'] = @{}
        $Script:Reporting['GPOList']['Variables']['GPONotOptimizedPerDomain'] = @{}
        $Script:Reporting['GPOList']['Variables']['GPOOptimizedPerDomain'] = @{}
        $Script:Reporting['GPOList']['Variables']['GPOProblemPerDomain'] = @{}
        $Script:Reporting['GPOList']['Variables']['GPONoProblemPerDomain'] = @{}
        $Script:Reporting['GPOList']['Variables']['GPOApplyPermissionYesPerDomain'] = @{}
        $Script:Reporting['GPOList']['Variables']['GPOApplypermissionNoPerDomain'] = @{}
        foreach ($GPO in $Script:Reporting['GPOList']['Data']) {
            # Create Per Domain Variables
            if (-not $Script:Reporting['GPOList']['Variables']['GPONotValidPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOList']['Variables']['GPONotValidPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOList']['Variables']['GPOValidPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOList']['Variables']['GPOValidPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOList']['Variables']['GPONotOptimizedPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOList']['Variables']['GPONotOptimizedPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOList']['Variables']['GPOOptimizedPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOList']['Variables']['GPOOptimizedPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOList']['Variables']['GPOProblemPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOList']['Variables']['GPOProblemPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOList']['Variables']['GPONoProblemPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOList']['Variables']['GPONoProblemPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOList']['Variables']['GPOApplyPermissionYesPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOList']['Variables']['GPOApplyPermissionYesPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOList']['Variables']['GPOApplypermissionNoPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOList']['Variables']['GPOApplypermissionNoPerDomain'][$GPO.DomainName] = 0
            }

            if ($GPO.Days -le $Script:Reporting['GPOList']['Variables']['GPOOlderThan']) {
                # Skip GPOS that are younger than 7 days
                $Script:Reporting['GPOList']['Variables']['GPOSkip']++
            }
            if (($GPO.Enabled -eq $false -or $GPO.Empty -eq $true -or $GPO.Linked -eq $false -or $GPO.ApplyPermission -eq $false) -and $GPO.Days -le $Script:Reporting['GPOList']['Variables']['GPOOlderThan']) {
                # Skip GPOS that are younger than 7 days
                $Script:Reporting['GPOList']['Variables']['GPONotValidButSkip']++
            }
            if (($GPO.Enabled -eq $false -or $GPO.Empty -eq $true -or $GPO.Linked -eq $false -or $GPO.ApplyPermission -eq $false) -and $GPO.Days) {
                $Script:Reporting['GPOList']['Variables']['GPONotValid']++
                $Script:Reporting['GPOList']['Variables']['GPONotValidPerDomain'][$GPO.DomainName]++
            } else {
                $Script:Reporting['GPOList']['Variables']['GPOValid']++
                $Script:Reporting['GPOList']['Variables']['GPOValidPerDomain'][$GPO.DomainName]++
            }
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
                $Script:Reporting['GPOList']['Variables']['GPOLinked']++
                $Script:Reporting['GPOList']['Variables']['GPONotEmpty']++
            }
            if ($GPO.Enabled -eq $true) {
                $Script:Reporting['GPOList']['Variables']['GPOEnabled']++
            } else {
                $Script:Reporting['GPOList']['Variables']['GPODisabled']++
            }
            if ($GPO.ApplyPermission -eq $true) {
                $Script:Reporting['GPOList']['Variables']['ApplyPermissionYes']++
            } else {
                $Script:Reporting['GPOList']['Variables']['ApplyPermissionNo']++
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
            if ($GPO.Problem -eq $true) {
                $Script:Reporting['GPOList']['Variables']['GPOProblem']++
                $Script:Reporting['GPOList']['Variables']['GPOProblemPerDomain'][$GPO.DomainName]++
            } else {
                $Script:Reporting['GPOList']['Variables']['GPONoProblem']++
                $Script:Reporting['GPOList']['Variables']['GPONoProblemPerDomain'][$GPO.DomainName]++
            }
            if ($GPO.Optimized -eq $true) {
                $Script:Reporting['GPOList']['Variables']['GPOOptimized']++
                $Script:Reporting['GPOList']['Variables']['GPOOptimizedPerDomain'][$GPO.DomainName]++
            } else {
                $Script:Reporting['GPOList']['Variables']['GPONotOptimized']++
                $Script:Reporting['GPOList']['Variables']['GPONotOptimizedPerDomain'][$GPO.DomainName]++
            }
        }
        $Script:Reporting['GPOList']['Variables']['GPOTotal'] = $Script:Reporting['GPOList']['Data'].Count
        if ($Script:Reporting['GPOList']['Variables']['GPONotValid'] -gt 0 -and $Script:Reporting['GPOList']['Variables']['GPONotValidButSkip'] -ne $Script:Reporting['GPOList']['Variables']['GPONotValid']) {
            $Script:Reporting['GPOList']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOList']['ActionRequired'] = $false
        }
    }
    Variables  = @{
        GPOOlderThan                   = 7
        GPONotValidPerDomain           = $null
        GPOValidPerDomain              = $null
        GPONotOptimizedPerDomain       = $null
        GPOOptimizedPerDomain          = $null
        GPOProblemPerDomain            = $null
        GPONoProblemPerDomain          = $null
        GPOApplyPermissionYesPerDomain = $null
        GPOApplyPermissionNoPerDomain  = $null
        GPOWithProblems                = 0
        ComputerOptimizedYes           = 0
        ComputerOptimizedNo            = 0
        ComputerProblemYes             = 0
        ComputerProblemNo              = 0
        UserOptimizedYes               = 0
        UserOptimizedNo                = 0
        UserProblemYes                 = 0
        UserProblemNo                  = 0
        GPOOptimized                   = 0
        GPONotOptimized                = 0
        GPOProblem                     = 0
        GPONoProblem                   = 0
        GPONotLinked                   = 0
        GPOLinked                      = 0
        GPOEmpty                       = 0
        GPONotEmpty                    = 0
        GPOEmptyAndUnlinked            = 0
        GPOEmptyOrUnlinked             = 0
        GPOLinkedButEmpty              = 0
        GPOEnabled                     = 0
        GPODisabled                    = 0
        GPOSkip                        = 0
        GPOValid                       = 0
        GPONotValid                    = 0
        GPONotValidButSkip             = 0
        GPOLinkedButLinkDisabled       = 0
        GPOTotal                       = 0
        ApplyPermissionYes             = 0
        ApplyPermissionNo              = 0
    }
    Overview   = {

    }
    Summary    = {
        New-HTMLText -TextBlock {
            "Over time Administrators add more and more group policies, as business requirements change. "
            "Due to neglection or thinking it may serve it's purpose later on a lot of Group Policies often have no value at all. "
            "Either the Group Policy is not linked to anything and just stays unlinked forever, or GPO is linked, but the link (links) are disabled or GPO is totally disabled. "
            "Then there are Group Policies that are targetting certain group or person and that group is removed leaving Group Policy doing nothing. "
            "Additionally sometimes new GPO is created without any settings or the settings are removed over time, but GPO stays in place. "
        } -FontSize 10pt
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies total: ', $Script:Reporting['GPOList']['Variables']['GPOTotal'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies valid: ", $Script:Reporting['GPOList']['Variables']['GPOValid'] -FontWeight normal, bold
            New-HTMLListItem -Text "Group Policies ", "NOT", " valid: ", $Script:Reporting['GPOList']['Variables']['GPONotValid'] -FontWeight normal, bold, normal, bold {
                New-HTMLList -Type Unordered {
                    New-HTMLListItem -Text 'Group Policies that are unlinked (are not doing anything currently): ', $Script:Reporting['GPOList']['Variables']['GPONotLinked'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies that are empty (have no settings): ", $Script:Reporting['GPOList']['Variables']['GPOEmpty'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies that are linked, but empty: ", $Script:Reporting['GPOList']['Variables']['GPOLinkedButEmpty'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies that are linked, but link disabled: ", $Script:Reporting['GPOList']['Variables']['GPOLinkedButLinkDisabled'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies that are disabled (both user/computer sections): ", $Script:Reporting['GPOList']['Variables']['GPODisabled'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies that have no Apply Permission: ", $Script:Reporting['GPOList']['Variables']['ApplyPermissionNo'] -FontWeight normal, bold
                }
            } -Color Black, Red, Black, Red, Black
            New-HTMLListItem -Text @(
                "Group Policies ", "NOT", " valid, to skip: ", $Script:Reporting['GPOList']['Variables']['GPONotValidButSkip'], " (not older than $($Script:Reporting['GPOList']['Variables']['GPOOlderThan']) days)"
            ) -FontWeight 'normal', 'bold', 'normal', 'bold', 'normal' -Color 'Black', 'Red', 'Black', 'Red', 'Black'
            New-HTMLListItem -Text "Group Policies younger than $($Script:Reporting['GPOList']['Variables']['GPOOlderThan']) days: ", $Script:Reporting['GPOList']['Variables']['GPOSkip'], " (not older than $($Script:Reporting['GPOList']['Variables']['GPOOlderThan']) days)" -FontWeight normal, bold
        } -FontSize 10pt

        New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOList']['Variables']['GPONotValidPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOList']['Variables']['GPONotValidPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
        } -FontSize 10pt
        New-HTMLText -Text "Keep in mind that each GPO can match multiple conditions such as being empty and unlinked and disabled at the same time. We're only deleting GPO once." -FontSize 10pt

        New-HTMLText -Text @(
            'All ',
            'empty',
            ' or ',
            'unlinked',
            ' or ',
            'disabled',
            ' Group Policies can be automatically deleted. Please review output in the table and follow steps below table to cleanup Group Policies. ',
            'GPOs that have content, but are disabled require manual intervention. ',
            "If performance is an issue you should consider disabling user or computer sections of GPO when those are not used. "
        ) -FontSize 10pt -FontWeight normal, bold, normal, bold, normal, bold, normal, normal, normal, normal

        New-HTMLText -LineBreak

        New-HTMLText -Text "Additionally, we're reviewing Group Policies that have their section disabled, but contain data." -FontSize 10pt
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies with problems: ', $Script:Reporting['GPOList']['Variables']['GPOWithProblems'] -FontWeight normal, bold {
                New-HTMLList -Type Unordered {
                    New-HTMLListItem -Text 'Group Policies that have content (computer), but are disabled: ', $Script:Reporting['GPOList']['Variables']['ComputerProblemYes'] -FontWeight normal, bold
                    New-HTMLListItem -Text "Group Policies that have content (user), but are disabled: ", $Script:Reporting['GPOList']['Variables']['UserProblemYes'] -FontWeight normal, bold
                }
            }
        } -FontSize 10pt
        New-HTMLText -Text @(
            "Such policies require manual review from whoever owns them. "
            "It could be a mistake tha section was disabled while containing data or that content is no longer needed in which case it should be deleted. "
            "This can't be auto-handled and is INFORMATIONAL only. "
        ) -FontSize 10pt

        New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOList']['Variables']['GPOProblemPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOList']['Variables']['GPOProblemPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
        } -FontSize 10pt

        New-HTMLText -LineBreak

        New-HTMLText -Text "Moreover, for best performance it's recommended that if there are no settings of certain kind (Computer or User settings) it's best to disable whole section. " -FontSize 10pt
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
        New-HTMLText -Text @(
            "This means "
            $Script:Reporting['GPOList']['Variables']['GPONotOptimized']
            " could be optimized for performance reasons. "
        ) -FontSize 10pt -FontWeight normal, bold, normal

        New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOList']['Variables']['GPONotOptimizedPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOList']['Variables']['GPONotOptimizedPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
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
                    New-ChartBar -Name 'Not Empty' -Value $Script:Reporting['GPOList']['Variables']['GPONotEmpty'], $Script:Reporting['GPOList']['Variables']['GPOEmpty']
                    New-ChartBar -Name 'Enabled' -Value $Script:Reporting['GPOList']['Variables']['GPOEnabled'], $Script:Reporting['GPOList']['Variables']['GPODisabled']
                    New-ChartBar -Name 'Apply Permission' -Value $Script:Reporting['GPOList']['Variables']['ApplyPermissionYes'], $Script:Reporting['GPOList']['Variables']['ApplyPermissionNo']
                    New-ChartBar -Name 'Valid' -Value $Script:Reporting['GPOList']['Variables']['GPOValid'], $Script:Reporting['GPOList']['Variables']['GPONotValid']
                    New-ChartBar -Name 'Optimized (for speed)' -Value $Script:Reporting['GPOList']['Variables']['GPOOptimized'], $Script:Reporting['GPOList']['Variables']['GPONotOptimized']
                    New-ChartBar -Name 'No problem' -Value $Script:Reporting['GPOList']['Variables']['GPONoProblem'], $Script:Reporting['GPOList']['Variables']['GPOProblem']
                    New-ChartBar -Name 'No problem (computers)' -Value $Script:Reporting['GPOList']['Variables']['ComputerProblemNo'], $Script:Reporting['GPOList']['Variables']['ComputerProblemYes']
                    New-ChartBar -Name 'No problem (users)' -Value $Script:Reporting['GPOList']['Variables']['UserProblemNo'], $Script:Reporting['GPOList']['Variables']['UserProblemYes']
                    New-ChartBar -Name 'Optimized Computers' -Value $Script:Reporting['GPOList']['Variables']['ComputerOptimizedYes'], $Script:Reporting['GPOList']['Variables']['ComputerOptimizedNo']
                    New-ChartBar -Name 'Optimized Users' -Value $Script:Reporting['GPOList']['Variables']['UserOptimizedYes'], $Script:Reporting['GPOList']['Variables']['UserOptimizedNo']
                } -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policies List' {
            New-HTMLContainer {
                New-HTMLText -Text 'Explanation to table columns:' -FontSize 10pt
                New-HTMLList {
                    New-HTMLListItem -FontWeight bold, normal -Text "Empty", " - means GPO has currently no content. It could be there was content, but it was removed, or that it never had content. "
                    New-HTMLListItem -FontWeight bold, normal -Text "Linked", " - means GPO is linked or unlinked. We need at least one link that is enabled to mark it as linked. If GPO is linked, but all links are disabled, it's not linked. "
                    New-HTMLListItem -FontWeight bold, normal -Text "Enabled", " - means GPO has at least one section enabled. If enabled is set to false that means both sections are disabled, and therefore GPO is not active. "
                    New-HTMLListItem -FontWeight bold, normal -Text "Optimized", " - means GPO section that is not in use is disabled. If section (user or computer) is enabled and there is no content, it's not optimized. "
                    New-HTMLListItem -FontWeight bold, normal -Text "Problem", " - means GPO has one or more section (user or computer) that is disabled, yet there is content in it. "
                    New-HTMLListItem -FontWeight bold, normal -Text "ApplyPermission", " - means GPO has no Apply Permission. This means there's no user/computer/group it's applicable to. "
                } -FontSize 10pt
                New-HTMLTable -DataTable $Script:Reporting['GPOList']['Data'] -Filtering {
                    New-HTMLTableCondition -Name 'Exclude' -Value $true -BackgroundColor DeepSkyBlue -ComparisonType string -Row

                    New-HTMLTableCondition -Name 'Empty' -Value $true -BackgroundColor Salmon -ComparisonType string
                    New-HTMLTableCondition -Name 'Linked' -Value $false -BackgroundColor Salmon -ComparisonType string
                    New-HTMLTableCondition -Name 'Enabled' -Value $false -BackgroundColor Salmon -ComparisonType string
                    New-HTMLTableCondition -Name 'Optimized' -Value $false -BackgroundColor Salmon -ComparisonType string
                    New-HTMLTableCondition -Name 'Problem' -Value $true -BackgroundColor Salmon -ComparisonType string
                    New-HTMLTableCondition -Name 'ApplyPermission' -Value $false -BackgroundColor Salmon -ComparisonType string
                    New-HTMLTableCondition -Name 'ComputerProblem' -Value $true -BackgroundColor Salmon -ComparisonType string
                    New-HTMLTableCondition -Name 'UserProblem' -Value $true -BackgroundColor Salmon -ComparisonType string
                    New-HTMLTableCondition -Name 'ComputerOptimized' -Value $false -BackgroundColor Salmon -ComparisonType string
                    New-HTMLTableCondition -Name 'UserOptimized' -Value $false -BackgroundColor Salmon -TextTransform capitalize -ComparisonType string
                    # reverse
                    New-HTMLTableCondition -Name 'Empty' -Value $false -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'Linked' -Value $true -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'Enabled' -Value $true -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'Optimized' -Value $true -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'Problem' -Value $false -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'ApplyPermission' -Value $true -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'ComputerProblem' -Value $false -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'UserProblem' -Value $false -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'ComputerOptimized' -Value $true -BackgroundColor SpringGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'UserOptimized' -Value $true -BackgroundColor SpringGreen -TextTransform capitalize -ComparisonType string
                } -PagingOptions 10, 20, 30, 40, 50
            }
        }
        if ($Script:Reporting['Settings']['HideSteps'] -eq $false) {
            New-HTMLSection -Name 'Steps to fix - Empty & Unlinked & Disabled Group Policies' {
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
                            New-HTMLWizardStep -Name 'Make a backup' {
                                New-HTMLText -TextBlock {
                                    "The process of deleting Group Policies is final. Once GPO is removed - it's gone. "
                                    "To make sure you can recover deleted GPO please make sure to back them up. "
                                }
                                New-HTMLCodeBlock -Code {
                                    $GPOSummary = Backup-GPOZaurr -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -Type All
                                    $GPOSummary | Format-Table # only if you want to display output of backup
                                }
                                New-HTMLText -TextBlock {
                                    "Above command when executed will make a backup to Desktop, create GPO folder and within it it will put all those GPOs. "
                                    "Keep in mind that Remove-GPOZaurr command also has a backup feature built-in. "
                                    "It's possible to skip this backup and use the backup provided as part of Remove-GPOZaurr command. "
                                }
                            }
                            New-HTMLWizardStep -Name 'Excluding Group Policies' {
                                New-HTMLText -Text @(
                                    "Remove-GPOZaurr",
                                    " cmdlet that you will use in next steps is pretty advanced in what it can do. It can remove one or multiple types of problems at the same time. "
                                    "That means you can pick just EMPTY, just UNLINKED or just DISABLED but also a mix of them if you want. "
                                    "It also provides a way to exclude some GPOs from being removed even though they match condition. "
                                    "You would do so using following approach "
                                ) -FontSize 10pt -FontWeight bold, normal
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type Empty, Unlinked, Disabled -BackupPath "$Env:UserProfile\Desktop\GPO" -LimitProcessing 2 -Verbose -IncludeDomains 'YourDomainYouHavePermissionsFor' {
                                        Skip-GroupPolicy -Name 'TEST | Drive Mapping'
                                        Skip-GroupPolicy -Name 'Default Domain Policy'
                                        Skip-GroupPolicy -Name 'Default Domain Controllers Policy' -DomaiName 'JustOneDomain'
                                    } -WhatIf
                                }
                                New-HTMLText -Text @(
                                    "Code above when executed will scan YourDomainYouHavePermissionsFor, find all empty, unlinked, disabled group policies, backup any GPO just before it's to be deleted to `$Env:UserProfile\Desktop\GPO. "
                                    "If it's not able to make a backup it will terminate. Additionally it will skip all 3 group policies that have been shown above. "
                                    "You can one or multiple group policies to be skipped. "
                                    "Now go ahead and find what's there"
                                )
                            }
                            New-HTMLWizardStep -Name 'Remove GPOs that are EMPTY' {
                                New-HTMLText -Text @(
                                    "Following command when executed removes every ",
                                    "EMPTY"
                                    " Group Policy. Make sure when running it for the first time to run it with ",
                                    "WhatIf",
                                    " parameter as shown below to prevent accidental removal.",
                                    "Make sure to use BackupPath which will make sure that for each GPO that is about to be deleted a backup is made to folder on a desktop."
                                    "You can skip parameters related to backup if you did backup all GPOs prior to running remove command. "
                                ) -FontWeight normal, bold, normal, bold, normal, bold, normal, normal -Color Black, Red, Black, Red, Black
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type Empty -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -WhatIf
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type Empty -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -WhatIf -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be deleted matches expected data. "
                                } -LineBreak
                                New-HTMLText -Text "Once happy with results please follow with command (this will start fixing process): " -LineBreak -FontWeight bold
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type Empty -BackupPath "$Env:UserProfile\Desktop\GPO" -LimitProcessing 2 -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type Empty -BackupPath "$Env:UserProfile\Desktop\GPO" -LimitProcessing 2 -Verbose -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "This command when executed deletes only first X empty GPOs. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur."
                                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
                                    "Please make sure to check if backup is made as well before going all in."
                                }
                                New-HTMLText -Text "If there's nothing else to be deleted, we can skip to next step step"
                            }
                            New-HTMLWizardStep -Name 'Remove GPOs that are UNLINKED' {
                                New-HTMLText -Text @(
                                    "Following command when executed removes every ",
                                    "NOT LINKED"
                                    " Group Policy. Make sure when running it for the first time to run it with ",
                                    "WhatIf",
                                    " parameter as shown below to prevent accidental removal.",
                                    "Make sure to use BackupPath which will make sure that for each GPO that is about to be deleted a backup is made to folder on a desktop."
                                    "You can skip parameters related to backup if you did backup all GPOs prior to running remove command. "
                                ) -FontWeight normal, bold, normal, bold, normal, bold, normal, normal -Color Black, Red, Black, Red, Black
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type Unlinked -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -WhatIf
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type Unlinked -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -WhatIf -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be deleted matches expected data. "
                                } -LineBreak
                                New-HTMLText -Text "Once happy with results please follow with command (this will start fixing process): " -LineBreak -FontWeight bold
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type Unlinked -BackupPath "$Env:UserProfile\Desktop\GPO" -LimitProcessing 2 -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type Unlinked -BackupPath "$Env:UserProfile\Desktop\GPO" -LimitProcessing 2 -Verbose -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "This command when executed deletes only first X unlinked GPOs. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur."
                                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
                                    "Please make sure to check if backup is made as well before going all in."
                                }
                                New-HTMLText -Text "If there's nothing else to be deleted, we can skip to next step step"
                            }
                            New-HTMLWizardStep -Name 'Remove GPOs that are DISABLED' {
                                New-HTMLText -Text @(
                                    "Following command when executed removes every ",
                                    "DISABLED"
                                    " Group Policy. Make sure when running it for the first time to run it with ",
                                    "WhatIf",
                                    " parameter as shown below to prevent accidental removal.",
                                    "Make sure to use BackupPath which will make sure that for each GPO that is about to be deleted a backup is made to folder on a desktop."
                                    "You can skip parameters related to backup if you did backup all GPOs prior to running remove command. "
                                ) -FontWeight normal, bold, normal, bold, normal, bold, normal, normal -Color Black, Red, Black, Red, Black
                                New-HTMLText -TextBlock {
                                    ""
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type Disabled -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -WhatIf
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type Disabled -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -WhatIf -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be deleted matches expected data. "
                                } -LineBreak
                                New-HTMLText -Text "Once happy with results please follow with command (this will start fixing process): " -LineBreak -FontWeight bold
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type Disabled -BackupPath "$Env:UserProfile\Desktop\GPO" -LimitProcessing 2 -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type Disabled -BackupPath "$Env:UserProfile\Desktop\GPO" -LimitProcessing 2 -Verbose -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "This command when executed deletes only first X disabled GPOs. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur. "
                                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly. "
                                    "Please make sure to check if backup is made as well before going all in."
                                }
                                New-HTMLText -Text "If there's nothing else to be deleted, we can skip to next step step."
                            }
                            New-HTMLWizardStep -Name 'Remove GPOs that do not APPLY' {
                                New-HTMLText -Text @(
                                    "Following command when executed removes every ",
                                    "NoApplyPermission"
                                    " Group Policy. Make sure when running it for the first time to run it with ",
                                    "WhatIf",
                                    " parameter as shown below to prevent accidental removal.",
                                    "Make sure to use BackupPath which will make sure that for each GPO that is about to be deleted a backup is made to folder on a desktop."
                                    "You can skip parameters related to backup if you did backup all GPOs prior to running remove command. "
                                ) -FontWeight normal, bold, normal, bold, normal, bold, normal, normal -Color Black, Red, Black, Red, Black
                                New-HTMLText -TextBlock {
                                    ""
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type NoApplyPermission -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -WhatIf
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type NoApplyPermission -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -WhatIf -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be deleted matches expected data. "
                                } -LineBreak
                                New-HTMLText -Text "Once happy with results please follow with command (this will start fixing process): " -LineBreak -FontWeight bold
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type NoApplyPermission -BackupPath "$Env:UserProfile\Desktop\GPO" -LimitProcessing 2 -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Remove-GPOZaurr -RequireDays 7 -Type NoApplyPermission -BackupPath "$Env:UserProfile\Desktop\GPO" -LimitProcessing 2 -Verbose -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "This command when executed deletes only first X NoApplyPermission GPOs. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur. "
                                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly. "
                                    "Please make sure to check if backup is made as well before going all in."
                                }
                                New-HTMLText -Text "If there's nothing else to be deleted, we can skip to next step step."
                            }
                            New-HTMLWizardStep -Name 'Optimize GPOs (optional)' {
                                New-HTMLText -Text @(
                                    "Following command when executed disables user or computer section when there's no content for given type. ",
                                    "This makes sure that when GPO is processed for application it's empty section is ignored. Make sure when running it for the first time to run it with ",
                                    "WhatIf",
                                    " parameter as shown below to prevent accidental disabling of sections."
                                ) -FontWeight normal, normal, bold, normal -Color Black, Black, Red, Black
                                New-HTMLCodeBlock -Code {
                                    Optimize-GPOZaurr -All -WhatIf -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Optimize-GPOZaurr -All -WhatIf -Verbose -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be optimized matches expected data. "
                                } -LineBreak
                                New-HTMLText -Text "Once happy with results please follow with command (this will start fixing process): " -LineBreak -FontWeight bold
                                New-HTMLCodeBlock -Code {
                                    Optimize-GPOZaurr -All -LimitProcessing 2 -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "Alternatively for multi-domain scenario, if you have limited Domain Admin credentials to a single domain please use following command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Optimize-GPOZaurr -All -LimitProcessing 2 -Verbose -IncludeDomains 'YourDomainYouHavePermissionsFor'
                                }
                                New-HTMLText -TextBlock {
                                    "This command when executed optimizes only first X not optimized GPOs. Use LimitProcessing parameter to prevent mass changes and increase the counter when no errors occur. "
                                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly. "
                                    "Please make sure to check if backup is made as well before going all in."
                                }
                                New-HTMLText -Text "If there's nothing else to be optimized, we can skip to next step step."
                            }
                            New-HTMLWizardStep -Name 'Verification report' {
                                New-HTMLText -TextBlock {
                                    "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                                }
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrEmptyUnlinkedAfter.html -Verbose -Type GPOList
                                }
                                New-HTMLText -Text "If there are no more problems to solve, GPOs to optimize in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                            }
                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center -EnableAllAnchors
                    }
                }
            }
            if ($Script:Reporting['GPOList']['Exclusions']) {
                New-HTMLSection -Invisible {
                    New-HTMLSection -Name 'Group Policies Exclusions' {
                        New-HTMLTable -DataTable $Script:Reporting['GPOList']['Exclusions'] -Filtering {

                        }
                    }
                    New-HTMLSection -Name 'Group Policies Exclusions Code' {
                        New-HTMLContainer {
                            New-HTMLText -Text 'Please make sure to use following exclusions when executing removal' -FontSize 10pt
                            New-HTMLCodeBlock -Code $Script:Reporting['GPOList']['ExclusionsCode']
                        }
                    }
                }
            }
        }
        if ($Script:Reporting['GPOList']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOList']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}