<#
$Script:GPOConfiguration = [ordered] @{
    GPOOrphans     = [ordered] @{
        Wizard = {
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
                    $GPOOutput = Get-GPOZaurrBroken
                    $GPOOutput | Format-Table
                }
                New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
            }
            New-HTMLWizardStep -Name 'Fix GPOs not available on SYSVOL' {
                New-HTMLText -Text "Following command when executed runs cleanup procedure that removes all broken GPOs on SYSVOL side."
                New-HTMLText -Text "Make sure when running it for the first time to run it with ", "WhatIf", " parameter as shown below to prevent accidental removal." -FontWeight normal, bold, normal -Color Black, Red, Black

                New-HTMLCodeBlock -Code {
                    Remove-GPOZaurrBroken -Type SYSVOL -WhatIf
                }
                New-HTMLText -TextBlock {
                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be deleted matches expected data. Once happy with results please follow with command: "
                }
                New-HTMLCodeBlock -Code {
                    Remove-GPOZaurrBroken -Type SYSVOL -LimitProcessing 2 -BackupPath $Env:UserProfile\Desktop\GPOSYSVOLBackup
                }
                New-HTMLText -TextBlock {
                    "This command when executed deletes only first X broken GPOs. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur."
                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
                }
                New-HTMLText -Text "If there's nothing else to be deleted on SYSVOL side, we can skip to next step step"
            }
            New-HTMLWizardStep -Name 'Fix GPOs not available on AD' {
                New-HTMLText -Text "Following command when executed runs cleanup procedure that removes all broken GPOs on Active Directory side."
                New-HTMLText -Text "Make sure when running it for the first time to run it with ", "WhatIf", " parameter as shown below to prevent accidental removal." -FontWeight normal, bold, normal -Color Black, Red, Black

                New-HTMLCodeBlock -Code {
                    Remove-GPOZaurrBroken -Type AD -WhatIf
                }
                New-HTMLText -TextBlock {
                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be deleted matches expected data. Once happy with results please follow with command: "
                }
                New-HTMLCodeBlock -Code {
                    Remove-GPOZaurrBroken -Type AD -LimitProcessing 2 -BackupPath $Env:UserProfile\Desktop\GPOSYSVOLBackup
                }
                New-HTMLText -TextBlock {
                    "This command when executed deletes only first X broken GPOs. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur."
                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
                }
                New-HTMLText -Text "If there's nothing else to be deleted on AD side, we can skip to next step step"
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
        }
    }
    GPOList        = [ordered] @{
        List   = {

        }
        Wizard = {
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
            New-HTMLWizardStep -Name 'Remove GPOs that are EMPTY or UNLINKED' {
                New-HTMLText -Text @(
                    "Following command when executed removes every ",
                    "EMPTY"
                    " or "
                    "NOT LINKED"
                    " Group Policy. Make sure when running it for the first time to run it with ",
                    "WhatIf",
                    " parameter as shown below to prevent accidental removal.",
                    "Make sure to use BackupPath which will make sure that for each GPO that is about to be deleted a backup is made to folder on a desktop."
                ) -FontWeight normal, bold, normal, bold, normal, bold, normal, normal -Color Black, Red, Black, Red, Black
                New-HTMLCodeBlock -Code {
                    Remove-GPOZaurr -Type Empty, Unlinked -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -WhatIf
                }
                New-HTMLText -TextBlock {
                    "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be deleted matches expected data. Once happy with results please follow with command: "
                }
                New-HTMLCodeBlock -Code {
                    Remove-GPOZaurr -Type Empty, Unlinked -BackupPath "$Env:UserProfile\Desktop\GPO" -LimitProcessing 2 -Verbose
                }
                New-HTMLText -TextBlock {
                    "This command when executed deletes only first empty or unlinked GPOs. Use LimitProcessing parameter to prevent mass delete and increase the counter when no errors occur."
                    "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
                    "Please make sure to check if backup is made as well before going all in."
                }
                New-HTMLText -Text "If there's nothing else to be deleted on SYSVOL side, we can skip to next step step"
            }
            New-HTMLWizardStep -Name 'Verification report' {
                New-HTMLText -TextBlock {
                    "Once cleanup task was executed properly, we need to verify that report now shows no problems."
                }
                New-HTMLCodeBlock -Code {
                    Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrEmptyUnlinkedAfter.html -Verbose -Type GPOList
                }
                New-HTMLText -Text "If there are no more empty or unlinked GPOs in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
            }
        }
    }
    GPOConsistency = $ScriptGPOConfigurationGPOConsistency
    NetLogon       = $ScriptGPOConfigurationNetLogon
    GPOOwners      = $ScriptGPOConfigurationGPOOwners
}
#>

$Script:GPOConfiguration = @{
    GPOConsistency = $GPOZaurrConsistency
    GPOOwners      = $GPOZaurrOwners
}