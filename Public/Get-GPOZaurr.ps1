function Get-GPOZaurr {
    [cmdletBinding()]
    param(
        [scriptblock] $ExcludeGroupPolicies,
        [string] $GPOName,
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [validateset('Empty', 'Unlinked', 'Disabled', 'NoApplyPermission', 'All')][string[]] $Type,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath,

        [switch] $PermissionsOnly,
        [switch] $OwnerOnly,
        [switch] $Limited,
        [switch] $ReturnObject,
        [System.Collections.IDictionary] $ADAdministrativeGroups
    )
    Begin {
        if (-not $ADAdministrativeGroups) {
            Write-Verbose "Get-GPOZaurr - Getting ADAdministrativeGroups"
            $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        }
        if (-not $GPOPath) {
            $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        }
        $ExcludeGPO = [ordered] @{}
        if ($ExcludeGroupPolicies) {
            $ExExecution = Invoke-Command -ScriptBlock $ExcludeGroupPolicies
            foreach ($GroupPolicy in $ExExecution) {
                if ($GroupPolicy -is [string]) {
                    $ExcludeGPO[$GroupPolicy] = $true
                } elseif ($GroupPolicy.Name -and $GroupPolicy.DomainName) {
                    $PolicyName = -join ($GroupPolicy.DomainName, $GroupPolicy.Name)
                    $ExcludeGPO[$PolicyName] = $true
                } elseif ($GroupPolicy.Name) {
                    $ExcludeGPO[$GroupPolicy.Name] = $true
                } else {
                    Write-Warning "Get-GPOZaurr - Exclusion takes only Group Policy Name as string, or as hashtable with domain name @{ Name = 'Group Policy Name'; DomainName = 'Domain' }."
                    continue
                }
            }
        }
        if ($OwnerOnly -or $PermissionsOnly -and $Type) {
            Write-Warning "Get-GPOZaurr - Using PermissionOnly or OwnerOnly with Type is not supported. "
        }
    }
    Process {
        if (-not $GPOPath) {
            foreach ($Domain in $ForestInformation.Domains) {
                $QueryServer = $ForestInformation.QueryServers[$Domain]['HostName'][0]
                $Count = 0
                if ($GPOName) {
                    $GroupPolicies = Get-GPO -Name $GPOName -Domain $Domain -Server $QueryServer -ErrorAction SilentlyContinue
                    $GroupPolicies | ForEach-Object {
                        $Count++
                        #Write-Verbose "Get-GPOZaurr - Getting GPO $($_.DisplayName) / ID: $($_.ID) from $Domain"
                        Write-Verbose "Get-GPOZaurr - Processing [$($_.DomainName)]($Count/$($GroupPolicies.Count)) $($_.DisplayName)"
                        if (-not $Limited) {
                            try {
                                $XMLContent = Get-GPOReport -ID $_.ID -ReportType XML -Server $ForestInformation.QueryServers[$Domain].HostName[0] -Domain $Domain -ErrorAction Stop
                            } catch {
                                Write-Warning "Get-GPOZaurr - Failed to get GPOReport: $($_.Exception.Message). Skipping."
                                continue
                            }
                            Get-XMLGPO -OwnerOnly:$OwnerOnly.IsPresent -XMLContent $XMLContent -GPO $_ -PermissionsOnly:$PermissionsOnly.IsPresent -ADAdministrativeGroups $ADAdministrativeGroups -ReturnObject:$ReturnObject.IsPresent -ExcludeGroupPolicies $ExcludeGPO -Type $Type
                        } else {
                            $_
                        }
                    }
                } elseif ($GPOGuid) {
                    $GroupPolicies = Get-GPO -Guid $GPOGuid -Domain $Domain -Server $QueryServer -ErrorAction SilentlyContinue
                    $GroupPolicies | ForEach-Object {
                        $Count++
                        #Write-Verbose "Get-GPOZaurr - Getting GPO $($_.DisplayName) / ID: $($_.ID) from $Domain"
                        Write-Verbose "Get-GPOZaurr - Processing [$($_.DomainName)]($Count/$($GroupPolicies.Count)) $($_.DisplayName)"
                        if (-not $Limited) {
                            try {
                                $XMLContent = Get-GPOReport -ID $_.ID -ReportType XML -Server $ForestInformation.QueryServers[$Domain].HostName[0] -Domain $Domain -ErrorAction Stop
                            } catch {
                                Write-Warning "Get-GPOZaurr - Failed to get GPOReport: $($_.Exception.Message). Skipping."
                                continue
                            }
                            Get-XMLGPO -OwnerOnly:$OwnerOnly.IsPresent -XMLContent $XMLContent -GPO $_ -PermissionsOnly:$PermissionsOnly.IsPresent -ADAdministrativeGroups $ADAdministrativeGroups -ReturnObject:$ReturnObject.IsPresent -ExcludeGroupPolicies $ExcludeGPO -Type $Type
                        } else {
                            $_
                        }
                    }
                } else {
                    $GroupPolicies = Get-GPO -All -Server $QueryServer -Domain $Domain -ErrorAction SilentlyContinue
                    $GroupPolicies | ForEach-Object {
                        $Count++
                        #Write-Verbose "Get-GPOZaurr - Getting GPO $($_.DisplayName) / ID: $($_.ID) from $Domain"
                        Write-Verbose "Get-GPOZaurr - Processing [$($_.DomainName)]($Count/$($GroupPolicies.Count)) $($_.DisplayName)"
                        if (-not $Limited) {
                            try {
                                $XMLContent = Get-GPOReport -ID $_.ID -ReportType XML -Server $ForestInformation.QueryServers[$Domain].HostName[0] -Domain $Domain -ErrorAction Stop
                            } catch {
                                Write-Warning "Get-GPOZaurr - Failed to get GPOReport: $($_.Exception.Message). Skipping."
                                continue
                            }
                            Get-XMLGPO -OwnerOnly:$OwnerOnly.IsPresent -XMLContent $XMLContent -GPO $_ -PermissionsOnly:$PermissionsOnly.IsPresent -ADAdministrativeGroups $ADAdministrativeGroups -ReturnObject:$ReturnObject.IsPresent -ExcludeGroupPolicies $ExcludeGPO -Type $Type
                        } else {
                            $_
                        }
                    }
                }
            }
        } else {
            foreach ($Path in $GPOPath) {
                Write-Verbose "Get-GPOZaurr - Getting GPO content from XML files"
                Get-ChildItem -LiteralPath $Path -Recurse -Filter *.xml | ForEach-Object {
                    $XMLContent = [XML]::new()
                    $XMLContent.Load($_.FullName)
                    Get-XMLGPO -OwnerOnly:$OwnerOnly.IsPresent -XMLContent $XMLContent -PermissionsOnly:$PermissionsOnly.IsPresent -ExcludeGroupPolicies $ExcludeGPO -Type $Type
                }
                Write-Verbose "Get-GPOZaurr - Finished GPO content from XML files"
            }
        }
    }
    End {

    }
}