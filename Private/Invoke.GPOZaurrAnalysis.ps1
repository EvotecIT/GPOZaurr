﻿$GPOZaurrAnalysis = [ordered] @{
    Name           = 'Group Policy Content'
    Enabled        = $true
    ActionRequired = $null
    Data           = $null
    Execute        = {
        Invoke-GPOZaurrContent -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -GPOName $GPOName -GPOGUID $GPOGUID
    }
    Processing     = {

    }
    Variables      = @{

    }
    Overview       = {

    }
    Solution       = {
        foreach ($Key in $Script:Reporting['GPOAnalysis']['Data'].Keys) {
            New-HTMLTab -Name $Key {
                New-HTMLTable -DataTable $Script:Reporting['GPOAnalysis']['Data'][$Key] -Filtering -Title $Key -ScrollX
            }
        }
        if ($Script:Reporting['GPOAnalysis']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOAnalysis']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}