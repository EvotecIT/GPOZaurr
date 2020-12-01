$GPOZaurrDuplicates = [ordered] @{
    Name       = 'Duplicate (CNF) Group Policies'
    Enabled    = $true
    Action     = $null
    Data       = $null
    Execute    = {
        Get-GPOZaurrDuplicateObject -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing = {
        $Script:Reporting['GPODuplicates']['Variables']['RequireDeletion'] = $Script:Reporting['GPODuplicates']['Data'].Count
        if ($Script:Reporting['GPODuplicates']['Data'].Count -gt 0) {
            $Script:Reporting['GPODuplicates']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPODuplicates']['ActionRequired'] = $false
        }
    }
    Variables  = @{
        RequireDeletion = 0
    }
    Overview   = {

    }
    Resources  = @(
        'https://social.technet.microsoft.com/wiki/contents/articles/15435.active-directory-duplicate-object-name-resolution.aspx'
        'https://kickthatcomputer.wordpress.com/2014/11/22/seek-and-destroy-duplicate-ad-objects-with-cnf-in-the-name/'
    )
    Summary    = {
        New-HTMLText -FontSize 10pt -TextBlock {
            "CNF objects, Conflict objects or Duplicate Objects are created in Active Directory when there is simultaneous creation of an AD object under the same container "
            "on two separate Domain Controllers near about the same time or before the replication occurs. "
            "This results in a conflict and the same is exhibited by a CNF (Duplicate) object. "
            "While it doesn't nessecary has a huge impact on Active Directory it's important to keep Active Directory in proper, healthy state. "
        }
        New-HTMLText -Text 'As it stands currently there are ', $Script:Reporting['GPODuplicates']['Data'].Count, ' CNF (Duplicate) Group Policy objects to be deleted.' -FontSize 10pt -FontWeight normal, bold, normal
    }
    Solution   = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPODuplicates']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartLegend -Names 'Bad' -Color Salmon
                    New-ChartBar -Name 'Duplicate (CNF) object' -Value $Script:Reporting['GPODuplicates']['Data'].Count
                } -Title 'Duplicate (CNF) Objects' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policy CNF (Duplicate) Objects' {
            New-HTMLTable -DataTable $Script:Reporting['GPODuplicates']['Data'] -Filtering {

            } -PagingOptions 10, 20, 30, 40, 50
        }
        if ($Script:Reporting['GPODuplicates']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPODuplicates']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
        New-HTMLSection -Name 'Steps to fix - Remove duplicate (CNF) objects' {
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
                            New-HTMLText -Text "Depending when this report was run you may want to prepare new report before proceeding fixing duplicate GPO objects. To generate new report please use:"
                            New-HTMLCodeBlock -Code {
                                Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrDuplicateObjectsBefore.html -Verbose -Type GPODuplicates
                            }
                            New-HTMLText -Text {
                                "When executed it will take a while to generate all data and provide you with new report depending on size of environment. "
                                "Once confirmed that data is still showing issues and requires fixing please proceed with next step. "
                            }
                            New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                            New-HTMLCodeBlock -Code {
                                $GPOOutput = Get-GPOZaurrDuplicateObject
                                $GPOOutput | Format-Table # do your actions as desired
                            }
                            New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
                        }
                        New-HTMLWizardStep -Name 'Remove CNF objects' {
                            New-HTMLText -Text "Following command when executed, runs internally command that lists all duplicate objects."
                            New-HTMLText -Text "Make sure when running it for the first time to run it with ", "WhatIf", " parameter as shown below to prevent accidental removal." -FontWeight normal, bold, normal -Color Black, Red, Black

                            New-HTMLCodeBlock -Code {
                                Remove-GPOZaurrDuplicateObject -WhatIf -Verbose
                            }
                            New-HTMLText -TextBlock {
                                "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be changed matches expected data. Once happy with results please follow with command: "
                            }
                            New-HTMLCodeBlock -Code {
                                Remove-GPOZaurrDuplicateObject -Verbose -LimitProcessing 2
                            }
                            New-HTMLText -TextBlock {
                                "This command when executed removes only first X duplicate objects. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur. "
                                "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly. "
                            }
                        }
                        New-HTMLWizardStep -Name 'Verification report' {
                            New-HTMLText -TextBlock {
                                "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                            }
                            New-HTMLCodeBlock -Code {
                                Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrDuplicateObjectsAfter.html -Verbose -Type GPODuplicates
                            }
                            New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                        }
                    } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                }
            }
        }
    }
}