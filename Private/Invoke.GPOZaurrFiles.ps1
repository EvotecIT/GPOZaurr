$GPOZaurrFiles = [ordered] @{
    Name           = 'SYSVOL (NetLogon) Files List'
    Enabled        = $true
    ActionRequired = $null
    Data           = $null
    Execute        = {
        Get-GPOZaurrFiles
    }
    Processing     = {

    }
    Variables      = @{

    }
    Overview       = {

    }
    Solution       = {
        New-HTMLTable -DataTable $Script:Reporting['GPOFiles']['Data'] -Filtering
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