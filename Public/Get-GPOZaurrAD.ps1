function Get-GPOZaurrAD {
    <#
    .SYNOPSIS
    Retrieves Group Policy Objects (GPOs) information from Active Directory.

    .DESCRIPTION
    This function retrieves information about Group Policy Objects (GPOs) from Active Directory based on specified criteria such as GPO name, GPO GUID, date range, and forest details.

    .PARAMETER GPOName
    Specifies the name of the GPO to retrieve.

    .PARAMETER GPOGuid
    Specifies the GUID of the GPO to retrieve.

    .PARAMETER Forest
    Specifies the forest name to search for GPOs.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from the search.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include in the search.

    .PARAMETER DateFrom
    Specifies the start date for filtering GPOs based on creation or modification date.

    .PARAMETER DateTo
    Specifies the end date for filtering GPOs based on creation or modification date.

    .PARAMETER DateRange
    Specifies a predefined date range for filtering GPOs based on creation or modification date.

    .PARAMETER DateProperty
    Specifies the property (WhenCreated or WhenChanged) to use for filtering GPOs based on date.

    .PARAMETER ExtendedForestInformation
    Specifies additional forest information to include in the output.

    .EXAMPLE
    Get-GPOZaurrAD -GPOName "ExampleGPO"

    Description:
    Retrieves information about a GPO with the name "ExampleGPO".

    .EXAMPLE
    Get-GPOZaurrAD -GPOGuid "{12345678-1234-1234-1234-123456789012}"

    Description:
    Retrieves information about a GPO with the specified GUID.

    .EXAMPLE
    Get-GPOZaurrAD -Forest "example.com" -IncludeDomains "domain1", "domain2" -DateRange "Last30Days"

    Description:
    Retrieves GPO information from the forest "example.com" for domains "domain1" and "domain2" created or modified in the last 30 days.

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
                    $Splat['Filter'] = -join ($Splat['Filter'], " -and ($Property -ge $DateFrom -and $Property -le $DateTo)")
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
                    $Splat['Filter'] = -join ($Splat['Filter'], " -and ($Property -ge $DateFrom -and $Property -le $DateTo)")
                } else {
                    Write-Warning -Message "Get-GPOZaurrAD - DateProperty parameter is empty. Provide name and try again."
                    continue
                }
            } else {
                # not needed
            }

            Write-Verbose -Message "Get-GPOZaurrAD - Searching domain $Domain with filter $($Splat['Filter'])"
            $Objects = Get-ADObject @Splat -Properties DisplayName, Name, Created, Modified, ntSecurityDescriptor, gPCFileSysPath, gPCFunctionalityVersion, gPCWQLFilter, gPCMachineExtensionNames, Description, CanonicalName, DistinguishedName
            foreach ($Object in $Objects) {
                $DomainCN = ConvertFrom-DistinguishedName -DistinguishedName $Object.DistinguishedName -ToDomainCN
                $GUID = $Object.Name -replace '{' -replace '}'
                if (($GUID).Length -ne 36) {
                    Write-Warning "Get-GPOZaurrAD - GPO GUID ($($($GUID.Replace("`n",' ')))) is incorrect. Skipping $($Object.DisplayName) / Domain: $($DomainCN)"
                } else {
                    [PSCustomObject]@{
                        'DisplayName'                = $Object.DisplayName
                        'DomainName'                 = $DomainCN
                        'Description'                = $Object.Description
                        'GUID'                       = $GUID
                        'Path'                       = $Object.gPCFileSysPath
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