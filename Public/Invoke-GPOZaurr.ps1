function Invoke-GPOZaurr {
    <#
    .SYNOPSIS
    Single cmdlet that provides 360 degree overview of Group Policies in Active Directory Forest.

    .DESCRIPTION
    Single cmdlet that provides 360 degree overview of Group Policies in Active Directory Forest with ability to pick reports and export to HTML.

    .PARAMETER Exclusions
    Allows to mark as excluded some Group Policies or Organizational Units depending on type.
    Can be a scriptblock or array depending on supported way by underlying report.
    Not every report support exclusions.
    Not every report support exclusions the same way.
    Exclusions should be used only if there is single report being asked for.

    .PARAMETER FilePath
    Path to the file where the report will be saved.

    .PARAMETER Type
    Type of report to be generated from a list of available reports.

    .PARAMETER PassThru
    Returns created objects after the report is done

    .PARAMETER HideHTML
    Do not auto open HTML report in default browser

    .PARAMETER HideSteps
    Do not show steps in report

    .PARAMETER ShowError
    Show errors in HTML report. Useful in case the report is being run as Scheduled Task

    .PARAMETER ShowWarning
    Show warnings in HTML report. Useful in case the report is being run as Scheduled Task

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER Online
    Forces report to use online resources in HTML (using CDN most of the time), by default it is run offline, and inlines all CSS/JS code.

    .PARAMETER SplitReports
    Split report into multiple files, one for each report. This can be useful for large domains with huge reports.

    .EXAMPLE
    Invoke-GPOZaurr

    .EXAMPLE
    Invoke-GPOZaurr -Type GPOOrganizationalUnit -Online -FilePath $PSScriptRoot\Reports\GPOZaurrOU.html -Exclusions @(
        '*OU=Production,DC=ad,DC=evotec,DC=pl'
    )

    .NOTES
    General notes
    #>
    [alias('Show-GPOZaurr', 'Show-GPO')]
    [cmdletBinding()]
    param(
        [alias('ExcludeGroupPolicies', 'ExclusionsCode')][Parameter(Position = 1)][object] $Exclusions,
        [string] $FilePath,
        [Parameter(Position = 0)][string[]] $Type,
        [switch] $PassThru,
        [switch] $HideHTML,
        [switch] $HideSteps,
        [switch] $ShowError,
        [switch] $ShowWarning,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [switch] $Online,
        [switch] $SplitReports
    )
    Reset-GPOZaurrStatus # This makes sure types are at it's proper status

    $Script:Reporting = [ordered] @{}
    $Script:Reporting['Version'] = Get-GitHubVersion -Cmdlet 'Invoke-GPOZaurr' -RepositoryOwner 'evotecit' -RepositoryName 'GPOZaurr'
    $Script:Reporting['Settings'] = @{
        ShowError   = $ShowError.IsPresent
        ShowWarning = $ShowWarning.IsPresent
        HideSteps   = $HideSteps.IsPresent
    }
    Write-Color '[i]', "[GPOZaurr] ", 'Version', ' [Informative] ', $Script:Reporting['Version'] -Color Yellow, DarkGray, Yellow, DarkGray, Magenta

    # Verify requested types are supported
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
    $DisplayForest = if ($Forest) { $Forest } else { 'Not defined. Using current one' }
    $DisplayIncludedDomains = if ($IncludeDomains) { $IncludeDomains -join "," } else { 'Not defined. Using all domains of forest' }
    $DisplayExcludedDomains = if ($ExcludeDomains) { $ExcludeDomains -join ',' } else { 'No exclusions provided' }
    Write-Color '[i]', "[GPOZaurr] ", 'Domain Information', ' [Informative] ', "Forest: ", $DisplayForest -Color Yellow, DarkGray, Yellow, DarkGray, Yellow, Magenta
    Write-Color '[i]', "[GPOZaurr] ", 'Domain Information', ' [Informative] ', "Included Domains: ", $DisplayIncludedDomains -Color Yellow, DarkGray, Yellow, DarkGray, Yellow, Magenta
    Write-Color '[i]', "[GPOZaurr] ", 'Domain Information', ' [Informative] ', "Excluded Domains: ", $DisplayExcludedDomains -Color Yellow, DarkGray, Yellow, DarkGray, Yellow, Magenta

    # Lets make sure we only enable those types which are requestd by user
    if ($Type) {
        foreach ($T in $Script:GPOConfiguration.Keys) {
            $Script:GPOConfiguration[$T].Enabled = $false
        }
        # Lets enable all requested ones
        foreach ($T in $Type) {
            $Script:GPOConfiguration[$T].Enabled = $true
        }
    }

    # Build data
    foreach ($T in $Script:GPOConfiguration.Keys) {
        if ($Script:GPOConfiguration[$T].Enabled -eq $true) {
            $Script:Reporting[$T] = [ordered] @{
                Name              = $Script:GPOConfiguration[$T].Name
                ActionRequired    = $null
                Data              = $null
                Exclusions        = $null
                WarningsAndErrors = $null
                Time              = $null
                Summary           = $null
                Variables         = Copy-Dictionary -Dictionary $Script:GPOConfiguration[$T]['Variables']
            }
            if ($Exclusions) {
                if ($Exclusions -is [scriptblock]) {
                    $Script:Reporting[$T]['Exclusions'] = $Exclusions
                    #$Script:Reporting[$T]['ExclusionsCode'] = $Exclusions
                }
                if ($Exclusions -is [Array]) {
                    $Script:Reporting[$T]['Exclusions'] = $Exclusions
                }
            }

            $TimeLogGPOList = Start-TimeLog
            Write-Color -Text '[i]', '[Start] ', $($Script:GPOConfiguration[$T]['Name']) -Color Yellow, DarkGray, Yellow
            $OutputCommand = Invoke-Command -ScriptBlock $Script:GPOConfiguration[$T]['Execute'] -WarningVariable CommandWarnings -ErrorVariable CommandErrors -ArgumentList $Forest, $ExcludeDomains, $IncludeDomains
            if ($OutputCommand -is [System.Collections.IDictionary]) {
                # in some cases the return will be wrapped in Hashtable/orderedDictionary and we need to handle this without an array
                $Script:Reporting[$T]['Data'] = $OutputCommand
            } else {
                # since sometimes it can be 0 or 1 objects being returned we force it being an array
                $Script:Reporting[$T]['Data'] = [Array] $OutputCommand
            }
            Invoke-Command -ScriptBlock $Script:GPOConfiguration[$T]['Processing']
            $Script:Reporting[$T]['WarningsAndErrors'] = @(
                if ($ShowWarning) {
                    foreach ($War in $CommandWarnings) {
                        [PSCustomObject] @{
                            Type       = 'Warning'
                            Comment    = $War
                            Reason     = ''
                            TargetName = ''
                        }
                    }
                }
                if ($ShowError) {
                    foreach ($Err in $CommandErrors) {
                        [PSCustomObject] @{
                            Type       = 'Error'
                            Comment    = $Err
                            Reason     = $Err.CategoryInfo.Reason
                            TargetName = $Err.CategoryInfo.TargetName
                        }
                    }
                }
            )
            #if ($Script:GPOConfiguration[$T]['Summary']) {
            #    $Script:Reporting[$T]['Summary'] = Invoke-Command -ScriptBlock $Script:GPOConfiguration[$T]['Summary']
            #}
            $TimeEndGPOList = Stop-TimeLog -Time $TimeLogGPOList -Option OneLiner
            $Script:Reporting[$T]['Time'] = $TimeEndGPOList
            Write-Color -Text '[i]', '[End  ] ', $($Script:GPOConfiguration[$T]['Name']), " [Time to execute: $TimeEndGPOList]" -Color Yellow, DarkGray, Yellow, DarkGray

            if ($SplitReports) {
                $TimeLogHTML = Start-TimeLog
                New-HTMLReportWithSplit -FilePath $FilePath -Online:$Online -HideHTML:$HideHTML -CurrentReport $T
                $TimeLogEndHTML = Stop-TimeLog -Time $TimeLogHTML -Option OneLiner
                Write-Color -Text '[i]', '[HTML ] ', 'Generating HTML report', " [Time to execute: $TimeLogEndHTML]" -Color Yellow, DarkGray, Yellow, DarkGray
            }
        }
    }

    if (-not $SplitReports) {
        # Generate pretty HTML
        $TimeLogHTML = Start-TimeLog
        if (-not $FilePath) {
            $FilePath = Get-FileName -Extension 'html' -Temporary
        }

        New-HTMLReportAll -FilePath $FilePath -Online:$Online -HideHTML:$HideHTML -Type $Type

        $TimeLogEndHTML = Stop-TimeLog -Time $TimeLogHTML -Option OneLiner
        Write-Color -Text '[i]', '[HTML ] ', 'Generating HTML report', " [Time to execute: $TimeLogEndHTML]" -Color Yellow, DarkGray, Yellow, DarkGray
    }
    if ($PassThru) {
        $Script:Reporting
    }
    Reset-GPOZaurrStatus # This makes sure types are at it's proper status

}

[scriptblock] $SourcesAutoCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $Script:GPOConfiguration.Keys | Sort-Object | Where-Object { $_ -like "*$wordToComplete*" }
}

Register-ArgumentCompleter -CommandName Invoke-GPOZaurr -ParameterName Type -ScriptBlock $SourcesAutoCompleter