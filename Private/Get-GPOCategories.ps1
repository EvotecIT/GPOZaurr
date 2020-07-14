function Get-GPOCategories {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [System.Xml.XmlElement[]] $GPOOutput,
        [string] $Splitter,
        [switch] $FullObjects,
        [System.Collections.IDictionary] $CachedCategories
    )
    if (-not $CachedCategories) {
        $CachedCategories = [ordered] @{}
    }
    $LinksInformation = Get-LinksFromXML -GPOOutput $GPOOutput -Splitter $Splitter -FullObjects:$FullObjects
    foreach ($GpoType in @('User', 'Computer')) {
        if ($GPOOutput.$GpoType.ExtensionData.Extension) {
            foreach ($ExtensionType in $GPOOutput.$GpoType.ExtensionData.Extension) {
                # It's possible that one of the ExtensionType records has value null. Weird but happend.
                if ($ExtensionType) {
                    $GPOSettingTypeSplit = ($ExtensionType.type -split ':')
                    try {
                        $KeysToLoop = $ExtensionType | Get-Member -MemberType Properties -ErrorAction Stop | Where-Object { $_.Name -notin 'type', $GPOSettingTypeSplit[0] -and $_.Name -notin @('Blocked') }
                    } catch {
                        Write-Warning "Get-XMLStandard - things went sideways $($_.Exception.Message)"
                        continue
                    }

                    foreach ($GpoSettings in $KeysToLoop.Name) {
                        $Template = [ordered] @{
                            DisplayName = $GPO.DisplayName
                            DomainName  = $GPO.DomainName
                            GUID        = $GPO.Guid
                            GpoType     = $GpoType
                            GpoCategory = $GPOSettingTypeSplit[1]
                            GpoSettings = $GpoSettings
                        }
                        $Template['Linked'] = $LinksInformation.Linked
                        $Template['LinksCount'] = $LinksInformation.LinksCount
                        $Template['Links'] = $LinksInformation.Links
                        $Template['IncludeComments'] = [bool]::Parse($GPOOutput.IncludeComments)
                        $Template['CreatedTime'] = [DateTime] $GPOOutput.CreatedTime
                        $Template['ModifiedTime'] = [DateTime] $GPOOutput.ModifiedTime
                        $Template['ReadTime'] = [DateTime] $GPOOutput.ReadTime
                        $Template['SecurityDescriptor'] = $GPOOutput.SecurityDescriptor
                        $Template['FilterDataAvailable'] = [bool]::Parse($GPOOutput.FilterDataAvailable)
                        $Template['DataSet'] = $ExtensionType.$GpoSettings
                        $ConvertedObject = [PSCustomObject] $Template

                        if (-not $CachedCategories["$($Template.GpoCategory)"]) {
                            $CachedCategories["$($Template.GpoCategory)"] = [ordered] @{}
                        }
                        if (-not $CachedCategories["$($Template.GpoCategory)"]["$($Template.GpoSettings)"]) {
                            $CachedCategories["$($Template.GpoCategory)"]["$($Template.GpoSettings)"] = [System.Collections.Generic.List[PSCustomObject]]::new()
                        }
                        $CachedCategories["$($Template.GpoCategory)"]["$($Template.GpoSettings)"].Add($ConvertedObject)
                        # return GPOCategory
                        $ConvertedObject
                    }
                }
            }
        }
    }
}