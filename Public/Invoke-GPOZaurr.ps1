function Invoke-GPOZaurr {
    [alias('Show-GPOZaurr', 'Show-GPO')]
    [cmdletBinding()]
    param(
        [string] $FilePath,
        [string[]] $Type,
        [switch] $PassThru,
        [switch] $HideHTML
    )
    Reset-GPOZaurrStatus # This makes sure types are at it's proper status

    $Script:Reporting = [ordered] @{}
    $Script:Reporting['Version'] = Get-GitHubVersion -Cmdlet 'Invoke-GPOZaurr' -RepositoryOwner 'evotecit' -RepositoryName 'GPOZaurr'
    Write-Color '[i]', "[GPOZaurr] ", 'Version', ' [Informative] ', $Script:Reporting['Version'] -Color Yellow, DarkGray, Yellow, DarkGray, Magenta

    $Supported = [System.Collections.Generic.List[string]]::new()
    [Array] $NotSupported = foreach ($T in $Type) {
        if ($T -notin $Script:GPOConfiguration.Keys ) {
            $T
        } else {
            $Supported.Add($T)
        }
    }
    if ($Supported) {
        Write-Color '[i]', "[GPOZaurr] ", 'Supported types', ' [Informative] ', "Chosen by user: ", ($Supported -join ', ') -Color Yellow, DarkGray, Yellow, DarkGray, Yellow, Magenta
    }
    if ($NotSupported) {
        Write-Color '[i]', "[GPOZaurr] ", 'Not supported types', ' [Informative] ', "Following types are not supported: ", ($NotSupported -join ', ') -Color Yellow, DarkGray, Yellow, DarkGray, Yellow, Magenta
        Write-Color '[i]', "[GPOZaurr] ", 'Not supported types', ' [Informative] ', "Please use one/multiple from the list: ", ($Script:GPOConfiguration.Keys -join ', ') -Color Yellow, DarkGray, Yellow, DarkGray, Yellow, Magenta
        return
    }

    # Lets disable all current ones
    if ($Type) {
        foreach ($T in $Script:GPOConfiguration.Keys) {
            $Script:GPOConfiguration[$T].Enabled = $false
        }
        # Lets enable all requested ones
        foreach ($T in $Type) {
            $Script:GPOConfiguration[$T].Enabled = $true
        }
    }

    foreach ($T in $Script:GPOConfiguration.Keys) {
        if ($Script:GPOConfiguration[$T].Enabled -eq $true) {
            $TimeLogGPOList = Start-TimeLog
            Write-Color -Text '[i]', '[Start] ', $($Script:GPOConfiguration[$T]['Name']) -Color Yellow, DarkGray, Yellow
            $Script:GPOConfiguration[$T]['Data'] = & $Script:GPOConfiguration[$T]['Execute']
            & $Script:GPOConfiguration[$T]['Processing']

            $TimeEndGPOList = Stop-TimeLog -Time $TimeLogGPOList -Option OneLiner
            Write-Color -Text '[i]', '[End  ] ', $($Script:GPOConfiguration[$T]['Name']), " [Time to execute: $TimeEndGPOList]" -Color Yellow, DarkGray, Yellow, DarkGray
        }
    }

    # Generate pretty HTML
    $TimeLogHTML = Start-TimeLog
    Write-Color -Text '[i]', '[HTML ] ', 'Generating HTML report' -Color Yellow, DarkGray, Yellow
    New-HTML -Author 'Przemysław Kłys' -TitleText 'GPOZaurr Report' {
        New-HTMLTabStyle -BorderRadius 0px -TextTransform capitalize -BackgroundColorActive SlateGrey
        New-HTMLSectionStyle -BorderRadius 0px -HeaderBackGroundColor Grey -RemoveShadow
        New-HTMLPanelStyle -BorderRadius 0px
        New-HTMLTableOption -DataStore JavaScript -BoolAsString

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
                    & $Script:GPOConfiguration[$T]['Solution']
                }
            }
        } else {
            foreach ($T in $Script:GPOConfiguration.Keys) {
                if ($Script:GPOConfiguration[$T].Enabled -eq $true) {
                    New-HTMLTab -Name $Script:GPOConfiguration[$T]['Name'] {
                        & $Script:GPOConfiguration[$T]['Solution']
                    }
                }
            }
        }
    } -Online -ShowHTML:(-not $HideHTML) -FilePath $FilePath
    $TimeLogEndHTML = Stop-TimeLog -Time $TimeLogHTML -Option OneLiner
    Write-Color -Text '[i]', '[HTML ] ', 'Generating HTML report', " [Time to execute: $TimeLogEndHTML]" -Color Yellow, DarkGray, Yellow, DarkGray
    if ($PassThru) {
        $OutputData = Export-GPOZaurr
        $OutputData
    }
    Reset-GPOZaurrStatus # This makes sure types are at it's proper status

}

[scriptblock] $SourcesAutoCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $Script:GPOConfiguration.Keys | Sort-Object | Where-Object { $_ -like "*$wordToComplete*" }
}

Register-ArgumentCompleter -CommandName Invoke-GPOZaurr -ParameterName Type -ScriptBlock $SourcesAutoCompleter