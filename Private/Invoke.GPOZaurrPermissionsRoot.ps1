$GPOZaurrPermissionsRoot = [ordered] @{
    Name       = 'Group Policies Root Permissions'
    Enabled    = $false
    Action     = $null
    Data       = $null
    Execute    = {
        Get-GPOZaurrPermissionRoot -SkipNames -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {

    }
    Solution   = {
        New-HTMLTable -DataTable $Script:Reporting['GPOPermissionsRoot']['Data'] -Filtering -PagingOptions 7, 15, 30, 45, 60 -ScrollX
        if ($Script:Reporting['GPOPermissionsRoot']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOPermissionsRoot']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}