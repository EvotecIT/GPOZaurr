$GPOZaurrLinks = [ordered] @{
    Name           = 'Group Policy Links'
    Enabled        = $true
    ActionRequired = $null
    Data           = $null
    Execute        = {
        Get-GPOZaurrLink -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -Summary
    }
    Processing     = {

    }
    Variables      = @{

    }
    Overview       = {

    }
    Solution       = {
        New-HTMLTable -DataTable $Script:Reporting['GPOLinks']['Data'] -Filtering -ScrollX -PagingOptions 7, 15, 30, 45, 60 -ExcludeProperty 'LinksObjects' {
            New-HTMLTableCondition -Name 'Linked' -Value 'True' -BackgroundColor PaleGreen -ComparisonType string -FailBackgroundColor Salmon
        }
        if ($Script:Reporting['GPOLinks']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOLinks']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}