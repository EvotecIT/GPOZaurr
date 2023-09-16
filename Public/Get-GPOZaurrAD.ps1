function Get-GPOZaurrAD {
    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'GPOName')]
        [string] $GPOName,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,

        [DateTime] $DateFrom,
        [DateTime] $DateTo,
        [ValidateSet('PastHour', 'CurrentHour', 'PastDay', 'CurrentDay', 'PastMonth', 'CurrentMonth', 'PastQuarter', 'CurrentQuarter', 'Last14Days', 'Last21Days', 'Last30Days', 'Last7Days', 'Last3Days', 'Last1Days')][string] $DateRange,
        [ValidateSet('WhenCreated', 'WhenChanged')][string[]] $DateProperty = 'WhenCreated',
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Begin {
        $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    }
    Process {
        foreach ($Domain in $ForestInformation.Domains) {
            if ($PSCmdlet.ParameterSetName -eq 'GPOGUID') {
                if ($GPOGuid) {
                    if ($GPOGUID -notlike '*{*') {
                        $GUID = -join ("{", $GPOGUID, '}')
                    } else {
                        $GUID = $GPOGUID
                    }
                    $Splat = @{
                        Filter = "(objectClass -eq 'groupPolicyContainer') -and (Name -eq '$GUID')"
                        Server = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                    }
                } else {
                    Write-Warning "Get-GPOZaurrAD - GPOGUID parameter is empty. Provide name and try again."
                    continue
                }
            } elseif ($PSCmdlet.ParameterSetName -eq 'GPOName') {
                if ($GPOName) {
                    $Splat = @{
                        Filter = "(objectClass -eq 'groupPolicyContainer') -and (DisplayName -eq '$GPOName')"
                        Server = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                    }
                } else {
                    Write-Warning "Get-GPOZaurrAD - GPOName parameter is empty. Provide name and try again."
                    continue
                }
            } else {
                $Splat = @{
                    Filter = "(objectClass -eq 'groupPolicyContainer')"
                    Server = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                }
            }
            # allows to only get GPOs from a specific date range
            if ($PSBoundParameters.ContainsKey('DateRange')) {
                $Dates = Get-ChoosenDates -DateRange $DateRange
                $DateFrom = $($Dates.DateFrom)
                $DateTo = $($Dates.DateTo)

                if ($DateProperty -contains 'WhenChanged' -and $DateProperty -contains 'WhenCreated') {
                    $Splat['Filter'] = -join ($Splat['Filter'], ' -and ((WhenChanged -ge $DateFrom -and WhenChanged -le $DateTo) -or (WhenCreated -ge $DateFrom -and WhenCreated -le $DateTo))')
                } elseif ($DateProperty -eq 'WhenChanged' -or $DateProperty -eq 'WhenCreated') {
                    $Property = $DateProperty[0]
                    $Splat['Filter'] = -join ($Splat['Filter'], ' -and ($Property -ge $DateFrom -and $Property -le $DateTo)')
                } else {
                    Write-Warning -Message "Get-GPOZaurrAD - DateProperty parameter is empty. Provide name and try again."
                    continue
                }
            } elseif ($PSBoundParameters.ContainsKey('DateFrom') -and $PSBoundParameters.ContainsKey('DateTo')) {
                # already set $DateFrom,DateTo
                #$Splat['Filter'] = -join ($Splat['Filter'], '-and ($DateProperty -ge $DateFrom -and $DateProperty -le $DateTo)')
                if ($DateProperty -contains 'WhenChanged' -and $DateProperty -contains 'WhenCreated') {
                    $Splat['Filter'] = -join ($Splat['Filter'], ' -and ((WhenChanged -ge $DateFrom -and WhenChanged -le $DateTo) -or (WhenCreated -ge $DateFrom -and WhenCreated -le $DateTo))')
                } elseif ($DateProperty -eq 'WhenChanged' -or $DateProperty -eq 'WhenCreated') {
                    $Property = $DateProperty[0]
                    $Splat['Filter'] = -join ($Splat['Filter'], ' -and ($Property -ge $DateFrom -and $Property -le $DateTo)')
                } else {
                    Write-Warning -Message "Get-GPOZaurrAD - DateProperty parameter is empty. Provide name and try again."
                    continue
                }
            } else {
                # not needed
            }

            Write-Verbose -Message "Get-GPOZaurrAD - Searching domain $Domain with filter $($Splat['Filter'])"
            Get-ADObject @Splat -Properties DisplayName, Name, Created, Modified, ntSecurityDescriptor, gPCFileSysPath, gPCFunctionalityVersion, gPCWQLFilter, gPCMachineExtensionNames, Description, CanonicalName, DistinguishedName | ForEach-Object -Process {
                $DomainCN = ConvertFrom-DistinguishedName -DistinguishedName $_.DistinguishedName -ToDomainCN
                $GUID = $_.Name -replace '{' -replace '}'
                if (($GUID).Length -ne 36) {
                    Write-Warning "Get-GPOZaurrAD - GPO GUID ($($($GUID.Replace("`n",' ')))) is incorrect. Skipping $($_.DisplayName) / Domain: $($DomainCN)"
                } else {
                    [PSCustomObject]@{
                        'DisplayName'                = $_.DisplayName
                        'DomainName'                 = $DomainCN
                        'Description'                = $_.Description
                        'GUID'                       = $GUID
                        'Path'                       = $_.gPCFileSysPath
                        #$Output['FunctionalityVersion'] = $_.gPCFunctionalityVersion
                        'Created'                    = $_.Created
                        'Modified'                   = $_.Modified
                        'Owner'                      = $_.ntSecurityDescriptor.Owner
                        'GPOCanonicalName'           = $_.CanonicalName
                        'GPODomainDistinguishedName' = ConvertFrom-DistinguishedName -DistinguishedName $_.DistinguishedName -ToDC
                        'GPODistinguishedName'       = $_.DistinguishedName
                    }
                }
            }
        }
    }
    End {

    }
}