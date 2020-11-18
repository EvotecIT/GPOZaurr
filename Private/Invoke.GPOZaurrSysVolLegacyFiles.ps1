$GPOZaurrSysVolLegacyFiles = [ordered] @{
    Name       = 'SYSVOL Legacy ADM Files'
    Enabled    = $false
    Action     = $null
    Data       = $null
    Execute    = {
        Get-GPOZaurrLegacyFiles -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {

    }
    Solution   = {
        New-HTMLTable -DataTable $Script:Reporting['SysVolLegacyFiles']['Data'] -Filtering
        if ($Script:Reporting['SysVolLegacyFiles']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['SysVolLegacyFiles']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}