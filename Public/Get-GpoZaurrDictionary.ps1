function Get-GPOZaurrDictionary {
    [cmdletBinding()]
    param(
        [string] $Splitter = [System.Environment]::NewLine
    )
    foreach ($Policy in $Script:GPODitionary.Keys) {

        if ($Script:GPODitionary[$Policy].ByReports) {
            [Array] $Type = foreach ($T in  $Script:GPODitionary[$Policy].ByReports ) {
                $T.Report
            }

        } else {
            [Array]$Type = foreach ($T in $Script:GPODitionary[$Policy].Types) {
                ( -join ($T.Category, '/', $T.Settings))
            }
        }

        [PSCustomObject] @{
            Name  = $Policy
            Types = $Type -join $Splitter
            Path  = $Script:GPODitionary[$Policy].GPOPath -join $Splitter
            #Details = $Script:GPODitionary[$Policy]
        }
    }
}