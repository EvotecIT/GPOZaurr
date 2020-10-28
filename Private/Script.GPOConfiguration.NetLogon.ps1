$ScriptGPOConfigurationNetLogon = [ordered] @{
    List   = {
        New-HTMLListItem -Text 'NetLogon Files in Total: ', $NetLogonOwners.Count -FontWeight normal, bold
        New-HTMLListItem -Text 'NetLogon BUILTIN\Administrators as Owner: ', $NetLogonOwnersAdministrators.Count -FontWeight normal, bold
        New-HTMLListItem -Text "NetLogon Owners requiring change: ", $NetLogonOwnersToFix.Count -FontWeight normal, bold {
            New-HTMLList -Type Unordered {
                New-HTMLListItem -Text 'Not Administrative: ', $NetLogonOwnersNotAdministrative.Count -FontWeight normal, bold
                New-HTMLListItem -Text 'Administrative, but not BUILTIN\Administrators: ', $NetLogonOwnersAdministrativeNotAdministrators.Count -FontWeight normal, bold
            }
        }
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
                Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrNetLogonBefore.html -Verbose -Type NetLogon
            }
            New-HTMLText -TextBlock {
                "When executed it will take a while to generate all data and provide you with new report depending on size of environment."
                "Once confirmed that data is still showing issues and requires fixing please proceed with next step."
            }
            New-HTMLText -Text "Alternatively if you prefer working with console you can run: "
            New-HTMLCodeBlock -Code {
                $NetLogonOutput = Get-GPOZaurrNetLogon -Verbose
                $NetLogonOutput | Format-Table
            }
            New-HTMLText -Text "It provides same data as you see in table above just doesn't prettify it for you."
        }
        New-HTMLWizardStep -Name 'Set non-compliant file owners to BUILTIN\Administrators' {
            New-HTMLText -Text "Following command when executed runs internally command that lists all file owners and if it doesn't match changes it BUILTIN\Administrators. It doesn't change compliant owners."
            New-HTMLText -Text "Make sure when running it for the first time to run it with ", "WhatIf", " parameter as shown below to prevent accidental removal." -FontWeight normal, bold, normal -Color Black, Red, Black

            New-HTMLCodeBlock -Code {
                Repair-GPOZaurrNetLogonOwner -Verbose -WhatIf
            }
            New-HTMLText -TextBlock {
                "After execution please make sure there are no errors, make sure to review provided output, and confirm that what is about to be changed matches expected data. Once happy with results please follow with command: "
            }
            New-HTMLCodeBlock -Code {
                Repair-GPOZaurrNetLogonOwner -Verbose -LimitProcessing 2
            }
            New-HTMLText -TextBlock {
                "This command when executed sets new owner only on first X non-compliant NetLogon files. Use LimitProcessing parameter to prevent mass change and increase the counter when no errors occur."
                "Repeat step above as much as needed increasing LimitProcessing count till there's nothing left. In case of any issues please review and action accordingly."
            }
        }
        New-HTMLWizardStep -Name 'Verification report' {
            New-HTMLText -TextBlock {
                "Once cleanup task was executed properly, we need to verify that report now shows no problems."
            }
            New-HTMLCodeBlock -Code {
                Invoke-GPOZaurr -FilePath $Env:UserProfile\Desktop\GPOZaurrNetLogonAfter.html -Verbose -Type NetLogon
            }
            New-HTMLText -Text "If everything is healthy in the report you're done! Enjoy rest of the day!" -Color BlueDiamond
        }
    }
}