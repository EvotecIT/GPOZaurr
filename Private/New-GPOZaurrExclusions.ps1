function New-GPOZaurrExclusions {
    <#
    .SYNOPSIS
    Creates exclusion code for Group Policy Objects (GPOs) in Zaurr format.

    .DESCRIPTION
    The New-GPOZaurrExclusions function generates exclusion code for GPOs in Zaurr format based on the provided exclusions. It supports both script block and array types of exclusions.

    .PARAMETER Exclusions
    Specifies the exclusions to be included in the generated code. This parameter accepts script blocks or arrays of exclusion items.

    .EXAMPLE
    $exclusions = {
        # Exclude specific settings
        'Setting1',
        'Setting2'
    }
    New-GPOZaurrExclusions -Exclusions $exclusions

    .EXAMPLE
    $exclusions = @('Setting1', 'Setting2')
    New-GPOZaurrExclusions -Exclusions $exclusions
    #>
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