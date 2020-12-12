$GPOZaurrPermissionsAnalysis = [ordered] @{
    Name       = 'Group Policy Permissions Analysis'
    Enabled    = $true
    Action     = $null
    Data       = $null
    Execute    = {
        Get-GPOZaurrPermissionAnalysis -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {

    }
    Solution   = {
        New-HTMLTable -DataTable $Script:Reporting['GPOPermissions']['Data'] -Filtering
        if ($Script:Reporting['GPOPermissions']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOPermissions']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}