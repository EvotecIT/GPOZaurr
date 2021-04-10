$GPOZaurrBrokenLink = [ordered] @{
    Name           = 'Group Policy Broken Links'
    Enabled        = $true
    ActionRequired = $null
    Data           = $null
    Execute        = {
        Get-GPOZaurrBrokenLink -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing     = {
        $Script:Reporting['GPOBrokenLink']['Variables']['RequireDeletion'] = $Script:Reporting['GPOBrokenLink']['Data'].Count
        $Script:Reporting['GPOBrokenLink']['Variables']['WillFixPerDomain'] = @{}
        $Script:Reporting['GPOBrokenLink']['Variables']['Unique'] = @{}
        foreach ($Link In $Script:Reporting['GPOBrokenLink']['Data']) {
            $DomainName = ConvertFrom-DistinguishedName -ToDomainCN -DistinguishedName $Link.DistinguishedName
            # Create Per Domain Variables
            if (-not $Script:Reporting['GPOBrokenLink']['Variables']['WillFixPerDomain'][$DomainName]) {
                $Script:Reporting['GPOBrokenLink']['Variables']['WillFixPerDomain'][$DomainName] = 0
            }
            $Script:Reporting['GPOBrokenLink']['Variables']['WillFixPerDomain'][$DomainName]++
            # Lets do unique OU counting
            $Script:Reporting['GPOBrokenLink']['Variables']['Unique'][$Link.CanonicalName] = $Link
        }
        $Script:Reporting['GPOBrokenLink']['Variables']['UniqueObjects'] = $Script:Reporting['GPOBrokenLink']['Variables']['Unique'].Keys

        if ($Script:Reporting['GPOBrokenLink']['Data'].Count -gt 0) {
            $Script:Reporting['GPOBrokenLink']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOBrokenLink']['ActionRequired'] = $false
        }
    }
    Variables      = @{
        RequireDeletion  = 0
        WillFixPerDomain = $null
        UniqueObjects    = $null
        Unique           = $null
    }
    Overview       = {

    }
    Summary        = {
        New-HTMLText -FontSize 10pt -TextBlock {
            "When GPO is deleted correctly, it usually is removed from AD, SYSVOL, and any link to it is also discarded. "
            "Unfortunately, this is true only if the GPO is created and linked within the same domain. "
            "If GPO is linked in another domain, this leaves a broken link hanging on before it was linked. "
            "Additionally, the Remove-GPO cmdlet doesn't handle site link deletions, which causes dead links to be stuck on sites until those are manually deleted. "
            "This means that any GPOs deleted using PowerShell may leave a trail."
        }
        New-HTMLText -Text @(
            'As it stands currently there are ',
            $Script:Reporting['GPOBrokenLink']['Data'].Count,
            ' broken links that need to be deleted over '
            $Script:Reporting['GPOBrokenLink']['Variables']['UniqueObjects'].Count,
            ' unique objects. '
        ) -FontSize 10pt -FontWeight normal, bold, normal, bold, normal -LineBreak
        if ($Script:Reporting['GPOBrokenLink']['Data'].Count -ne 0) {
            New-HTMLText -Text 'Following domains require actions (permissions required):' -FontSize 10pt -FontWeight bold
            New-HTMLList -Type Unordered {
                foreach ($Domain in $Script:Reporting['GPOBrokenLink']['Variables']['WillFixPerDomain'].Keys) {
                    New-HTMLListItem -Text "$Domain requires ", $Script:Reporting['GPOBrokenLink']['Variables']['WillFixPerDomain'][$Domain], " changes." -FontWeight normal, bold, normal
                }
            } -FontSize 10pt
        }
    }
    Solution       = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPOBrokenLink']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartLegend -Names 'Bad' -Color Salmon
                    New-ChartBar -Name 'Broken Links' -Value $Script:Reporting['GPOBrokenLink']['Data'].Count
                } -Title 'Broken Links' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policy Broken Links' {
            New-HTMLTable -DataTable $Script:Reporting['GPOBrokenLink']['Data'] -Filtering {

            } -PagingOptions 10, 20, 30, 40, 50 -SearchBuilder
        }
        if ($Script:Reporting['Settings']['HideSteps'] -eq $false) {
            New-HTMLSection -Name 'Steps to remove Broken Links' {
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
                                New-HTMLText -Text "Depending when this report was run you may want to prepare new report before proceeding fixing GPO links. To generate new report please use:"
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrBrokenLinkBefore.html -Verbose -Type GPOBrokenLink
                                }
                                New-HTMLText -TextBlock {
                                    "When executed it will take a while to generate all data and provide you with new report depending on size of environment. "
                                    "Once confirmed that data is still showing issues and requires fixing please proceed with next step. "
                                }
                                New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                                New-HTMLCodeBlock -Code {
                                    $GPOOutput = Get-GPOZaurrBrokenLink -Verbose
                                    $GPOOutput | Format-Table * # do your actions as desired
                                }
                                New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
                            }
                            New-HTMLWizardStep -Name 'Remove Broken Links' {
                                New-HTMLText -Text "Following command when executed, runs internally command that lists all broken links. After finding them all it delets them according to given criteria. "
                                New-HTMLText -Text "Make sure when running it for the first time to run it with ", "WhatIf", " parameter as shown below to prevent accidental removal." -FontWeight normal, bold, normal -Color Black, Red, Black

                                New-HTMLCodeBlock -Code {
                                    Repair-GPOZaurrBrokenLink -WhatIf -Verbose
                                }
                                New-HTMLText -TextBlock {
                                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be changed matches expected data. Once happy with results please follow with command: "
                                }
                                New-HTMLCodeBlock -Code {
                                    Repair-GPOZaurrBrokenLink -Verbose -LimitProcessing 2
                                }
                                New-HTMLText -TextBlock {
                                    "This command when executed removes only first X number of links. Keep in mind that 5 broken links on a single Organizational Unit are treated as one. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur. "
                                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly. "
                                }
                            }
                            New-HTMLWizardStep -Name 'Verification report' {
                                New-HTMLText -TextBlock {
                                    "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                                }
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrBrokenLinkAfter.html -Verbose -Type GPOBrokenLink
                                }
                                New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                            }
                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center -EnableAllAnchors
                    }
                }
            }
        }
        if ($Script:Reporting['GPOBrokenLink']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOBrokenLink']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}