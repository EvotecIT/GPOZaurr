$GPOZaurrNetLogonPermissions = [ordered] @{
    Name       = 'NetLogon Permissions'
    Enabled    = $true
    Data       = $null
    Execute    = {

        $NetLogon = Get-GPOZaurrNetLogon
        $NetLogonOwners = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersAdministrators = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersNotAdministrative = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersAdministrative = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersAdministrativeNotAdministrators = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersToFix = [System.Collections.Generic.List[PSCustomObject]]::new()
        foreach ($File in $Netlogon) {
            if ($File.FileSystemRights -eq 'Owner') {
                $NetLogonOwners.Add($File)

                if ($File.PrincipalType -eq 'WellKnownAdministrative') {
                    $NetLogonOwnersAdministrative.Add($File)
                } elseif ($File.PrincipalType -eq 'Administrative') {
                    $NetLogonOwnersAdministrative.Add($File)
                } else {
                    $NetLogonOwnersNotAdministrative.Add($File)
                }

                if ($File.PrincipalSid -eq 'S-1-5-32-544') {
                    $NetLogonOwnersAdministrators.Add($File)
                } elseif ($File.PrincipalType -in 'WellKnownAdministrative', 'Administrative') {
                    $NetLogonOwnersAdministrativeNotAdministrators.Add($File)
                    $NetLogonOwnersToFix.Add($File)
                } else {
                    $NetLogonOwnersToFix.Add($File)
                }
            }
        }
     }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {
        New-HTMLPanel {
            New-HTMLText -Text 'Following chart presents ', 'NetLogon Summary' -FontSize 10pt -FontWeight normal, bold
            New-HTMLList -Type Unordered {
                & $Script:GPOConfiguration['NetLogon']['List']
            } -FontSize 10pt
            #New-HTMLText -FontSize 10pt -Text 'Those problems must be resolved before doing other clenaup activities.'
            New-HTMLChart {
                New-ChartPie -Name 'Correct Owners' -Value $NetLogonOwnersAdministrators.Count -Color LightGreen
                New-ChartPie -Name 'Incorrect Owners' -Value $NetLogonOwnersToFix.Count -Color Crimson
            } -Title 'NetLogon Owners' -TitleAlignment center
        }
        New-HTMLPanel {

        }
    }
    Solution   = {
        New-HTMLTab -Name 'NetLogon Owners' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    "Following table shows NetLogon file owners. It's important that NetLogon file owners are set to BUILTIN\Administrators (SID: S-1-5-32-544). "
                    "Owners have full control over the file object. Current owner of the file may be an Administrator but it doesn't guarentee that he will be in the future. "
                    "That's why as a best-practice it's recommended to change any non-administrative owners to BUILTIN\Administrators, and even Administrative accounts should be replaced with it. "
                } -FontSize 10pt
                New-HTMLList -Type Unordered {
                    & $Script:GPOConfiguration['NetLogon']['List']
                } -FontSize 10pt
                New-HTMLText -Text "Follow the steps below table to get NetLogon Owners into compliant state." -FontSize 10pt
            }
            New-HTMLSection -Name 'NetLogon Files List' {
                New-HTMLTable -DataTable $NetLogonOwners -Filtering {
                    New-HTMLTableCondition -Name 'PrincipalSid' -Value "S-1-5-32-544" -BackgroundColor LightGreen -ComparisonType string
                    New-HTMLTableCondition -Name 'PrincipalSid' -Value "S-1-5-32-544" -BackgroundColor Salmon -ComparisonType string -Operator ne
                    New-HTMLTableCondition -Name 'PrincipalType' -Value "WellKnownAdministrative" -BackgroundColor LightGreen -ComparisonType string -Operator eq
                }
            }
            New-HTMLSection -Name 'Steps to fix NetLogon Owners ' {
                New-HTMLContainer {
                    New-HTMLSpanStyle -FontSize 10pt {
                        New-HTMLText -Text 'Following steps will guide you how to fix NetLogon Owners and make them compliant.'
                        New-HTMLWizard {
                            & $Script:GPOConfiguration['NetLogon']['Wizard']
                        } -RemoveDoneStepOnNavigateBack -Theme arrows -ToolbarButtonPosition center
                    }
                }
            }
        }
        New-HTMLTab -Name 'NetLogon Permissions' {
            New-HTMLSection -Name 'NetLogon Files List' {
                New-HTMLTable -DataTable $Netlogon -Filtering
            }
        }
    }
}