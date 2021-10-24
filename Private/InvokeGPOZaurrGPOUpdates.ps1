$GPOZaurrGPOUpdates = [ordered] @{
    Name       = 'Group Policies added last 7 days'
    Enabled    = $false
    Action     = $null
    Data       = $null
    Execute    = {
        Get-GPOZaurrUpdates -DateRange Last14Days -DateProperty WhenCreated -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing = {
        foreach ($GPO in $Script:Reporting['GPOUpdates']['Data']) {

            $Script:Reporting['GPOUpdates']['Variables']['GPOTotal']++

            if ($GPO.LinksEnabledCount -eq 0) {
                $Script:Reporting['GPOUpdates']['Variables']['GPOWithoutEnabledLinks']++
            } else {
                $Script:Reporting['GPOUpdates']['Variables']['GPOWithEnabledLinks']++
            }
            if ($GPO.AffectedCount -eq 0) {
                $Script:Reporting['GPOUpdates']['Variables']['GPOWithoutAffectedObjects']++
            }
        }
    }
    Variables  = @{
        GPOTotal                  = 0
        GPOWithoutEnabledLinks    = 0
        GPOWithEnabledLinks       = 0
        GPOWithoutAffectedObjects = 0
    }
    Overview   = {

    }
    Summary    = {
        New-HTMLText -TextBlock {
            "Group Policies are important part of Active Directory. Knowing when those are created and what they affect is important part of admins work."
            "This report shows which GPOs were created in last 7 days and how many objects those are affecting."
        } -FontSize 10pt -LineBreak
        New-HTMLList -Type Unordered {
            New-HTMLListItem -Text 'Group Policies added in last 7 days: ', $Script:Reporting['GPOUpdates']['Variables']['GPOTotal'] -FontWeight normal, bold
            New-HTMLListItem -Text 'Group Policies without enabled links: ', $Script:Reporting['GPOUpdates']['Variables']['GPOWithoutEnabledLinks'] -FontWeight normal, bold
            New-HTMLListItem -Text 'Group Policies with enabled links: ', $Script:Reporting['GPOUpdates']['Variables']['GPOWithEnabledLinks'] -FontWeight normal, bold
            New-HTMLListItem -Text 'Group Policies without affected objects: ', $Script:Reporting['GPOUpdates']['Variables']['GPOWithoutAffectedObjects'] -FontWeight normal, bold

        } -FontSize 10pt
        New-HTMLText -TextBlock {
            "If you notice any GPO that is not working or against best practices please reach out to your collegues to confirm whether this is as expected."
        } -FontSize 10pt -LineBreak
    }
    Solution   = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['GPOUpdates']['Summary']
            }
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartBarOptions -Type barStacked
                    New-ChartLegend -Name 'No enabled links', 'Enabled links' -Color Crimson, MediumOrchid
                    New-ChartBar -Name 'Links enabled' -Value $Script:Reporting['GPOUpdates']['Variables']['GPOWithoutEnabledLinks'], $Script:Reporting['GPOUpdates']['Variables']['GPOWithEnabledLinks']
                } -Title 'Group Policies created last 7 days' -TitleAlignment center
            }
        }
        New-HTMLSection -Name 'Group Policies added in last 7 days' {
            New-HTMLTable -DataTable $Script:Reporting['GPOUpdates']['Data'] -Filtering {
                New-HTMLTableCondition -Name 'LinksCount' -Value 0 -BackgroundColor Salmon -ComparisonType number
                New-HTMLTableCondition -Name 'LinksEnabledCount' -Value 0 -BackgroundColor Salmon -ComparisonType number
                New-HTMLTableCondition -Name 'AffectedCount' -Value 0 -BackgroundColor Salmon -ComparisonType number
            }
        }
        if ($Script:Reporting['GPOUpdates']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOUpdates']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}