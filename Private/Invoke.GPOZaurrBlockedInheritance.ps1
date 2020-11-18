$GPOZaurrBlockedInheritance = [ordered] @{
    Name           = 'Group Policy Blocked Inhertiance'
    Enabled        = $true
    ActionRequired = $null
    Data           = $null
    Execute        = {
        Get-GPOZaurrInheritance -IncludeBlockedObjects -OnlyBlockedInheritance -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing     = {

    }
    Variables      = @{

    }
    Overview       = {

    }
    Solution       = {
        New-HTMLTable -DataTable $Script:Reporting['GPOBlockedInheritance']['Data'] -Filtering
        if ($Script:Reporting['GPOBlockedInheritance']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOBlockedInheritance']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}