function New-HTMLReportWithSplit {
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
            New-HTML -Author 'Przemysław Kłys' -TitleText 'GPOZaurr Report' {
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