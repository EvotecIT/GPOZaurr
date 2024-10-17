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
    Summary    = {
        New-HTMLText -TextBlock {
            "This report shows legacy ADM files in SYSVOL. These files are no longer used and can be safely removed. "
            "Before 'adm' files were replaced by 'admx' files, they were stored in the SYSVOL share, directly per each GPO. "
            "This report will help you identify and remove these files. "
        }
    }
    Solution   = {
        New-HTMLSection -Invisible {
            New-HTMLPanel {
                & $Script:GPOConfiguration['SysVolLegacyFiles']['Summary']
            }
        }
        New-HTMLSection -Name "Legacy ADM Files in SYSVOL" {
            New-HTMLTable -DataTable $Script:Reporting['SysVolLegacyFiles']['Data'] -Filtering -PagingOptions 7, 15, 30, 45, 60 -ScrollX
        }
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