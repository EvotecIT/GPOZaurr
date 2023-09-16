function Get-GPOZaurrRedirect {
    <#
    .SYNOPSIS
    Command to detect if GPOs have correct path in SYSVOL, or someone changed it manually.

    .DESCRIPTION
    Command to detect if GPOs have correct path in SYSVOL, or someone changed it manually.

    .PARAMETER GPOName
    Provide GPO name to search for. By default command returns all GPOs

    .PARAMETER GPOGuid
    Provide GPO GUID to search for. By default command returns all GPOs

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER DateFrom
    Provide a date from which to start the search, by default the last X days are used

    .PARAMETER DateTo
    Provide a date to which to end the search, by default the last X days are used

    .PARAMETER DateRange
    Provide a date range to search for, by default the last X days are used

    .PARAMETER DateProperty
    Choose a date property. It can be WhenCreated or WhenChanged or both. By default whenCreated is used for comparison purposes

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .EXAMPLE
    Get-GPOZaurrRedirect | Format-Table

    .NOTES
    General notes
    #>
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
                    Write-Warning "Get-GPOZaurrRedirect - GPOGUID parameter is empty. Provide name and try again."
                    continue
                }
            } elseif ($PSCmdlet.ParameterSetName -eq 'GPOName') {
                if ($GPOName) {
                    $Splat = @{
                        Filter = "(objectClass -eq 'groupPolicyContainer') -and (DisplayName -eq '$GPOName')"
                        Server = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                    }
                } else {
                    Write-Warning "Get-GPOZaurrRedirect - GPOName parameter is empty. Provide name and try again."
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
                    Write-Warning -Message "Get-GPOZaurrRedirect - DateProperty parameter is empty. Provide name and try again."
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
                    Write-Warning -Message "Get-GPOZaurrRedirect - DateProperty parameter is empty. Provide name and try again."
                    continue
                }
            } else {
                # not needed
            }

            Write-Verbose -Message "Get-GPOZaurrRedirect - Searching domain $Domain with filter $($Splat['Filter'])"
            $Objects = Get-ADObject @Splat -Properties DisplayName, Name, Created, Modified, ntSecurityDescriptor, gPCFileSysPath, gPCFunctionalityVersion, gPCWQLFilter, gPCMachineExtensionNames, Description, CanonicalName, DistinguishedName
            foreach ($Object in $Objects) {
                $DomainCN = ConvertFrom-DistinguishedName -DistinguishedName $Object.DistinguishedName -ToDomainCN
                $GUID = $Object.Name -replace '{' -replace '}'
                if (($GUID).Length -ne 36) {
                    Write-Warning "Get-GPOZaurrRedirect - GPO GUID ($($($GUID.Replace("`n",' ')))) is incorrect. Skipping $($Object.DisplayName) / Domain: $($DomainCN)"
                } else {
                    $Path = $Object.gPCFileSysPath
                    $ExpectedPath = "\\$($DomainCN)\SYSVOL\$($DomainCN)\Policies\{$($GUID)}"
                    $Compare = if ($Path -eq $ExpectedPath) { $true } else { $false }
                    [PSCustomObject]@{
                        'DisplayName'                = $Object.DisplayName
                        'DomainName'                 = $DomainCN
                        'Description'                = $Object.Description
                        'IsCorrect'                  = $Compare
                        'GUID'                       = $GUID
                        'Path'                       = $Path
                        'ExpectedPath'               = $ExpectedPath
                        #$Output['FunctionalityVersion'] = $Object.gPCFunctionalityVersion
                        'Created'                    = $Object.Created
                        'Modified'                   = $Object.Modified
                        'Owner'                      = $Object.ntSecurityDescriptor.Owner
                        'GPOCanonicalName'           = $Object.CanonicalName
                        'GPODomainDistinguishedName' = ConvertFrom-DistinguishedName -DistinguishedName $Object.DistinguishedName -ToDC
                        'GPODistinguishedName'       = $Object.DistinguishedName
                    }
                }
            }
        }
    }
    End {

    }
}