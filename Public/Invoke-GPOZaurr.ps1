function Invoke-GPOZaurr {
    [alias('Show-GPOZaurr', 'Show-GPO')]
    [cmdletBinding()]
    param(
        [string] $FilePath,
        [string[]] $Type
        <#
        [ValidateSet(
            'GPOList', 'GPOOrphans', 'GPOPermissions', 'GPOPermissionsRoot', 'GPOFiles',
            'GPOConsistency', 'GPOOwners', 'GPOAnalysis',
            'NetLogon',
            'LegacyAdm'
        )][string[]] $Type
        #>
    )
    Reset-GPOZaurrStatus # This makes sure types are at it's proper status

    $Script:Reporting = [ordered] @{}
    # Provide version check for easy use
    $GPOZaurrVersion = Get-Command -Name 'Invoke-GPOZaurr' -ErrorAction SilentlyContinue

    [Array] $GitHubReleases = (Get-GitHubLatestRelease -Url "https://api.github.com/repos/evotecit/GpoZaurr/releases" -Verbose:$false)

    $LatestVersion = $GitHubReleases[0]
    if (-not $LatestVersion.Errors) {
        if ($GPOZaurrVersion.Version -eq $LatestVersion.Version) {
            $Script:Reporting['Version'] = "GPOZaurr Current/Latest: $($LatestVersion.Version) at $($LatestVersion.PublishDate)"
        } elseif ($GPOZaurrVersion.Version -lt $LatestVersion.Version) {
            $Script:Reporting['Version'] = "GPOZaurr Current: $($GPOZaurrVersion.Version), Published: $($LatestVersion.Version) at $($LatestVersion.PublishDate). Update?"
        } elseif ($GPOZaurrVersion.Version -gt $LatestVersion.Version) {
            $Script:Reporting['Version'] = "GPOZaurr Current: $($GPOZaurrVersion.Version), Published: $($LatestVersion.Version) at $($LatestVersion.PublishDate). Lucky you!"
        }
    } else {
        $Script:Reporting['Version'] = "GPOZaurr Current: $($GPOZaurrVersion.Version)"
    }

    # Lets disable all current ones
    foreach ($T in $Script:GPOConfiguration.Keys) {
        $Script:GPOConfiguration[$T].Enabled = $false
    }
    # Lets enable all requested ones
    foreach ($T in $Type) {
        $Script:GPOConfiguration[$T].Enabled = $true
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
    Write-Verbose "Invoke-GPOZaurr - Generating HTML"
    New-HTML {
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
                    New-HTMLText -Text $Script:Reporting['Version'] -Color Blue
                } -JustifyContent flex-end -Invisible
            }
        }

        if ($Type.Count -eq 1) {
            foreach ($T in $Script:GPOConfiguration.Keys) {
                if ($Script:GPOConfiguration[$T].Enabled -eq $true) {
                    if ($Script:GPOConfiguration[$T]['Data']) {
                        & $Script:GPOConfiguration[$T]['Solution']
                    }
                }
            }
        } else {
            foreach ($T in $Script:GPOConfiguration.Keys) {
                if ($Script:GPOConfiguration[$T].Enabled -eq $true) {
                    New-HTMLTab -Name $T {
                        if ($Script:GPOConfiguration[$T]['Data']) {
                            & $Script:GPOConfiguration[$T]['Solution']
                        }
                    }
                }
            }
        }
    } -Online -ShowHTML -FilePath $FilePath
    Reset-GPOZaurrStatus # This makes sure types are at it's proper status
}

[scriptblock] $SourcesAutoCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $Script:GPOConfiguration.Keys | Sort-Object | Where-Object { $_ -like "*$wordToComplete*" }
}

Register-ArgumentCompleter -CommandName Invoke-GPOZaurr -ParameterName Type -ScriptBlock $SourcesAutoCompleter