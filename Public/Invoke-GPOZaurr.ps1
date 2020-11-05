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

    <#
    # Gather data
    $TimeLog = Start-TimeLog
    if ($Type -contains 'GPOOrphans' -or $null -eq $Type) {
        #Write-Color -Text "[Info] ", "Processing GPOOrphans" -Color Yellow, White
        Write-Verbose -Message "Invoke-GPOZaurr - Processing GPO Sysvol"
        $GPOOrphans = Get-GPOZaurrBroken

        $NotAvailableInAD = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NotAvailableOnSysvol = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NotAvailablePermissionIssue = [System.Collections.Generic.List[PSCustomObject]]::new()
        foreach ($_ in $GPOOrphans) {
            if ($_.Status -eq 'Not available in AD') {
                $NotAvailableInAD.Add($NotAvailableInAD)
            } elseif ($_.Status -eq 'Not available on SYSVOL') {
                $NotAvailableOnSysvol.Add($NotAvailableInAD)
            } elseif ( $_.Status -eq 'Permissions issue') {
                $NotAvailablePermissionIssue.Add($NotAvailableInAD)
            }
        }
    }
    if ($Type -contains 'GPOPermissions' -or $null -eq $Type) {
        #Write-Color -Text "[Info] ", "Processing GPOPermissions" -Color Yellow, White
        Write-Verbose -Message "Invoke-GPOZaurr - Processing GPO Permissions"
        $GPOPermissions = Get-GPOZaurrPermission -Type All -IncludePermissionType GpoEditDeleteModifySecurity, GpoEdit, GpoCustom -IncludeOwner
    }
    if ($Type -contains 'GPOPermissionsRoot' -or $null -eq $Type) {
        Write-Verbose -Message "Invoke-GPOZaurr - Processing GPO Permissions Root"
        $GPOPermissionsRoot = Get-GPOZaurrPermissionRoot -SkipNames
    }
    if ($Type -contains 'NetLogon' -or $null -eq $Type) {
        $TimeLogSection = Start-TimeLog
        Write-Verbose "Get-GPOZaurrNetLogon - Processing NETLOGON Share"
        $NetLogon = Get-GPOZaurrNetLogon
        $NetLogonOwners = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersAdministrators = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersNotAdministrative = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersAdministrative = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersAdministrativeNotAdministrators = [System.Collections.Generic.List[PSCustomObject]]::new()
        $NetLogonOwnersToFix = [System.Collections.Generic.List[PSCustomObject]]::new()
        foreach ($File in $Netlogon) {
            if ($File.FileSystemRights -eq 'Owner') {
                $NetLogonOwners.Add($File)

                if ($File.PrincipalType -eq 'WellKnownAdministrative') {
                    $NetLogonOwnersAdministrative.Add($File)
                } elseif ($File.PrincipalType -eq 'Administrative') {
                    $NetLogonOwnersAdministrative.Add($File)
                } else {
                    $NetLogonOwnersNotAdministrative.Add($File)
                }

                if ($File.PrincipalSid -eq 'S-1-5-32-544') {
                    $NetLogonOwnersAdministrators.Add($File)
                } elseif ($File.PrincipalType -in 'WellKnownAdministrative', 'Administrative') {
                    $NetLogonOwnersAdministrativeNotAdministrators.Add($File)
                    $NetLogonOwnersToFix.Add($File)
                } else {
                    $NetLogonOwnersToFix.Add($File)
                }
            }
        }
        $TimeLogSectionEnd = Stop-TimeLog -Time $TimeLogSection -Option OneLiner
        Write-Verbose "Get-GPOZaurrNetLogon - Processing NETLOGON Share $TimeLogSectionEnd"
    }
    if ($Type -contains 'GPOAnalysis' -or $null -eq $Type) {
        Write-Verbose "Invoke-GPOZaurr - Processing GPO Analysis"
        $GPOContent = Invoke-GPOZaurrContent
    }
    if ($Type -contains 'GPOFiles') {
        Write-Verbose "Invoke-GPOZaurr - Processing GPOFiles"
        $GPOFiles = Get-GPOZaurrFiles
    }
    if ($Type -contains 'LegacyADM') {
        Write-Verbose "Invoke-GPOZaurr - Processing GPOFiles"
        $ADMLegacyFiles = Get-GPOZaurrLegacyFiles
    }
    $TimeEnd = Stop-TimeLog -Time $TimeLog -Option OneLiner
    Write-Verbose "Invoke-GPOZaurr - Data gathering time $TimeEnd"
    #>
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

        }
    } -Online -ShowHTML -FilePath $FilePath


    Reset-GPOZaurrStatus # This makes sure types are at it's proper status
}

[scriptblock] $SourcesAutoCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $Script:GPOConfiguration.Keys | Sort-Object | Where-Object { $_ -like "*$wordToComplete*" }
}

Register-ArgumentCompleter -CommandName Invoke-GPOZaurr -ParameterName Type -ScriptBlock $SourcesAutoCompleter