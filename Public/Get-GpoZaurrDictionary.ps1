function Get-GPOZaurrDictionary {
    <#
    .SYNOPSIS
    Retrieves a dictionary of Group Policy Objects (GPOs) with their associated types and paths.

    .DESCRIPTION
    This function retrieves a dictionary of Group Policy Objects (GPOs) along with their associated types and paths. It iterates through the GPOs stored in the $Script:GPODitionary variable and constructs a custom object for each GPO containing its name, types, and path.

    .PARAMETER Splitter
    Specifies the delimiter used to separate multiple types or paths. Default value is [System.Environment]::NewLine.

    .EXAMPLE
    Get-GPOZaurrDictionary
    Retrieves the dictionary of GPOs with their types and paths using the default newline delimiter.

    .EXAMPLE
    Get-GPOZaurrDictionary -Splitter ","
    Retrieves the dictionary of GPOs with their types and paths using a comma as the delimiter.

    #>
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