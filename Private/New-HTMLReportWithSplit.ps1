function New-HTMLReportWithSplit {
    <#
    .SYNOPSIS
    Creates an HTML report with the option to split it into multiple files for easier viewing.

    .DESCRIPTION
    This function generates an HTML report based on the provided parameters. It also allows splitting the report into multiple files for better organization and readability.

    .PARAMETER FilePath
    Specifies the path where the HTML report will be saved.

    .PARAMETER Online
    Indicates whether the report should be generated for online viewing.

    .PARAMETER HideHTML
    Hides the HTML report file after generation.

    .PARAMETER CurrentReport
    Specifies the type of the current report to generate.

    .EXAMPLE
    New-HTMLReportWithSplit -FilePath "C:\Reports\GPO_Report.html" -Online -HideHTML -CurrentReport "Security"

    Generates an HTML report for the "Security" report type and saves it to the specified file path. The report is optimized for online viewing and the HTML file is hidden after generation.

    .EXAMPLE
    New-HTMLReportWithSplit -FilePath "C:\Reports\All_Reports.html" -CurrentReport "All"

    Generates an HTML report for all available report types and saves it to the specified file path.

    #>
    [cmdletBinding()]
    param(
        [string] $FilePath,
        [switch] $Online,
        [switch] $HideHTML,
        [string] $CurrentReport
    )

    # Split reports into multiple files for easier viewing
    $DateName = $(Get-Date -f yyyy-MM-dd_HHmmss)
    $FileName = [io.path]::GetFileNameWithoutExtension($FilePath)
    $DirectoryName = [io.path]::GetDirectoryName($FilePath)
    foreach ($T in $Script:GPOConfiguration.Keys) {
        $NewFileName = $FileName + '_' + $T + "_" + $DateName + '.html'
        $FilePath = [io.path]::Combine($DirectoryName, $NewFileName)

        # we execute only if enabled and current report not given which means there's a single report to run
        # or if current report is given and it matches the current report type which works for split reprots
        if ($Script:GPOConfiguration[$T].Enabled -eq $true -and ((-not $CurrentReport) -or ($CurrentReport -and $CurrentReport -eq $T))) {
            Write-Color -Text '[i]', '[HTML ] ', "Generating HTML report ($FilePath) for $T with split reports" -Color Yellow, DarkGray, Yellow
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

                # if ($Type.Count -eq 1) {
                #     foreach ($T in $Script:GPOConfiguration.Keys) {
                #         if ($Script:GPOConfiguration[$T].Enabled -eq $true) {
                #             if ($Script:GPOConfiguration[$T]['Summary']) {
                #                 $Script:Reporting[$T]['Summary'] = Invoke-Command -ScriptBlock $Script:GPOConfiguration[$T]['Summary']
                #             }
                #             & $Script:GPOConfiguration[$T]['Solution']
                #         }
                #     }
                # } else {

                if ($Script:GPOConfiguration[$T]['Summary']) {
                    $Script:Reporting[$T]['Summary'] = Invoke-Command -ScriptBlock $Script:GPOConfiguration[$T]['Summary']
                }
                New-HTMLTab -Name $Script:GPOConfiguration[$T]['Name'] {
                    & $Script:GPOConfiguration[$T]['Solution']
                }

                # }
            } -Online:$Online.IsPresent -ShowHTML:(-not $HideHTML) -FilePath $FilePath
        }
    }
}