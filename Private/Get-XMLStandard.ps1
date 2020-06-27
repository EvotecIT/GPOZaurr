function Get-XMLStandard {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [System.Xml.XmlElement[]] $GPOOutput,
        [string] $Splitter,
        [switch] $FullObjects
    )
    $LinksInformation = Get-LinksFromXML -GPOOutput $GPOOutput -Splitter $Splitter -FullObjects:$FullObjects
    foreach ($GpoType in @('User', 'Computer')) {
        if ($GPOOutput.$GpoType.ExtensionData.Extension) {
            foreach ($ExtensionType in $GPOOutput.$GpoType.ExtensionData.Extension) {
                $GPOSettingTypeSplit = ($ExtensionType.type -split ':')
                $KeysToLoop = $ExtensionType | Get-Member -MemberType Properties | Where-Object { $_.Name -notin 'type', $GPOSettingTypeSplit[0] }
                foreach ($GpoSettings in $KeysToLoop.Name) {
                    foreach ($Key in $ExtensionType.$GpoSettings) {
                        $Template = [ordered] @{
                            DisplayName = $GPO.DisplayName
                            DomainName  = $GPO.DomainName
                            GUID        = $GPO.Guid
                            Linked      = $LinksInformation.Linked
                            LinksCount  = $LinksInformation.LinksCount
                            Links       = $LinksInformation.Links
                            GpoType     = $GpoType
                            GpoCategory = $GPOSettingTypeSplit[1]
                            GpoSettings = $GpoSettings
                        }
                        $Properties = ($Key | Get-Member -MemberType Properties).Name
                        foreach ($Property in $Properties) {
                            $Template["$Property"] = $Key.$Property
                        }
                        [PSCustomObject] $Template
                    }
                }
            }
        }
    }
}