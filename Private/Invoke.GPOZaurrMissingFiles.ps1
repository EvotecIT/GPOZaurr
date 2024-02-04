$GPOZaurrMissingFiles = [ordered] @{
    Name       = 'Group Policies with missing files'
    Enabled    = $true
    Action     = $null
    Data       = $null
    Execute    = {
        Get-GPOZaurrMissingFiles -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -GPOName $GPOName -GPOGUID $GPOGUID | Sort-Object -Property ErrorCount -Descending
    }
    Processing = {
        foreach ($GPO in  $Script:Reporting['GPOBrokenPartially']['Data']) {
            if ($GPO.ErrorCount -gt 0) {
                $Script:Reporting['GPOBrokenPartially']['Variables']['RequireFixing']++
            }
        }
        if ($Script:Reporting['GPOBrokenPartially']['Variables']['RequireFixing'] -gt 0) {
            $Script:Reporting['GPOBrokenPartially']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOBrokenPartially']['ActionRequired'] = $false
        }
    }
    Variables  = @{
        RequireFixing = 0
    }
    Overview   = {

    }
    Resources  = @(

    )
    Summary    = {
        New-HTMLText -FontSize 10pt -TextBlock {
            "Group Policies can become broken for various reasons. One of the common reasons is when GPOs are created and then deleted without being properly removed from Active Directory. "
            "In other cases it can be due to replication issues, or simply due to corruption. "
            "This can lead to GPOs not being applied as expected, or not being applied at all. "
            "If random files are missing from GPOs it's important to fix them to ensure that GPOs are applied as expected. "
            "This report provides you with list of GPOs that have missing files. "
            "Usually once files are missing it's best to restore them from backup (if available) or remove given section completly. "
            "It's not possible to restore missing files from Active Directory directly or manually. "
        } -LineBreak
        New-HTMLText -Text 'As it stands currently there are ', $Script:Reporting['GPOBrokenPartially']['Variables']['RequireFixing'], ' error requring fixing. ' -FontSize 10pt -FontWeight normal, bold, normal
    }
    Solution   = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPOBrokenPartially']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartLegend -Names 'Bad' -Color Salmon
                    New-ChartBar -Name 'Missing Files' -Value $Script:Reporting['GPOBrokenPartially']['Variables']['RequireFixing']
                } -Title 'Group Policies with Missing Files' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policy Missing Files' {
            New-HTMLTable -DataTable $Script:Reporting['GPOBrokenPartially']['Data'] -Filtering {
                New-HTMLTableCondition -Name 'ErrorCount' -Value 0 -BackgroundColor LightGreen -ComparisonType number -FailBackgroundColor Salmon -HighlightHeaders 'ErrorCount', 'ErrorCategory', 'ErrorDetails'
            } -PagingOptions 10, 20, 30, 40, 50
        }
        if ($Script:Reporting['Settings']['HideSteps'] -eq $false) {
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
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrMissingFilesBefore.html -Verbose -Type GPOMissingFiles
                                }
                                New-HTMLText -TextBlock {
                                    "When executed it will take a while to generate all data and provide you with new report depending on size of environment. "
                                    "Once confirmed that data is still showing issues and requires fixing please proceed with next step. "
                                }
                                New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
                                New-HTMLCodeBlock -Code {
                                    $GPOOutput = Get-GPOZaurrMissingFiles -BrokenOnly
                                    $GPOOutput | Format-Table # do your actions as desired
                                }
                                New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
                            }
                            New-HTMLWizardStep -Name 'Remove Broken objects' {
                                New-HTMLText -Text "There is no automated way to fix missing files. You need to manually fix them. "
                                New-HTMLText -Text "You can do so by restoring files from backup or removing section completly. "
                            }
                            New-HTMLWizardStep -Name 'Verification report' {
                                New-HTMLText -TextBlock {
                                    "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                                }
                                New-HTMLCodeBlock -Code {
                                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrMissingFilesAfter.html -Verbose -Type GPOMissingFiles
                                }
                                New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
                            }
                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center -EnableAllAnchors
                    }
                }
            }
        }
        if ($Script:Reporting['GPOBrokenPartially']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOZaurrMissingFiles']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}