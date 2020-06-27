function Get-XMLStandard {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [System.Xml.XmlElement[]] $GPOOutput,
        [string] $Splitter = [System.Environment]::NewLine,
        [switch] $FullObjects
    )
    $LinksInformation = Get-LinksFromXML -GPOOutput $GPOOutput -Splitter $Splitter -FullObjects:$FullObjects
    foreach ($Type in @('User', 'Computer')) {
        if ($GPOOutput.$Type.ExtensionData.Extension) {
            foreach ($ExtensionType in $GPOOutput.$Type.ExtensionData.Extension) {
                $GPOSettingTypeSplit = ($ExtensionType.type -split ':')
                $KeysToLoop = $ExtensionType | Get-Member -MemberType Properties | Where-Object { $_.Name -notin 'type', $GPOSettingTypeSplit[0] }
                foreach ($Keys in $KeysToLoop.Name) {
                    foreach ($Key in $ExtensionType.$Keys) {
                        $Template = [ordered] @{
                            DisplayName = $GPO.DisplayName
                            DomainName  = $GPO.DomainName
                            GUID        = $GPO.Guid
                            Linked      = $LinksInformation.Linked
                            LinksCount  = $LinksInformation.LinksCount
                            Links       = $LinksInformation.Links
                            GpoType     = $Type
                            GpoSubType  = $GPOSettingTypeSplit[1]
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