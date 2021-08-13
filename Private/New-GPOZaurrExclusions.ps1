function New-GPOZaurrExclusions {
    [cmdletBinding()]
    param(
        [alias('ExcludeGroupPolicies', 'ExclusionsCode', 'ExclusionsArray')][Parameter(Position = 1)][object] $Exclusions
    )

    if ($Exclusions) {
        if ($Exclusions -is [scriptblock]) {
            #$Script:Reporting[$T]['Exclusions'] = $Exclusions
            #$Script:Reporting[$T]['ExclusionsCode'] = $Exclusions
            [string] $Code = @(
                "`$Exclusions = {"
                "    " + $Exclusions.ToString()
                "}"
            )
            $Code
        }
        if ($Exclusions -is [Array]) {
            #$Script:Reporting[$T]['Exclusions'] = $Exclusions
            #$ExclusionsArray = $Exclusions
            [string] $Code = @(
                '$Exclusions = @('
                [System.Environment]::NewLine
                foreach ($Exclusion in $Exclusions) {
                    "   `"$Exclusion`"" + [System.Environment]::NewLine
                }
                [System.Environment]::NewLine
                ')'
            )
            $Code
        }
    }
}