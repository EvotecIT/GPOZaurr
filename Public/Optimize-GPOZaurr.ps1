function Optimize-GPOZaurr {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 1)][scriptblock] $ExcludeGroupPolicies,
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
        Get-GPOZaurr -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -ExcludeGroupPolicies $ExcludeGroupPolicies | ForEach-Object {
            $GPO = $_
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