function Get-GPOCategories {
    <#
    .SYNOPSIS
    Retrieves GPO categories based on the provided GPO object and XML output.

    .DESCRIPTION
    This function retrieves GPO categories by analyzing the provided GPO object and XML output. It categorizes GPO settings based on different criteria.

    .PARAMETER GPO
    The GPO object containing information about the Group Policy Object.

    .PARAMETER GPOOutput
    An array of XML elements representing the GPO output.

    .PARAMETER Splitter
    The delimiter used to split GPO settings.

    .PARAMETER FullObjects
    A switch parameter to indicate whether to retrieve full GPO objects.

    .PARAMETER CachedCategories
    A dictionary containing cached GPO categories.

    .EXAMPLE
    Get-GPOCategories -GPO $gpoObject -GPOOutput $xmlOutput -Splitter ":" -FullObjects

    Description:
    Retrieves GPO categories for the specified GPO object and XML output, splitting settings using ":" as the delimiter and retrieving full GPO objects.

    #>
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