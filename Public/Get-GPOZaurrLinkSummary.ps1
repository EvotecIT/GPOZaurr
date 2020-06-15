function Get-GPOZaurrLinkSummary {
    [cmdletBinding()]
    param(
        [ValidateSet('All', 'MultipleLinks', 'OneLink', 'LinksSummary')][string[]] $Report = 'All',
        [switch] $UnlimitedProperties
    )
    $HighestCount = 0 # to keep number of depth
    $CacheSummaryLinks = [ordered] @{} # cache

    # Get all links
    $Links = Get-GPOZaurrLink
    foreach ($Link in $Links) {
        if (-not $CacheSummaryLinks["$($Link.DomainName)$($Link.Guid)"]) {
            $CacheSummaryLinks["$($Link.DomainName)$($Link.Guid)"] = [System.Collections.Generic.List[System.Object]]::new()
        }
        $CacheSummaryLinks["$($Link.DomainName)$($Link.Guid)"].Add($Link)
    }

    $ReturnObject = [ordered] @{
        MultipleLinks = [System.Collections.Generic.List[System.Object]]::new()
        OneLink       = [System.Collections.Generic.List[System.Object]]::new()
        LinksSummary  = [System.Collections.Generic.List[System.Object]]::new()
    }

    foreach ($Key in $CacheSummaryLinks.Keys) {
        $GPOs = $CacheSummaryLinks[$Key]

        [Array] $LinkingSummary = foreach ($GPO in $GPOs) {
            $SplitttedOU = ($GPO.DistinguishedName -split ',')
            [Array] $Clean = foreach ($_ in $SplitttedOU) {
                if ($_ -notlike 'DC=*') { $_ -replace 'OU=' }
            }
            if ($Clean.Count -gt $HighestCount) {
                $HighestCount = $Clean.Count
            }
            if ($Clean) {
                $Test = [ordered] @{
                    GPOName = $GPO.DisplayName
                    #Test    = $GPO.DistinguishedName
                    Level0  = ConvertFrom-DistinguishedName -DistinguishedName $GPO.DistinguishedName -ToDomainCN
                }
                for ($i = 1; $i -le 10; $i++) {
                    $Test["Level$i"] = $Clean[ - $i]
                }
                [PSCustomobject] $Test
            } else {
                $Test = [ordered] @{
                    GPOName = $GPO.DisplayName
                    #Test    = $GPO.DistinguishedName
                    Level0  = $GPO.CanonicalName
                }
                for ($i = 1; $i -le 10; $i++) {
                    $Test["Level$i"] = $null
                }
                [PSCustomobject] $Test
            }
        }
        if ($Report -contains 'MultipleLinks' -or $Report -contains 'All') {
            foreach ($Link in $LinkingSummary) {
                $ReturnObject.MultipleLinks.Add($Link)
            }
            #continue
        }
        if ($Report -eq 'OneLink' -or $Report -contains 'All') {
            $List = [ordered] @{
                GPOName    = $GPO.DisplayName
                DomainName = $GPO.DomainName
                LinksCount = $GPOs.Count
            }
            for ($i = 0; $i -le 10; $i++) {
                $List["Level$i"] = ($LinkingSummary."Level$i" | Select-Object -Unique).Count
                $List["Level$($i)List"] = ($LinkingSummary."Level$i" | Select-Object -Unique)
            }


            <#
                Level0     = ($LinkingSummary.Level0 | Select-Object -Unique).Count
                Level0List = ($LinkingSummary.Level0 | Select-Object -Unique)
                Level1     = ($LinkingSummary.Level1 | Select-Object -Unique).Count
                Level1List = ($LinkingSummary.Level1 | Select-Object -Unique)
                Level2     = ($LinkingSummary.Level2 | Select-Object -Unique).Count
                Level2List = ($LinkingSummary.Level2 | Select-Object -Unique)
            #>

            $List.LinksDistinguishedName = $GPOs.DistinguishedName          # = Computers, OU = ITR02, DC = ad, DC = evotec, DC = xyz
            $List.LinksCanonicalName = $GPOs.CanonicalName
            $ReturnObject.OneLink.Add( [PSCustomObject] $List)
        }
        if ($Report -eq 'LinksSummary' -or $Report -contains 'All') {
            $Output = [PSCustomObject] @{
                Guid                   = $GPOs[0].Guid                       #: AA782787 - 002B-4B8C-886F-05873F2DC0CA
                DisplayName            = $GPOs[0].DisplayName                #: COMPUTERS | LAPS
                DomainName             = $GPOs[0].DomainName                 #: ad.evotec.xyz
                LinksCount             = $GPOs.Count
                LinksDistinguishedName = $GPOs.DistinguishedName          # = Computers, OU = ITR02, DC = ad, DC = evotec, DC = xyz
                LinksCanonicalName     = $GPOs.CanonicalName              #: ad.evotec.xyz / ITR02 / Computers
                #LinkSummary = $LinkingSummary
                <#
                Owner                      = $GPOs[0].Owner                      #: EVOTEC\Domain Admins
                GpoStatus                  = $GPOs[0].GpoStatus                  #: AllSettingsEnabled
                Description                = $GPOs[0].Description                #:
                CreationTime               = $GPOs[0].CreationTime               #: 16.12.2019 21:25:32
                ModificationTime           = $GPOs[0].ModificationTime           #: 30.05.2020 19:12:58
                GPODomainDistinguishedName = $GPOs[0].GPODomainDistinguishedName #: DC = ad, DC = evotec, DC = xyz
                GPODistinguishedName       = $GPOs[0].GPODistinguishedName       #: cn = { AA782787 - 002B-4B8C-886F-05873F2DC0CA }, cn = policies, cn = system, DC = ad, DC = evotec, DC = xy
                #>
            }
            $ReturnObject.LinksSummary.Add($Output)
        }
    }
    # Processing output
    if (-not $UnlimitedProperties) {
        if ($Report -contains 'MultipleLinks' -or $Report -contains 'All') {
            $Properties = @(
                'GPOName'
                for ($i = 0; $i -le $HighestCount; $i++) {
                    "Level$i"
                }
            )
            $ReturnObject.MultipleLinks = $ReturnObject.MultipleLinks | Select-Object -Property $Properties
        }
        if ($Report -contains 'OneLink' -or $Report -contains 'All') {
            $Properties = @(
                'GPOName'
                'DomainName'
                for ($i = 0; $i -le $HighestCount; $i++) {
                    "Level$i"
                    "Level$($i)List"
                }
                'LinksDistinguishedName'
                'LinksCanonicalName'
            )
            $ReturnObject.OneLink = $ReturnObject.OneLink | Select-Object -Property $Properties
        }
        if ($Report -contains 'LinksSummary' -or $Report -contains 'All') {
            # Not needed because there's no dynamic properties, but if there would be we need to uncomment and fix it
            <#
            $Properties = @(
                'Guid'
                'DisplayName'
                'DomainName'
                'LinksCount'
                'LinksDistinguishedName'
                'LinksCanonicalName'
            )
            $ReturnObject.LinksSummary = $ReturnObject.LinksSummary | Select-Object -Property $Properties
            #>
        }
    }
    if ($Report.Count -eq 1 -and $Report -notcontains 'All') {
        $ReturnObject["$Report"]
    } else {
        $ReturnObject
    }
}