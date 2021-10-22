function Get-GPOZaurrUpdates {
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
        [parameter(Mandatory, ParameterSetName = 'DateRange')][ValidateSet('PastHour', 'CurrentHour', 'PastDay', 'CurrentDay', 'PastMonth', 'CurrentMonth', 'PastQuarter', 'CurrentQuarter', 'Last14Days', 'Last7Days', 'Last3Days', 'Last1Days')][string] $DateRange,
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