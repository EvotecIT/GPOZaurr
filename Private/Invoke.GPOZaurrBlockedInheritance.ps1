$GPOZaurrBlockedInheritance = [ordered] @{
    Name           = 'Group Policy Blocked Inhertiance'
    Enabled        = $true
    ActionRequired = $null
    Data           = $null
    Execute        = {
        if ($Script:Reporting['GPOBlockedInheritance']['Exclusions']) {
            Get-GPOZaurrInheritance -IncludeBlockedObjects -IncludeExcludedObjects -OnlyBlockedInheritance -IncludeGroupPoliciesForBlockedObjects -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $Excludeomains -Exclusions $Script:Reporting['GPOBlockedInheritance']['Exclusions']
        } else {
            Get-GPOZaurrInheritance -IncludeBlockedObjects -IncludeExcludedObjects -OnlyBlockedInheritance -IncludeGroupPoliciesForBlockedObjects -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $Excludeomains
        }
    }
    Processing     = {
        foreach ($GPO in $Script:Reporting['GPOBlockedInheritance']['Data']) {
            if (-not $Script:Reporting['GPOBlockedInheritance']['Variables']['DeletionHarmlessPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOBlockedInheritance']['Variables']['DeletionHarmlessPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOBlockedInheritance']['Variables']['RequiresInvesigationPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOBlockedInheritance']['Variables']['RequiresInvesigationPerDomain'][$GPO.DomainName] = 0
            }
            if ($GPO.Exclude -eq $true) {
                $Script:Reporting['GPOBlockedInheritance']['Variables']['Exclude']++
                $Script:Reporting['GPOBlockedInheritance']['Variables']['UsersAffectedExclude'] = $Script:Reporting['GPOBlockedInheritance']['Variables']['UsersAffectedExclude'] + $GPO.UsersCount
                $Script:Reporting['GPOBlockedInheritance']['Variables']['ComputersAffectedExclude'] = $Script:Reporting['GPOBlockedInheritance']['Variables']['ComputersAffectedExclude'] + $GPO.ComputersCount
            } else {
                $Script:Reporting['GPOBlockedInheritance']['Variables']['UsersAffected'] = $Script:Reporting['GPOBlockedInheritance']['Variables']['UsersAffected'] + $GPO.UsersCount
                $Script:Reporting['GPOBlockedInheritance']['Variables']['ComputersAffected'] = $Script:Reporting['GPOBlockedInheritance']['Variables']['ComputersAffected'] + $GPO.ComputersCount
            }
            $Script:Reporting['GPOBlockedInheritance']['Variables']['UsersAffectedIncludingExclude'] = $Script:Reporting['GPOBlockedInheritance']['Variables']['UsersAffectedIncludingExclude'] + $GPO.UsersCount
            $Script:Reporting['GPOBlockedInheritance']['Variables']['ComputersAffectedIncludingExclude'] = $Script:Reporting['GPOBlockedInheritance']['Variables']['ComputersAffectedIncludingExclude'] + $GPO.ComputersCount

            if ($GPO.Exclude -eq $false -and ($GPO.UsersCount -gt 0 -or $GPO.ComputersCount -gt 0)) {
                $Script:Reporting['GPOBlockedInheritance']['Variables']['RequiresInvesigation']++
                $Script:Reporting['GPOBlockedInheritance']['Variables']['RequiresInvesigationPerDomain'][$GPO.DomainName]++
            }
            if ($GPO.Exclude -eq $false -and ($GPO.UsersCount -eq 0 -and $GPO.ComputersCount -eq 0)) {
                $Script:Reporting['GPOBlockedInheritance']['Variables']['DeletionHarmless']++
                $Script:Reporting['GPOBlockedInheritance']['Variables']['DeletionHarmlessPerDomain'][$GPO.DomainName]++
            }
            # add gpo from blocked inheritance to create additional table
            #foreach ($GpoBlocked in $Script:Reporting['GPOBlockedInheritance']['Data'].GroupPolicies) {
            #$Script:Reporting['GPOBlockedInheritance']['Variables']['GroupPolicies'].Add($GpoBlocked)
            #}
        }
        if ($Script:Reporting['GPOBlockedInheritance']['Variables']['RequiresInvesigation'] -gt 0 -or $Script:Reporting['GPOBlockedInheritance']['Variables']['DeletionHarmless'] -gt 0) {
            $Script:Reporting['GPOBlockedInheritance']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOBlockedInheritance']['ActionRequired'] = $false
        }
    }
    Resources      = @(
        'http://www.firewall.cx/microsoft-knowledgebase/windows-2012/1056-windows-2012-group-policy-enforcement.html'
    )
    Variables      = @{
        Total                             = 0
        Exclude                           = 0
        RequiresInvesigation              = 0
        RequiresInvesigationPerDomain     = [ordered] @{}
        DeletionHarmless                  = 0
        DeletionHarmlessPerDomain         = [ordered] @{}
        UsersAffected                     = 0
        UsersAffectedExclude              = 0
        UsersAffectedIncludingExclude     = 0
        ComputersAffected                 = 0
        ComputersAffectedIncludingExclude = 0
        ComputersAffectedExclude          = 0
        GroupPolicies                     = [System.Collections.Generic.List[PSCustomObject]]::new()
    }
    Overview       = {

    }
    Summary        = {
        New-HTMLText -FontSize 10pt -TextBlock {
            "By default, group policy settings that are linked to parent objects are inherited to the child objects in the active directory hierarchy. "
            "By default, Default Domain Policy is linked to the domain and is inherited to all the child objects of the domain hierarchy. "
            "So does any other policies linked to the top level OU's. "
        }
        New-HTMLText -Text "Blocked Inheritance" -FontSize 10pt -FontWeight bold
        New-HTMLText -FontSize 10pt -Text @(
            "As GPOs can be inherited by default, they can also be blocked, if required using the Block Inheritance. "
            "If the Block Inheritance setting is enabled, the inheritance of group policy setting is blocked. "
            "This setting is mostly used when the OU contains users or computers that require different settings than what is applied to the domain level. "
            "Unfortunetly blocking inheritance can have serious security consequences. "
        )
        New-HTMLText -Text @(
            'As it stands currently there are ',
            $Script:Reporting['GPOBlockedInheritance']['Data'].Count,
            ' organisational units with '
            'GPO Inheritance Block'
            ' out of which '
            $Script:Reporting['GPOBlockedInheritance']['Variables']['Exclude'],
            ' are marked as Excluded '
            '(approved by IT). '
        ) -FontSize 10pt -FontWeight normal, bold, normal, bold, normal, bold, normal, bold -LineBreak
        if ($Script:Reporting['GPOBlockedInheritance']['Data'].Count -ne 0) {
            New-HTMLText -Text 'Users & Computers affected by inheritance blocks:' -FontSize 10pt -FontWeight bold
            New-HTMLList -Type Unordered {
                New-HTMLListItem -Text $Script:Reporting['GPOBlockedInheritance']['Variables']['UsersAffected'], ' users affected due to inheritance blocks' -FontWeight bold, normal
                New-HTMLListItem -Text $Script:Reporting['GPOBlockedInheritance']['Variables']['UsersAffectedExclude'], ' users affected, but approved/excluded, due to inheritance blocks' -FontWeight bold, normal
                New-HTMLListItem -Text $Script:Reporting['GPOBlockedInheritance']['Variables']['ComputersAffected'], ' computers affected due to inheritance blocks' -FontWeight bold, normal
                New-HTMLListItem -Text $Script:Reporting['GPOBlockedInheritance']['Variables']['ComputersAffectedExclude'], ' computers affected, but approved/excluded, due to inheritance blocks' -FontWeight bold, normal
            } -FontSize 10pt

            New-HTMLText -Text 'Following domains require:' -FontSize 10pt -FontWeight bold
            New-HTMLList -Type Unordered {
                foreach ($Domain in $Script:Reporting['GPOBlockedInheritance']['Variables']['RequiresInvesigationPerDomain'].Keys) {
                    New-HTMLListItem -Text "$Domain proposes ", $Script:Reporting['GPOBlockedInheritance']['Variables']['RequiresInvesigationPerDomain'][$Domain], " investigation (computers or users inside)." -FontWeight normal, bold, normal
                    New-HTMLListItem -Text "$Domain proposes ", $Script:Reporting['GPOBlockedInheritance']['Variables']['DeletionHarmlessPerDomain'][$Domain], " removal (mostly harmless due to no computers or users inside)." -FontWeight normal, bold, normal
                }
            } -FontSize 10pt
        }
        New-HTMLText -FontSize 10pt -Text "Please review output in table and follow the steps below table to get Active Directory Group Policies in healthy state."
    }
    Solution       = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPOBlockedInheritance']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartLegend -Names 'Affected', 'Affected, but excluded' -Color Salmon, PaleGreen
                    New-ChartBarOptions -Type barStacked
                    New-ChartBar -Name 'Users' -Value $Script:Reporting['GPOBlockedInheritance']['Variables']['UsersAffected'], $Script:Reporting['GPOBlockedInheritance']['Variables']['UsersAffectedExclude']
                    New-ChartBar -Name 'Computers' -Value $Script:Reporting['GPOBlockedInheritance']['Variables']['ComputersAffected'], $Script:Reporting['GPOBlockedInheritance']['Variables']['ComputersAffectedExclude']
                } -Title 'Users & Computers affected due to blocked inheritance' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Organizational Units with Group Policy Blocked Inheritance' {
            New-HTMLTable -DataTable $Script:Reporting['GPOBlockedInheritance']['Data'] -Filtering {
                New-TableEvent -TableID 'TableWithGroupPoliciesBlockedInheritance' -SourceColumnID 8 -TargetColumnID 9
                New-HTMLTableCondition -Name 'Exclude' -Value $true -BackgroundColor DeepSkyBlue -ComparisonType string -Row
                New-TableConditionGroup {
                    New-TableCondition -Name 'BlockedInheritance' -Value $true
                    New-TableCondition -Name 'Exclude' -Value $false
                } -BackgroundColor Salmon -FailBackgroundColor SpringGreen -HighlightHeaders 'BlockedInheritance', 'Exclude'
                New-TableConditionGroup {
                    New-TableCondition -Name 'UsersCount' -Value 0
                    New-TableCondition -Name 'ComputersCount' -Value 0
                } -BackgroundColor Salmon -FailBackgroundColor Amber -HighlightHeaders 'UsersCount', 'ComputersCount'
                New-TableColumnOption -Hidden $true -ColumnIndex 8
            } -PagingOptions 5, 10, 20, 30, 40, 50 -SearchBuilder -ExcludeProperty GroupPolicies
        }
        New-HTMLSection -Name 'Group Policies affecting objects in Organizational Units with Blocked Inheritance' {
            New-HTMLTable -DataTable $Script:Reporting['GPOBlockedInheritance']['Data'].GroupPolicies -Filtering {
                New-TableCondition -Name 'Enabled' -Value $true -BackgroundColor SpringGreen -FailBackgroundColor Salmon
                New-TableCondition -Name 'Enforced' -Value $true -BackgroundColor Amber -FailBackgroundColor AirForceBlue
                New-TableCondition -Name 'LinkedDirectly' -Value $true -BackgroundColor Amber -FailBackgroundColor AirForceBlue
            } -PagingOptions 5, 10, 20, 30, 40, 50 -SearchBuilder -DataTableID 'TableWithGroupPoliciesBlockedInheritance'
        }
        if ($Script:Reporting['Settings']['HideSteps'] -eq $false) {
            New-HTMLSection -Name 'Steps to fix - Organizational Units with Group Policy Blocked Inheritance' {
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
                            if ($Script:Reporting['GPOBlockedInheritance']['Exclusions']) {
                                New-HTMLWizardStep -Name 'Required exclusions' {
                                    New-HTMLText -Text @(
                                        "While preparing this report following exclusions were defined. "
                                        "Please make sure that when you execute your steps to include those exclusions to prevent any issues. "
                                    )
                                    [string] $Code = New-GPOZaurrExclusions -ExclusionsArray $Script:Reporting['GPOBlockedInheritance']['Exclusions']

                                    New-HTMLCodeBlock -Code $Code -Style powershell
                                }
                            }
                            New-HTMLWizardStep -Name 'Prepare report' {
                                New-HTMLText -Text @(
                                    "Depending when this report was run you may want to prepare new report before proceeding removing Group Policy Inheritance Blocks. "
                                    "Please keep in mind that if exclusions for some Organizational OU's were defined you need to pass them to cmdlet below to not remove approved GPO Inheritance Blocks. "
                                    "To generate new report please use:"
                                )
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrBlockedGPOInheritanceBefore.html -Verbose -Type GPOBlockedInheritance
                                }
                                New-HTMLText -TextBlock {
                                    "When executed it will take a while to generate all data and provide you with new report depending on size of environment. "
                                    "Once confirmed that data is still showing issues and requires fixing please proceed with next step. "
                                }
                                New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                                New-HTMLCodeBlock -Code {
                                    $GPOOutput = Get-GPOZaurrInheritance -IncludeBlockedObjects -IncludeExcludedObjects -OnlyBlockedInheritance
                                    $GPOOutput | Format-Table # do your actions as desired
                                }
                                New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
                            }
                            New-HTMLWizardStep -Name 'Remove OU GPO Inheritance Blocks' {
                                New-HTMLText -Text @(
                                    "Removing inheritance blocks is quite trivial and can be done from GPO GUI. However knowing when to remove is the important part. "
                                    "Please consult other Domain Admins before removing any inheritance blocks, and either approve exclusion or remove blocking inheritance. "
                                )
                            }
                            New-HTMLWizardStep -Name 'Verification report' {
                                New-HTMLText -TextBlock {
                                    "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                                }
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrBlockedGPOInheritanceAfter.html -Verbose -Type GPOBlockedInheritance
                                }
                                New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                            }
                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center -EnableAllAnchors
                    }
                }
            }
        }
        if ($Script:Reporting['GPOBlockedInheritance']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOBlockedInheritance']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                } -SearchBuilder
            }
        }
    }
}