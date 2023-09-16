$GPOZaurrGPORedirects = [ordered] @{
    Name       = 'Group Policies With Redirected SYSVOL'
    Enabled    = $false
    Action     = $null
    Data       = $null
    Execute    = {
        Get-GPOZaurrRedirect -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing = {
        foreach ($GPO in $Script:Reporting['GPORedirect']['Data']) {
            $Script:Reporting['GPORedirect']['Variables']['GPOTotal']++
            if ($GPO.IsCorrect -eq $true) {
                $Script:Reporting['GPORedirect']['Variables']['GPOIsCorrect']++
            } else {
                $Script:Reporting['GPORedirect']['Variables']['GPOIsNotCorrect']++
            }
        }
    }
    Variables  = @{
        GPOTotal        = 0
        GPOIsCorrect    = 0
        GPOIsNotCorrect = 0
    }
    Overview   = {

    }
    Summary    = {
        New-HTMLText -TextBlock {
            "Group Policies are stored in Active Directory and SYSVOL. SYSVOL is a folder shared by the domain controllers to hold its logon scripts, "
            "group policy data, and other domain-wide data which needs to be available anywhere there is a domain controller. "
            "SYSVOL provides a default location for files that must be shared for common access throughout a domain. "
            "However it is possible to redirect SYSVOL to a different location by modifying "
            "gPCFileSysPath "
            "attribute of a GPO. "
            "This is not recommended and should be avoided, but it can also be a sign of compromise."
            "This report shows which GPOs are redirected and which are not. "
        } -FontSize 10pt -LineBreak -FontWeight normal, normal, normal, normal, bold, normal, normal, normal -Color None, None, None, None, RedBerry, None, None, None
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies in total: ', $Script:Reporting['GPORedirect']['Variables']['GPOTotal'] -FontWeight normal, bold
            New-HTMLListItem -Text 'Group Policies without redirects: ', $Script:Reporting['GPORedirect']['Variables']['GPOIsCorrect'] -FontWeight normal, bold -Color None, MintGreen
            New-HTMLListItem -Text 'Group Policies with redirects: ', $Script:Reporting['GPORedirect']['Variables']['GPOIsNotCorrect'] -FontWeight normal, bold -Color None, RedBerry
        } -FontSize 10pt
        New-HTMLText -TextBlock {
            "If you notice any GPO with redirect, you should investigate it. "
        } -FontSize 10pt -LineBreak
    }
    Solution   = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPORedirect']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartBarOptions -Type barStacked
                    New-ChartLegend -Name 'No redirects', 'With redirects' -Color MintGreen, MediumOrchid
                    New-ChartBar -Name 'No redirection' -Value $Script:Reporting['GPORedirect']['Variables']['GPOIsCorrect'], $Script:Reporting['GPORedirect']['Variables']['GPOIsNotCorrect']
                } -Title 'Group Policies with redirects' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policies showing redirects (if any)' {
            New-HTMLTable -DataTable $Script:Reporting['GPORedirect']['Data'] -Filtering {
                New-HTMLTableCondition -Name 'IsCorrect' -Value $false -BackgroundColor Salmon -ComparisonType bool -FailBackgroundColor MintGreen -HighlightHeaders 'IsCorrect', 'Path', 'ExpectedPath'
            }
        }
        if ($Script:Reporting['GPORedirect']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPORedirect']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}