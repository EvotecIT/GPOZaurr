$GPOZaurrFiles = [ordered] @{
    Name           = 'SYSVOL (NetLogon) Files List'
    Enabled        = $true
    ActionRequired = $null
    Data           = $null
    Execute        = {
        Get-GPOZaurrFiles -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing     = {

    }
    Variables      = @{

    }
    Overview       = {

    }
    Solution       = {
        New-HTMLTable -DataTable $Script:Reporting['GPOFiles']['Data'] -Filtering -ScrollX -PagingOptions 7, 15, 30, 45, 60 {
            New-HTMLTableCondition -Name 'SuggestedAction' -Value 'Requires verification' -BackgroundColor YellowOrange -ComparisonType string
            New-HTMLTableCondition -Name 'SuggestedAction' -Value 'Consider deleting' -BackgroundColor Salmon -ComparisonType string
            New-HTMLTableCondition -Name 'SuggestedAction' -Value 'GPO requires cleanup' -BackgroundColor RedRobin -ComparisonType string
            New-HTMLTableCondition -Name 'SuggestedAction' -Value 'Skip assesment' -BackgroundColor LightGreen -ComparisonType string
        }
        if ($Script:Reporting['GPOFiles']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOFiles']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}