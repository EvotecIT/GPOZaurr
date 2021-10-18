function Get-GPOZaurrUpdates {
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [DateTime] $DateFrom,
        [DateTime] $DateTo,
        [ValidateSet('PastHour', 'CurrentHour', 'PastDay', 'CurrentDay', 'PastMonth', 'CurrentMonth', 'PastQuarter', 'CurrentQuarter', 'Last14Days', 'Last7Days', 'Last3Days', 'Last1Days')][string] $DateRange,
        [ValidateSet('WhenCreated', 'WhenChanged')][string] $DateProperty = 'WhenCreated',
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

    Write-Verbose -Message "Get-GPOZaurrUpdates - Get group policies for defined ranges"
    $LinksSummaryCache = Get-GPOZaurrLink -AsHashTable -Summary -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation

    $OUCache = [ordered] @{}
    foreach ($Domain in $ForestInformation.Domains) {
        $OrganizationalUnits = Get-ADOrganizationalUnit -Filter * -Properties gpOptions, canonicalName -Server $ForestInformation['QueryServers'][$Domain]['HostName'][0]
        $OUCache[$OrganizationalUnits.DistinguishedName] = if ($OrganizationalUnits.gpOptions -eq 1) { $true } else { $false } # blocked inheritance
    }


    $GPOs = Get-GPOZaurrAD @getGPOZaurrADSplat
    foreach ($GPO in $GPOs) {
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
        [PSCustomObject] @{
            DisplayName             = $GPO.DisplayName
            DomainName              = $GPO.DomainName
            Owner                   = $GPO.Owner
            LinksCount              = if ($GPOLinkData) { $GPOLinkData.LinksCount } else { 0 }
            LinksEnabledCount       = if ($GPOLinkData) { $GPOLinkData.LinksEnabledCount } else { 0 }
            AffectedCount           = $OrganizationalUnitsObjects.ObjectsTotalCount
            BlockedInheritanceCount = $OrganizationalUnitsObjects.ObjectsBlockedInheritanceCount
            AffectedClasses         = $OrganizationalUnitsObjects.ObjectsClasses
            Created                 = $GPO.Created
            Changed                 = $GPO.Modified
            LinksEnabled            = $LinksDN
        }
    }
}