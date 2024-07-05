function New-HTMLReportAll {
    <#
    .SYNOPSIS
    Generates an HTML report based on specified parameters.

    .DESCRIPTION
    This function generates an HTML report with customizable content based on the provided parameters. It supports generating standard reports and can be used for various reporting purposes.

    .PARAMETER FilePath
    Specifies the file path where the HTML report will be saved.

    .PARAMETER Online
    Indicates whether the report should be generated online.

    .PARAMETER HideHTML
    Hides the HTML content of the report if specified.

    .PARAMETER Type
    Specifies the type of report to generate.

    .EXAMPLE
    New-HTMLReportAll -FilePath "C:\Reports\Report.html" -Online -Type "Summary"
    Generates an HTML report with a summary of data and saves it to the specified file path.

    .EXAMPLE
    New-HTMLReportAll -FilePath "C:\Reports\FullReport.html" -Type "Detailed"
    Generates a detailed HTML report and saves it to the specified file path.

    #>
    [CmdletBinding()]
    param(
        [string] $FilePath,
        [switch] $Online,
        [switch] $HideHTML,
        [Array] $Type
    )
    # Standard reports as requested
    Write-Color -Text '[i]', '[HTML ] ', "Generating HTML report ($FilePath)" -Color Yellow, DarkGray, Yellow
    New-HTML -Author 'Przemysław Kłys @ Evotec' -TitleText 'GPOZaurr Report' {
        New-HTMLTabStyle -BorderRadius 0px -TextTransform capitalize -BackgroundColorActive SlateGrey
        New-HTMLSectionStyle -BorderRadius 0px -HeaderBackGroundColor Grey -RemoveShadow
        New-HTMLPanelStyle -BorderRadius 0px
        New-HTMLTableOption -DataStore JavaScript -BoolAsString -ArrayJoinString ', ' -ArrayJoin

        New-HTMLHeader {
            New-HTMLSection -Invisible {
                New-HTMLSection {
                    New-HTMLText -Text "Report generated on $(Get-Date)" -Color Blue
                } -JustifyContent flex-start -Invisible
                New-HTMLSection {
                    New-HTMLText -Text "GPOZaurr - $($Script:Reporting['Version'])" -Color Blue
                } -JustifyContent flex-end -Invisible
            }
        }

        if ($Type.Count -eq 1) {
            foreach ($T in $Script:GPOConfiguration.Keys) {
                if ($Script:GPOConfiguration[$T].Enabled -eq $true) {
                    if ($Script:GPOConfiguration[$T]['Summary']) {
                        $Script:Reporting[$T]['Summary'] = Invoke-Command -ScriptBlock $Script:GPOConfiguration[$T]['Summary']
                    }
                    & $Script:GPOConfiguration[$T]['Solution']
                }
            }
        } else {
            foreach ($T in $Script:GPOConfiguration.Keys) {
                if ($Script:GPOConfiguration[$T].Enabled -eq $true) {
                    if ($Script:GPOConfiguration[$T]['Summary']) {
                        $Script:Reporting[$T]['Summary'] = Invoke-Command -ScriptBlock $Script:GPOConfiguration[$T]['Summary']
                    }
                    New-HTMLTab -Name $Script:GPOConfiguration[$T]['Name'] {
                        & $Script:GPOConfiguration[$T]['Solution']
                    }
                }
            }
        }
    } -Online:$Online.IsPresent -ShowHTML:(-not $HideHTML) -FilePath $FilePath
}