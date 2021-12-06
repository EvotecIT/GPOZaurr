function Get-GPOZaurrUpdates {
    <#
    .SYNOPSIS
    Gets the list of GPOs created or updated in the last X number of days.

    .DESCRIPTION
    Gets the list of GPOs created or updated in the last X number of days.

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned
ą
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
    Get-GPOZaurrUpdates -DateRange Last14Days -DateProperty WhenCreated, WhenChanged -Verbose -IncludeDomains 'ad.evotec.pl' | Format-List

    .EXAMPLE
    Get-GPOZaurrUpdates -DateRange Last14Days -DateProperty WhenCreated -Verbose | Format-Table

    .NOTES
    General notes
    #>
    [cmdletBinding(DefaultParameterSetName = 'DateRange')]
    param(
        [parameter(ParameterSetName = 'Dates')]
        [parameter(ParameterSetName = 'DateRange')]
        [alias('ForestName')][string] $Forest,
        [parameter(ParameterSetName = 'Dates')]
        [parameter(ParameterSetName = 'DateRange')]
        [string[]] $ExcludeDomains,
        [parameter(ParameterSetName = 'Dates')]
        [parameter(ParameterSetName = 'DateRange')]
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [parameter(Mandatory, ParameterSetName = 'Dates')][DateTime] $DateFrom,
        [parameter(Mandatory, ParameterSetName = 'Dates')][DateTime] $DateTo,
        [parameter(Mandatory, ParameterSetName = 'DateRange')][ValidateSet('PastHour', 'CurrentHour', 'PastDay', 'CurrentDay', 'PastMonth', 'CurrentMonth', 'PastQuarter', 'CurrentQuarter', 'Last14Days', 'Last21Days', 'Last30Days', 'Last7Days', 'Last3Days', 'Last1Days')][string] $DateRange,
        [parameter(ParameterSetName = 'Dates')]
        [parameter(ParameterSetName = 'DateRange')]
        [ValidateSet('WhenCreated', 'WhenChanged')][string[]] $DateProperty = 'WhenCreated',
        [parameter(ParameterSetName = 'Dates')]
        [parameter(ParameterSetName = 'DateRange')]
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $getGPOZaurrADSplat = @{
        Forest                    = $Forest
        IncludeDomains            = $IncludeDomains
        ExcludeDomains            = $ExcludeDomains
        ExtendedForestInformation = $ExtendedForestInformation
        DateFrom                  = $DateFrom
        DateTo                    = $DateTo
        DateRange                 = $DateRange
        DateProperty              = $DateProperty
    }
    Remove-EmptyValue -Hashtable $getGPOZaurrADSplat
    # lets get all the links including sites

    if ($DateRange) {
        Write-Verbose -Message "Get-GPOZaurrUpdates - Get group policies for defined range $DateRange"
    } elseif ($DateFrom -and $DateTo) {
        Write-Verbose -Message "Get-GPOZaurrUpdates - Get group policies for defined range $DateFrom to $DateTo"
    } else {
        Write-Warning -Message "Get-GPOZaurrUpdates - No range is selected. Try again."
        return
    }
    $LinksSummaryCache = Get-GPOZaurrLink -AsHashTable -Summary -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation

    $OUCache = [ordered] @{}
    foreach ($Domain in $ForestInformation.Domains) {
        Write-Verbose -Message "Get-GPOZaurrUpdates - Getting OU's for $Domain"
        $OrganizationalUnits = Get-ADOrganizationalUnit -Filter * -Properties gpOptions, canonicalName -Server $ForestInformation['QueryServers'][$Domain]['HostName'][0]
        $OUCache[$OrganizationalUnits.DistinguishedName] = if ($OrganizationalUnits.gpOptions -eq 1) { $true } else { $false } # blocked inheritance
    }

    $CurrentCount = 0
    Write-Verbose -Message "Get-GPOZaurrUpdates - Getting GPO information"
    [Array] $GPOs = Get-GPOZaurrAD @getGPOZaurrADSplat
    foreach ($GPO in $GPOs) {
        $CurrentCount++
        Write-Verbose -Message "Get-GPOZaurrUpdates - Processing $($GPO.DisplayName) / $($GPO.DomainName) [$CurrentCount/$($GPOs.Count)]"
        $GPOLinkData = $LinksSummaryCache["$($GPO.DomainName)$($GPO.GUID)"]
        #$GPOLinkData
        [Array] $LinksDN = if ($GPOLinkData.Links.Count -gt 0) {
            foreach ($Link in $GPOLinkData.LinksObjects) {
                If ($Link.Enabled -eq $true) {
                    $Link.DistinguishedName
                }
            }
        }
        if ($LinksDN.Count -gt 0) {
            $OrganizationalUnitsObjects = Get-ADOrganizationalUnitObject -OrganizationalUnit $LinksDN -Summary -IncludeAffectedOnly
        } else {
            # GPO is not linked
            $OrganizationalUnitsObjects = [PSCUstomObject] @{
                ObjectsTotalCount              = 0
                ObjectsBlockedInheritanceCount = 0
                ObjectsClasses                 = @()
            }
        }
        if ($GPO.Owner) {
            $Owner = Get-WinADObject -Identity $GPO.Owner -AddType
        } else {
            $Owner = [PSCustomObject] @{
                Name        = 'Unknown'
                Type        = 'Unknown'
                ObjectClass = 'Unknown'
            }
        }
        [PSCustomObject] @{
            DisplayName             = $GPO.DisplayName
            GUID                    = ConvertFrom-DistinguishedName -DistinguishedName $GPO.GPODistinguishedName
            DomainName              = $GPO.DomainName
            Owner                   = $GPO.Owner
            OwnerName               = $Owner.Name
            OwnerType               = $Owner.Type
            OwnerClass              = $Owner.ObjectClass
            LinksCount              = if ($GPOLinkData) { $GPOLinkData.LinksCount } else { 0 }
            LinksEnabledCount       = if ($GPOLinkData) { $GPOLinkData.LinksEnabledCount } else { 0 }
            AffectedCount           = $OrganizationalUnitsObjects.ObjectsTotalCount
            BlockedInheritanceCount = $OrganizationalUnitsObjects.ObjectsBlockedInheritanceCount
            AffectedClasses         = $OrganizationalUnitsObjects.ObjectsClasses.GetEnumerator().Name
            Created                 = $GPO.Created
            Changed                 = $GPO.Modified
            LinksEnabled            = $LinksDN
        }
    }
}