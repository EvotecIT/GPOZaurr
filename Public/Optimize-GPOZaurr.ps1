function Optimize-GPOZaurr {
    <#
    .SYNOPSIS
    Enables or disables user/computer section of group policy based on it's content.

    .DESCRIPTION
    Long description

    .PARAMETER ExcludeGroupPolicies
    Provide a list of group policies to skip using Skip-GroupPolicy cmdlet

    .PARAMETER LimitProcessing
    Allows to specify maximum number of items that will be fixed in a single run. It doesn't affect amount of GPOs processed

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .EXAMPLE
    Optimize-GPOZaurr -All -WhatIf -Verbose -LimitProcessing 2

    .EXAMPLE
    Optimize-GPOZaurr -All -WhatIf -Verbose -LimitProcessing 2 {
        Skip-GroupPolicy -Name 'TEST | Drive Mapping 1'
        Skip-GroupPolicy -Name 'TEST | Drive Mapping 2'
    }
    .NOTES
    General notes
    #>
    [cmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'GPOName')]
    param(
        [Parameter(Position = 1)][scriptblock] $ExcludeGroupPolicies,
        [alias('Name', 'DisplayName')][Parameter(ParameterSetName = 'GPOName', Mandatory)][string] $GPOName,
        [Parameter(ParameterSetName = 'GPOGUID', Mandatory)][alias('GUID', 'GPOID')][string] $GPOGuid,
        [Parameter(ParameterSetName = 'All', Mandatory)][switch] $All,
        [int] $LimitProcessing,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Begin {
        $Count = 0
    }
    Process {
        $getGPOZaurrSplat = @{
            GpoName                   = $GPOName
            GPOGUID                   = $GPOGuid
            Forest                    = $Forest
            IncludeDomains            = $IncludeDomains
            ExcludeDomains            = $ExcludeDomains
            ExtendedForestInformation = $ExtendedForestInformation
            ExcludeGroupPolicies      = $ExcludeGroupPolicies
        }
        Remove-EmptyValue -Hashtable $getGPOZaurrSplat

        Get-GPOZaurr @getGPOZaurrSplat | ForEach-Object {
            $GPO = $_
            if (-not $GPO.Exclude) {
                if ($GPO.Optimized -eq $false -and $GPO.Problem -eq $false) {
                    if ($GPO.Empty) {
                        Write-Verbose "Optimize-GPOZaurr - GPO ($($GPO.DisplayName)) / $($GPO.DomainName)) is not optimized, but GPO is empty, so leaving as is."
                    } else {
                        if ($GPO.UserSettingsAvailable -and $GPO.ComputerSettingsAvailable) {
                            Write-Verbose "Optimize-GPOZaurr - "
                            if ($PSCmdlet.ShouldProcess($GPO.DisplayName, "Enabling computer and user settings in domain $($GPO.DomainName)")) {
                                try {
                                    $GPO.GPOObject.GpoStatus = [Microsoft.GroupPolicy.GpoStatus]::AllSettingsEnabled
                                } catch {
                                    Write-Warning -Message "Optimize-GPOZaurr - Couldn't set $($GPO.DisplayName) / $($GPO.DomainName) to $Status. Error $($_.Exception.Message)"
                                }
                            }
                        } elseif ($GPO.UserSettingsAvailable) {
                            if ($PSCmdlet.ShouldProcess($GPO.DisplayName, "Disabling computer setings in domain $($GPO.DomainName)")) {
                                try {
                                    $GPO.GPOObject.GpoStatus = [Microsoft.GroupPolicy.GpoStatus]::ComputerSettingsDisabled
                                } catch {
                                    Write-Warning -Message "Optimize-GPOZaurr - Couldn't set $($GPO.DisplayName) / $($GPO.DomainName) to $Status. Error $($_.Exception.Message)"
                                }
                            }
                        } elseif ($GPO.ComputerSettingsAvailable) {
                            if ($PSCmdlet.ShouldProcess($GPO.DisplayName, "Disabling user setings in domain $($GPO.DomainName)")) {
                                try {
                                    $GPO.GPOObject.GpoStatus = [Microsoft.GroupPolicy.GpoStatus]::UserSettingsDisabled
                                } catch {
                                    Write-Warning -Message "Optimize-GPOZaurr - Couldn't set $($GPO.DisplayName) / $($GPO.DomainName) to $Status. Error $($_.Exception.Message)"
                                }
                            }
                        }
                    }

                    $Count++
                    if ($LimitProcessing -eq $Count) {
                        break
                    }
                } elseif ($GPO.Optimized -eq $false) {
                    Write-Warning "Optimize-GPOZaurr - GPO ($($GPO.DisplayName)) / $($GPO.DomainName)) is not optimized, but GPO is marked as one with problem. Skipping."
                }
            }
            <#
        if ($GPO.UserSettingsAvailable -eq $false -and $GPO.ComputerSettingsAvailable -eq $false) {
            if ($GPO.Enabled -ne 'All setttings disabled') {
                # $GPO
            }
        } elseif ($GPO.UserSettingsAvailable -eq $false) {

        } elseif ($GPO.ComputerSettingsAvailable -eq $false) {

        }
        #>
        }
    }
}