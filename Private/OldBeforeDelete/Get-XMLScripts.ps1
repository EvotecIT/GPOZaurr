function Get-XMLScripts {
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
                foreach ($Key in $ExtensionType.Script) {
                    if ($FullObjects) {
                        [PSCustomObject] @{
                            DisplayName = $GPO.DisplayName
                            DomainName  = $GPO.DomainName
                            GUID        = $GPO.Guid
                            Linked      = $LinksInformation.Linked
                            LinksCount  = $LinksInformation.LinksCount
                            Links       = $LinksInformation.Links
                            GpoType     = $Type
                            Command     = $Key.Command
                            Parameters  = $Key.Parameters
                            Type        = $Key.Type
                            Order       = $Key.Order
                            RunOrder    = $Key.RunOrder
                        }
                    } else {
                        [PSCustomObject] @{
                            DisplayName = $GPO.DisplayName
                            DomainName  = $GPO.DomainName
                            GUID        = $GPO.Guid
                            Linked      = $LinksInformation.Linked
                            LinksCount  = $LinksInformation.LinksCount
                            Links       = $LinksInformation.Links
                            GpoType     = $Type
                            Command     = $Key.Command
                            Parameters  = $Key.Parameters
                            type        = $Key.Type
                            Order       = $Key.Order
                            RunOrder    = $Key.RunOrder
                        }
                    }
                }
            }
        }
    }
}