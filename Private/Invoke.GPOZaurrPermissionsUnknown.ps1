$GPOZaurrPermissionsUnknown = [ordered] @{
    Name       = 'Group Policy Unknown Permissions'
    Enabled    = $false
    Action     = $null
    Data       = $null
    Execute    = {
        Get-GPOZaurrPermission -Type Unknown -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing = {
        # Create Per Domain Variables
        $Script:Reporting['GPOPermissionsUnknown']['Variables']['WillFixPerDomain'] = @{}
        foreach ($GPO in $Script:Reporting['GPOPermissionsUnknown']['Data']) {
            # Create Per Domain Variables
            if (-not $Script:Reporting['GPOPermissionsUnknown']['Variables']['WillFixPerDomain'][$GPO[0].DomainName]) {
                $Script:Reporting['GPOPermissionsUnknown']['Variables']['WillFixPerDomain'][$GPO[0].DomainName] = 0
            }
            # Checks
            $Script:Reporting['GPOPermissionsUnknown']['Variables']['WillFix']++
            $Script:Reporting['GPOPermissionsUnknown']['Variables']['WillFixPerDomain'][$GPO[0].DomainName]++
        }
        if ($Script:Reporting['GPOPermissionsUnknown']['Variables']['WillFix'] -gt 0) {
            $Script:Reporting['GPOPermissionsUnknown']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOPermissionsUnknown']['ActionRequired'] = $false
        }
    }
    Variables  = @{
        WillFix          = 0
        WillFixPerDomain = $null
    }
    Overview   = {

    }
    Summary    = {
        New-HTMLText -FontSize 10pt -TextBlock {
            "Group Policies contain multiple permissions for different level of access. "
            "Be it adminstrative permissions, read permissions or apply permissions. "
            "Over time some users or groups get deleted for different reasons and such permission in Group Policies leave a trace in form of Unknown SID. "
            "Unknown SIDs can also be remains of Active Directory Trusts, that have been deleted or are otherwise unavailable. "
            "Following assesment detects all unknown permissions and provides them for review & deletion. "
        } -LineBreak
        New-HTMLText -FontSize 10pt -Text "Assesment results: " -FontWeight bold
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies requiring removal of unknown SIDs: ', $Script:Reporting['GPOPermissionsUnknown']['Variables']['WillFix'] -FontWeight normal, bold
        } -FontSize 10pt
        New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
        New-HTMLList -Type Unordered {
            foreach ($Domain in $Script:Reporting['GPOPermissionsUnknown']['Variables']['WillFixPerDomain'].Keys) {
                New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOPermissionsUnknown']['Variables']['WillFixPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
            }
        } -FontSize 10pt
        New-HTMLText -Text @(
            "That means we need to remove "
            $($Script:Reporting['GPOPermissionsUnknown']['Variables'].WillFix)
            " unknown permissions from Group Policies. "
        ) -FontSize 10pt -FontWeight normal, bold, normal -Color Black, FreeSpeechRed, Black -LineBreak -TextDecoration none, underline, none
    }
    Solution   = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPOPermissionsUnknown']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartBarOptions -Type barStacked
                    New-ChartLegend -Name 'Yes' -Color Salmon
                    New-ChartBar -Name 'Unknown Permissions Present' -Value $Script:Reporting['GPOPermissionsUnknown']['Variables']['WillFix']
                } -Title 'Group Policy Permissions' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policy Unknown Permissions Analysis' {
            New-HTMLTable -DataTable $Script:Reporting['GPOPermissionsUnknown']['Data'] -Filtering {
                New-HTMLTableCondition -Name 'Permission' -Value '' -BackgroundColor Salmon -ComparisonType string -Row
            } -PagingOptions 7, 15, 30, 45, 60
        }
        if ($Script:Reporting['Settings']['HideSteps'] -eq $false) {
            New-HTMLSection -Name 'Steps to fix Group Policy Unknown Permissions' {
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
                                New-HTMLText -Text "Depending when this report was run you may want to prepare new report before proceeding with removing unknown permissions. To generate new report please use:"
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrGPOPermissionsUnknownBefore.html -Verbose -Type GPOPermissionsUnknown
                                }
                                New-HTMLText -TextBlock {
                                    "When executed it will take a while to generate all data and provide you with new report depending on size of environment. "
                                    "The table only shows GPO and their unknown permissions. "
                                    "It doesn't show permissions that are not subject of this investigation. "
                                    "Once confirmed that data is still showing issues and requires fixing please proceed with next step."
                                }
                                New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                                New-HTMLCodeBlock -Code {
                                    $UnknownPermissions = Get-GPOZaurrPermission -Type Unknown
                                    $UnknownPermissions | Format-Table
                                }
                                New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
                            }
                            New-HTMLWizardStep -Name 'Make a backup (optional)' {
                                New-HTMLText -TextBlock {
                                    "The process of fixing GPO Permissions does NOT touch GPO content. It simply removes permissionss on AD and SYSVOL at the same time for given GPO. "
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
                            New-HTMLWizardStep -Name 'Remove Unknown Permissions' {
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
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrGPOPermissionsUnknownAfter.html -Verbose -Type GPOPermissionsUnknown
                                }
                                New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                            }
                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center -EnableAllAnchors
                    }
                }
            }
        }
        if ($Script:Reporting['GPOPermissionsUnknown']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOPermissionsUnknown']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                } -PagingOptions 10, 20, 30, 40, 50
            }
        }
    }
}